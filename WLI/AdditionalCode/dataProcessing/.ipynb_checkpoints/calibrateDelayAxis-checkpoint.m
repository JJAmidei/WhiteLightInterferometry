% CALIBRATEDELAY AXIS Calibrates the delay axis using knowledge of the HeNe
% wavelength
%
% v  | voltages from the labjack and diode
% xL | linear x-grid
function xNL = calibrateDelayAxis(v,xL)
    
    % HeNe wavelength in mm. OK to hard-code
    lambdaHeNe = 0.6328/1000;
    
    % angular wave number
    k = 2*pi/lambdaHeNe;
    
    % step size
    dx_mm = mean(diff(xL));
    
    % number of points in the grid
    N = numel(xL);
    
    % c_mm_ps = 0.3;
    % t = 2*xL/c_mm_ps;
    % dw = 2*pi/max(abs(t));
    % wMax = dw*N;
    % w = -wMax/2:dw:wMax/2-dw;
    % 
    % idx=w>0;
    % lambda = (2*pi*c_mm_ps./w)*1000;
    % 
    % figure;
    % V = fftshift( fft( ifftshift( v ) ) );
    % plot(lambda(idx), abs(V(idx)) ); axis tight;
    
    % spatial frequency grid -------------------------------------------- %
    %
    % step size
    dfx = 1/dx_mm/N;
    
    % maximum extent
    fxMax = 1/dx_mm;
    
    % grid
    fx = (-fxMax/2:dfx:fxMax/2-dfx)';
    
    % take the Fourier transform of the voltage array
    V = fftshift( fft( ifftshift( v ) ) );
    % figure;movegui('north');plot(fx,abs(V));
    % the ac peak is located near
    p0 = 1/lambdaHeNe;
    
    % find the nearest pixel to this location
    [~,idx] = min( abs(p0-fx) );
    [~,idx0] = min(abs(fx));
    % construct a super-Gaussian filter
    %
    % super-Gaussian order
    n = 22;
    
    % half-width. Note: it's ok if N is odd because this is the width of an
    % analytic function
    sigma = (idx-(N/2+1))*dfx * 0.25;
    
    % filter
    G = exp(-(fx-fx(idx)).^n/sigma^n);
    
    %Observe location of super gaussian compared to peak
    % figure; plot(fx,abs(V)/max(abs(V(:))),fx,G); rectangle('position',[p0-dfx/2,0,dfx,0.1]);
    
    % multiply this by the function and circshift to the center
    V = circshift(G .* V, -(idx-idx0));
    % plot(fx,abs(V)); axis tight;
    
    % inverse Fourier transform
    v2 = fftshift( ifft( ifftshift(V) ) );
    
    % extract the phase and unwrap
    phi = unwrap(angle(v2));
    
    % solve for the position dependent correction
    delta_x = phi/k;
    
    % add these deltas back to the original x-grid
    xNL = xL+delta_x;
    % plot(1:N,xL,1:N,xNL);
    
    % % Use the following code to check to make sure this process worked
    % % correctly
    % %
    % % interpolate the voltages
    % v = interp1(xNL,v,xL,'pchip',0);
    % 
    % % Fourier transform

    % c_mm_ps = 0.3;
    % t = 2*xL/c_mm_ps;
    % dw = 2*pi/max(abs(t));
    % wMax = dw*N;
    % w = -wMax/2:dw:wMax/2-dw;
    % lambda = (2*pi*c_mm_ps./w)*1000;
    % 
    % idx = (w>0)&(lambda<1);
    % 
    % figure;
    % V = fftshift( fft( ifftshift( v ) ) );
    % plot(lambda(idx), abs(V(idx)) ); axis tight; title('FT of voltage')
    
end

function numInum = convertmm2um(numInum)
    numInum = numInum * 1000;
    
end

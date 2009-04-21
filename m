From: Aioanei Rares <krnl.list@gmail.com>
Subject: Re: 2.6.29.1: Pid: 2831, comm: nfsd Not tainted 2.6.29.1 #4
Date: Tue, 21 Apr 2009 23:00:59 +0300
Message-ID: <49EE25FB.9050503@gmail.com>
References: <alpine.DEB.2.00.0904211202590.10241@p34.internal.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Justin Piszcz <jpiszcz@lucidpixels.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754469AbZDUUBW@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.0904211202590.10241@p34.internal.lan>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Justin Piszcz wrote:



> Hello,
>
> This has been happening with 2.6.28.(x) and now 2.6.29.(x), can anyone 
> suggest the possible root cause of this problem, re: the nfsd page 
> allocation
> failures:
>


<snip>

Yes, it happened to me too on a Debian unstable machine with more than 
one kernel, starting with 2.6.28 until now. I have a feeling it's a 
Debian-specific problem rather than a kernel one.

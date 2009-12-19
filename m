From: fche@redhat.com (Frank Ch. Eigler)
Subject: Re: 2.6.33 NFS server header reorg breaks existing systemtap scripts.
Date: Sat, 19 Dec 2009 11:40:58 -0500
Message-ID: <y0mmy1e9asl.fsf@fche.csb>
References: <4B2CF5AB.9040000@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: SystemTAP
	<public-systemtap-R2MHTz/CkKAf7BdofF/totBPR1lH4CV8-wOFGN7rlS/M9smdsby/KFg@public.gmane.org>,
	Linux NFS Mailing list
	<public-linux-nfs-u79uwXL29TY76Z2rM5mHXA-wOFGN7rlS/M9smdsby/KFg@public.gmane.org>
To: Steve Dickson
	<public-SteveD-H+wXaHxf7aLQT0dZR+AlfA-wOFGN7rlS/M9smdsby/KFg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:43963 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752671AbZLSRRt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 19 Dec 2009 12:17:49 -0500
Received: from public by plane.gmane.org with local (Exim 4.63)
	(envelope-from <public-wOFGN7rlS/M9smdsby/KFg@public.gmane.org>)
	id 1NM2Mc-0006PL-I2
	for linux-nfs@vger.kernel.org; Sat, 19 Dec 2009 17:41:06 +0100
In-Reply-To: <4B2CF5AB.9040000-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org> (Steve Dickson's message of "Sat, 19 Dec 2009 10:47:55 -0500")
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>




Hi -

steved wrote:

> [...]
> In the upcoming 2.6.33 kernel release the following
> NFS server header files have been moved out of the 
> 'include/linux/nfsd' include directory and into the 
> 'fs/nfsd' source directory:
>      linux/nfsd/nfsd.h
>      linux/nfsd/cache.h
>      linux/nfsd/xdr.h
>      linux/nfsd/xdr3.h
>      linux/nfsd/xdr4.h
>
> This reorg will break any and all existing systemtap scripts 
> including the nfsd.stp in the current systemtap release. 

Sigh.  Well, nfsd.stp can probably adapt to avoid using those headers,
and rewrite __get_fh etc. to rely on @cast() instead of embedded-C.


> Plus it appears the header files that live in source directories are
> not include in the kernel-devel package
 
Yes, it's a problem.  This is harder to work around for tracepoints,
which systemtap finds by parsing kernel-devel header files (instead of
searching debuginfo or whatnot).  Perhaps we should lobby kernel-devel
to include all .h files from the kernel build trees, even subsystem 
internal .h files.


- FChE


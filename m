From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: (ANSWER) Question About nfs3 vs. nfs4 Semantics On Sun 7310
	Server
Date: Thu, 5 Nov 2009 14:55:15 -0500
Message-ID: <20091105195515.GA1989@fieldses.org>
References: <hcsvs6$dbl$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Jon Forrest <jlforrest-TVLZxgkOlNX2fBVCVOL8/A@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:32923 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751885AbZKETzF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Nov 2009 14:55:05 -0500
In-Reply-To: <hcsvs6$dbl$1@ger.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 04, 2009 at 02:40:21PM -0800, Jon Forrest wrote:
> The other day I posted the description below of a problem
> I was having when I was mounting from a Sun 7310
> server using NFSv3 and NFSv4 from a CentOS 5.3
> client.
>
> It turned out that the solution was trivial - all
> I needed to do was to use the "noacl" option
> in my NFSv3 mount command. I still think that the
> client shouldn't have complained about not
> being able to preserve file protections since
> it was actually to do so.

I still don't understand quite what was happening: in the absence of
"noacl", does the client just always claim to support the posix acl
xattr's, but return an error when cp attempts to set them?

--b.

>
> I'm still not sure if I should try NFSv4 but that's
> another issue.
>
> Cordially,
>
> -- 
> Jon Forrest
> Research Computing Support
> College of Chemistry
> 173 Tan Hall
> University of California Berkeley
> Berkeley, CA
> 94720-1460
> 510-643-1032
>
> 1    [nfs3]# touch x
> 2    [nfs3]# cp -p x y
> 3    cp: preserving permissions for `y': Operation not supported
> 4    cp: preserving ACL for `y': Operation not supported
> 5    [nfs3]# ls -l
> 6    total 1
> 7    -rw-r--r--+ 1 root root 0 Nov  3 14:46 x
> 8    -rw-r--r--+ 1 root root 0 Nov  3 14:46 y
> 9    [nfs3]# cd /tmp/x/home/jlforrest/nfs4
> 10   [nfs4]# touch x
> 11   [nfs4]# cp -p x y
> 12   [nfs4]# ls -l
> 13   total 1
> 14   -rw-rw-r-- 1 nobody nobody 0 Nov  3 14:48 x
> 15   -rw-rw-r-- 1 nobody nobody 0 Nov  3 14:48 y
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

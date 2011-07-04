Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f52.google.com ([209.85.161.52]:43265 "EHLO
	mail-fx0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753157Ab1GDGyN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Jul 2011 02:54:13 -0400
Received: by fxd18 with SMTP id 18so4960613fxd.11
        for <linux-nfs@vger.kernel.org>; Sun, 03 Jul 2011 23:54:12 -0700 (PDT)
Message-ID: <4E11638B.5090302@tonian.com>
Date: Mon, 04 Jul 2011 09:54:03 +0300
From: Benny Halevy <bhalevy@tonian.com>
To: Steve Dickson <SteveD@redhat.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: ANNOUNCE: nfs-utils-1.2.4 re-released.
References: <4E0C94D4.50205@RedHat.com>
In-Reply-To: <4E0C94D4.50205@RedHat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

git://linux-nfs.org/~bhalevy/pnfs-nfs-utils
rebased accordingly, tip at tag pnfs-nfs-utils-1-2-4

Benny

On 2011-06-30 18:23, Steve Dickson wrote:
> I just make a re-release of 1.2.4 this that corrects the mount problem.
> Again, my apologies for not catching this problem before the release.
> Its something I will avoid in the feature...  
> 
> New Features in this release:
> 
>    * Added the --enable-libmount-mount configuration 
>      flag that enables the mount command to use the new
>      libmount code.
> 
>    * A large number of bug fixes.
> 
> The tarballs can be found at:
> 
>   http://www.kernel.org/pub/linux/utils/nfs/
>   http://sourceforge.net/projects/nfs
> 
> The git tree is at:
>    git://linux-nfs.org/nfs-utils
> 
> The change log:
> 
> http://www.kernel.org/pub/linux/utils/nfs/ChangeLog-nfs-utils-1.2.4
> 
> steved.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

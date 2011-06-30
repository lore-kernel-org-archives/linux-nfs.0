Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:59986 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751904Ab1F3R7k (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Jun 2011 13:59:40 -0400
Date: Thu, 30 Jun 2011 13:59:39 -0400
To: Steve Dickson <SteveD@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: ANNOUNCE: nfs-utils-1.2.4 re-released.
Message-ID: <20110630175939.GB18713@fieldses.org>
References: <4E0C94D4.50205@RedHat.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E0C94D4.50205@RedHat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Jun 30, 2011 at 11:23:00AM -0400, Steve Dickson wrote:
> I just make a re-release of 1.2.4 this that corrects the mount problem.
> Again, my apologies for not catching this problem before the release.
> Its something I will avoid in the feature...  

Once we've made something available under one version number, in future
I'd rather we make it an absolute rule not to release something else
under the same number, even if that means releasing N and N+1 with a day
of each other....  It's just two confusing if "1.2.4" could mean two
different things, even if one of them was only available briefly.

--b.

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

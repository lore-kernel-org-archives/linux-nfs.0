Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47950 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750991Ab1F3LkR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Jun 2011 07:40:17 -0400
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p5UBeGaT029257
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 30 Jun 2011 07:40:16 -0400
Message-ID: <4E0C609F.10301@RedHat.com>
Date: Thu, 30 Jun 2011 07:40:15 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: ANNOUNCE: nfs-utils-1.2.4 released.
References: <4E0B3A7B.9080006@RedHat.com>
In-Reply-To: <4E0B3A7B.9080006@RedHat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello,

Please hold off on download this version since the mount
command is broken when libmount code is not enabled. The 
breakage was missed due to a misconfiguration in my 
testing... My apologies! 

Shortly I will be re-issuing a new 1.2.4 release.

steved.  

On 06/29/2011 10:45 AM, Steve Dickson wrote:
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

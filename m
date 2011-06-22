Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6463 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757938Ab1FVWeO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Jun 2011 18:34:14 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p5MMYE62020824
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 22 Jun 2011 18:34:14 -0400
Date: Wed, 22 Jun 2011 18:34:13 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/4] mountd: don't automatically add subexports to kernel
 cache
Message-ID: <20110622223412.GB7395@pad.home.fieldses.org>
References: <1308063492-30103-1-git-send-email-bfields@redhat.com>
 <1308063492-30103-5-git-send-email-bfields@redhat.com>
 <4E026D08.5070309@RedHat.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E026D08.5070309@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Jun 22, 2011 at 06:30:32PM -0400, Steve Dickson wrote:
> Hey Bruce,
> 
> This patch breaks cross mounts... Here is my set up
> 
> /home/fs1 two different file systems:
> 
> Filesystem           1K-blocks      Used Available Use% Mounted on
> /dev/mapper/VolGroup00-HomeDirs
>                       15236080   9439036   5010612  66% /home
> RedHat# df /home/fs1
> Filesystem           1K-blocks      Used Available Use% Mounted on
> /dev/mapper/VolGroup00-FS1
>                       10321208    154468   9642452   2% /home/fs1
> 
> The export is:
>   /home *(rw,crossmnt,nohide,sec=sys:krb5:krb5i:krb5p)
> 
> when I mount from a f15 client
>     mount -v -o v3 redhat:/home/fs1/tmp/tophat /mnt/tmp
> I get:
>     mount.nfs: mount(2): Stale NFS file handle
> 
> When I revert the patch, the mount works.

Oh, crap, I didn't check v3.  And, OK, it makes sense that v3 might need
this.

> Unfortunately I'm going to be taking the next few days off
> so I am not going be able to debug this... So I'm going to 
> wait on the entire patch series until we can sort this out...

No problem.  But if you want to apply the rest of the series and drop
just this one patch, that would be fine too.  (That's probably what will
end up being the fix anyway.)

--b.

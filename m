From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Is order for "exportfs -r" and rpc.mountd important?
Date: Thu, 04 Dec 2008 08:59:31 -0500
Message-ID: <4937E243.1080608@RedHat.com>
References: <200811281541.39272.t.bubeck@reinform.de> <200811281705.45087.t.bubeck@reinform.de> <20081203172518.GD16846@fieldses.org> <200812041025.02563.t.bubeck@reinform.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: "Dr. Tilmann Bubeck" <t.bubeck-dx1aEnP5Zukb1SvskN2V4Q@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:54179 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751148AbYLDOBp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Dec 2008 09:01:45 -0500
In-Reply-To: <200812041025.02563.t.bubeck-dx1aEnP5Zukb1SvskN2V4Q@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Dr. Tilmann Bubeck wrote:
> Sorry for the confusion. Maybe I can make myself clearer this time:
> 
> Fedora 10 uses the following simplified /etc/init.d/nfs to start the NFS 
> server:
> 
>   1. exportfs -r
>   2. modprobe nfsd
>      This also does (see modprobe.conf.dist): mount -t nfsd nfsd /proc/fs/nfsd
> 
> As you can read in "man exportfs" there are two modes: "legacy" and "new"
> depending on the existance of /proc/fs/nfsd. The above version of
> /etc/init.d/nfs executes exportfs in lecacy mode and therefore feeds
> /var/lib/nfs/rmtab into the kernel. After "mount -t nfsd ..." the "new" mode 
> is used. In this case the previously fed rmtab is disturbing because we have 
> a mix of "legacy" and "new" mode. This results in the problem that some NFS 
> clients are receiving a "Stale NFS file handle" after a server reboot.
> 
> I tracked the problem down to the kernel based export table which is found 
> in /proc/fs/nfsd/exports. The above start order results in:
> 
> root# cat /proc/fs/nfsd/exports  | grep dhcp-10-1-1-209
> /home   
> dhcp-10-1-1-209.loef.reinform.de(rw,root_squash,sync,wdelay,no_subtree_check,fsid=1510)
> 
> which results from "exportfs -r" reading rmtab and feeding into the kernel.
> 
> By changing the start order to:
> 
>   1. modprobe nfsd
>      This also does (see modprobe.conf.dist): mount -t nfsd nfsd /proc/fs/nfsd
>   2. exportfs -r
> 
> then "exportfs -r" starts in "new" mode and does not feed the rmtab into the 
> kernel. 
This has been fixed in both Fedora 9 and 10... The update nfs-utils version
should be hitting a yum repository near you soon... 

steved.

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e9.ny.us.ibm.com ([32.97.182.139]:40934 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756589Ab2BCObR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 3 Feb 2012 09:31:17 -0500
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Fri, 3 Feb 2012 09:31:15 -0500
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id ADDDA6E805D
	for <linux-nfs@vger.kernel.org>; Fri,  3 Feb 2012 09:31:04 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q13ETmlj247804
	for <linux-nfs@vger.kernel.org>; Fri, 3 Feb 2012 09:29:48 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q13ETlfd008469
	for <linux-nfs@vger.kernel.org>; Fri, 3 Feb 2012 09:29:48 -0500
Date: Fri, 3 Feb 2012 08:29:45 -0600
From: Malahal Naineni <malahal@us.ibm.com>
To: NeilBrown <neilb@suse.de>
Cc: Boaz Harrosh <bharrosh@panasas.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Check for beginning '/' in the mount path
Message-ID: <20120203142945.GA31805@us.ibm.com>
References: <1328233332-26020-1-git-send-email-malahal@us.ibm.com>
 <4F2BC1C0.8070900@panasas.com>
 <20120203231623.442fefde@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120203231623.442fefde@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NeilBrown [neilb@suse.de] wrote:
> On Fri, 3 Feb 2012 13:15:12 +0200 Boaz Harrosh <bharrosh@panasas.com> wrote:
> 
> > On 02/03/2012 03:42 AM, Malahal Naineni wrote:
> > > NFSv4 gladly accepts and mounts "hostname:path" instead of
> > > "hostname:/path". This causes mount entry mistmatch between /etc/mtab
> > > and /proc/mounts files. The former will have "hostname:path" but the
> > > latter will have "hostname:/path". This causes umount not work at all.
> > > 
> > 
> > NACK
> > 
> > like it or not you are changing ABI. Bunch of systems will not work now.
> > 
> > Also some other NFS servers/clients support it fine. Actually some servers
> > make it a special case. (It's called mount by tag)
> > 
> > The bug is else where fix it there. Either add the preceding '/' to
> > /etc/mtab or remove it from /proc/mounts (I prefer the later). Or
>                                             ^^^^^^^^^^^^^^^^^^
> > fix umount to work with that case.
> 
> Agreed.  And while we are at it we should remove the trailing '/' too.
> If you
>   mount host:/path /somewhere
> /proc/mounts will show
>     host:/path/
> 
> which also confused mount.

Thank you Neil and Boaz. Since there is already a fix in umount to take
care of trailing slash, I will post a patch to take care of leading
slash.

Any reason(s) why trailing slash is fixed in umount rather than in
/proc/mounts?

Thanks, Malahal.


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e31.co.us.ibm.com ([32.97.110.149]:60287 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751519Ab2CBVwX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Mar 2012 16:52:23 -0500
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Fri, 2 Mar 2012 14:52:18 -0700
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id DA648C90050
	for <linux-nfs@vger.kernel.org>; Fri,  2 Mar 2012 16:51:27 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q22Lor9F434756
	for <linux-nfs@vger.kernel.org>; Fri, 2 Mar 2012 16:50:54 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q22LorTj004395
	for <linux-nfs@vger.kernel.org>; Fri, 2 Mar 2012 16:50:53 -0500
Received: from malahal (malahal.austin.ibm.com [9.53.40.203])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id q22LorVu004381
	for <linux-nfs@vger.kernel.org>; Fri, 2 Mar 2012 16:50:53 -0500
Date: Fri, 2 Mar 2012 15:50:52 -0600
From: Malahal Naineni <malahal@us.ibm.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] mount.nfs: strip of extra slashes in device name
Message-ID: <20120302215052.GA17475@us.ibm.com>
References: <1330707221-4005-1-git-send-email-steved@redhat.com>
 <20120302184556.GA6880@us.ibm.com>
 <4F511C95.2040806@RedHat.com>
 <20120302194655.GB28389@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120302194655.GB28389@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Malahal Naineni [malahal@us.ibm.com] wrote:
> > as well... What kernel are you using?
> 
> Using 3.3.0-rc1+ kernel.
> [root@elm3c105 ~]# grep mnt /proc/mounts 
> elm3c104:///server/ /mnt nfs rw,relatime,vers=3,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=9.47.69.104,mountvers=3,mountport=929,mountproto=udp,local_lock=none,addr=9.47.69.104 0 0
> 
> I must be missing something, I see the same thing in RHEL6.2 version of
> Linux.

I rebooted my server with an older distro and you can see above that it
is mounting NFSv3. Sorry, my bad. Kernel does strip extra leading '/'s
when I mount NFSv4.

Regards, Malahal.


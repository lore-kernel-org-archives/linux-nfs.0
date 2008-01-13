From: Mark Hobley <markhobley-/E1597aS9LT10XsdtD+oqA@public.gmane.org>
Subject: Error inserting lockd: Cannot allocate memory
Date: Sun, 13 Jan 2008 15:20:41 +0000 (GMT)
Message-ID: <418336.76056.qm@web26513.mail.ukl.yahoo.com>
Reply-To: markhobley-ktR7oAotx3zQT0dZR+AlfA@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
To: linux-nfs@vger.kernel.org, okir-pn4DOG8n3UYbFoVRYvo4fw@public.gmane.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from web26513.mail.ukl.yahoo.com ([217.146.177.60]:25620 "HELO
	web26513.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751514AbYAMP1Y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 13 Jan 2008 10:27:24 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello All.

I am getting an error "Cannot allocate memory" when
trying to load the lockd module into a 2.6.22.9
vanilla kernel as follows:

 modprobe lockd
 Error inserting lockd
(/lib/modules/2.6.22.9/kernel/fs/lockd/lockd.ko):
 Cannot allocate memory

The top utility reveals:

 Mem   387268k total   15524k used   371744k free
 Swap 2706912k total       0k used  2706912k free

The modinfo utility reveals the following information
about lockd:

filename:   
/lib/modules/2.6.22.9/kernel/fs/lockd/lockd.ko
license:        GPL
description:    NFS file locking service version 0.5.
author:         Olaf Kirch <okir-pn4DOG8n3UYbFoVRYvo4fw@public.gmane.org>
depends:        sunrpc
vermagic:       2.6.22.9 preempt mod_unload 586
parm:           nsm_use_hostnames:bool

Should I be taking any special actions or passing a
parameter to load the module? (I have no experience of
this.)

What is the parm: nsm_use_hostnames:bool line?

I notice that my older (working) systems have no such
entry relating to lockd.

The distribution affected by this problem is Gentoo.
The kernel and modules were built at the same time,
and I have no old modules on the system, since this is
a first time build. Other modules load fine, with the
exception of nfs and nfsd, which have dependencies on
this lockd module.

The systems with no entry relating to lockd are Debian
based.

My version of the kernel is about two months old, and
I know there have been updates, since then. Would a
kernel update fix this problem?

Thanks in advance to anyone who can help me.

Mark.



      __________________________________________________________
Sent from Yahoo! Mail - a smarter inbox http://uk.mail.yahoo.com


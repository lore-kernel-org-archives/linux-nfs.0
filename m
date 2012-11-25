Return-Path: linux-nfs-owner@vger.kernel.org
Received: from nm39-vm3.bullet.mail.sg3.yahoo.com ([106.10.151.174]:35706 "EHLO
	nm39-vm3.bullet.mail.sg3.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752285Ab2KYEMk convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 24 Nov 2012 23:12:40 -0500
References: <1353479256.92520.YahooMailNeo@web190605.mail.sg3.yahoo.com> <1353481809.32623.YahooMailNeo@web190605.mail.sg3.yahoo.com>
Message-ID: <1353816433.24972.YahooMailNeo@web190603.mail.sg3.yahoo.com>
Date: Sun, 25 Nov 2012 12:07:13 +0800 (SGT)
From: Kks Kbase <kks.kbase@yahoo.in>
Reply-To: Kks Kbase <kks.kbase@yahoo.in>
Subject: Re: NFS exportfs options
To: Linux NFS <linux-nfs@vger.kernel.org>
In-Reply-To: <1353481809.32623.YahooMailNeo@web190605.mail.sg3.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

Here is the mounted option on /var/lib/nfs/etab

# cat /var/lib/nfs/etab
/home/nfstest1  *(rw,sync,wdelay,hide,nocrossmnt,secure,root_squash,no_all_squash,no_subtree_check,secure_locks,no_acl,mapping=identity,anonuid=65534,anongid=65534)






----- Original Message -----
From: Kks Kbase <kks.kbase@yahoo.in>
To: Linux NFS <linux-nfs@vger.kernel.org>
Cc: 
Sent: Wednesday, 21 November 2012 12:40 PM
Subject: NFS exportfs options



Hi,

Today I have tried to setup the NFS share. 


Here is the exportsfs on NFS server

/home/nfstest1   *(rw)

Then I have mounted the nfs share folder and tried to create folders and files. But I am always getting the error as permission denied either root or normal user.

Any ideas please?


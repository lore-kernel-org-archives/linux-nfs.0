Return-Path: linux-nfs-owner@vger.kernel.org
Received: from nm3.bullet.mail.sg3.yahoo.com ([106.10.148.82]:37554 "EHLO
	nm3.bullet.mail.sg3.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751775Ab2KUHKN convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Nov 2012 02:10:13 -0500
References: <1353479256.92520.YahooMailNeo@web190605.mail.sg3.yahoo.com>
Message-ID: <1353481809.32623.YahooMailNeo@web190605.mail.sg3.yahoo.com>
Date: Wed, 21 Nov 2012 15:10:09 +0800 (SGT)
From: Kks Kbase <kks.kbase@yahoo.in>
Reply-To: Kks Kbase <kks.kbase@yahoo.in>
Subject: NFS exportfs options
To: Linux NFS <linux-nfs@vger.kernel.org>
In-Reply-To: <1353479256.92520.YahooMailNeo@web190605.mail.sg3.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Hi,

Today I have tried to setup the NFS share. 


Here is the exportsfs on NFS server

/home/nfstest1   *(rw)

Then I have mounted the nfs share folder and tried to create folders and files. But I am always getting the error as permission denied either root or normal user.

Any ideas please?

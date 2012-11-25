Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38816 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752712Ab2KYOsR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 25 Nov 2012 09:48:17 -0500
Date: Sun, 25 Nov 2012 09:48:16 -0500
To: Kks Kbase <kks.kbase@yahoo.in>
Cc: Linux NFS <linux-nfs@vger.kernel.org>
Subject: Re: NFS exportfs options
Message-ID: <20121125144816.GA31110@fieldses.org>
References: <1353479256.92520.YahooMailNeo@web190605.mail.sg3.yahoo.com>
 <1353481809.32623.YahooMailNeo@web190605.mail.sg3.yahoo.com>
 <1353816433.24972.YahooMailNeo@web190603.mail.sg3.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <1353816433.24972.YahooMailNeo@web190603.mail.sg3.yahoo.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Nov 25, 2012 at 12:07:13PM +0800, Kks Kbase wrote:
> Hi,
> 
> Here is the mounted option on /var/lib/nfs/etab
> 
> # cat /var/lib/nfs/etab
> /home/nfstest1  *(rw,sync,wdelay,hide,nocrossmnt,secure,root_squash,no_all_squash,no_subtree_check,secure_locks,no_acl,mapping=identity,anonuid=65534,anongid=65534)
> 
> 
> 
> 
> 
> 
> ----- Original Message -----
> From: Kks Kbase <kks.kbase@yahoo.in>
> To: Linux NFS <linux-nfs@vger.kernel.org>
> Cc: 
> Sent: Wednesday, 21 November 2012 12:40 PM
> Subject: NFS exportfs options
> 
> 
> 
> Hi,
> 
> Today I have tried to setup the NFS share. 
> 
> 
> Here is the exportsfs on NFS server
> 
> /home/nfstest1   *(rw)
> 
> Then I have mounted the nfs share folder and tried to create folders and files. But I am always getting the error as permission denied either root or normal user.
> 
> Any ideas please?

How are you mounting this on the client?

Have you checked permissions on the exported directory?  (ls -ld
/home/nfstest1).

--b.

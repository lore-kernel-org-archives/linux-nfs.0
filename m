Return-Path: linux-nfs-owner@vger.kernel.org
Received: from nm28-vm1.bullet.mail.sg3.yahoo.com ([106.10.151.144]:35717 "EHLO
	nm28-vm1.bullet.mail.sg3.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755614Ab2K0CSR convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Nov 2012 21:18:17 -0500
References: <1353479256.92520.YahooMailNeo@web190605.mail.sg3.yahoo.com> <1353481809.32623.YahooMailNeo@web190605.mail.sg3.yahoo.com> <1353816433.24972.YahooMailNeo@web190603.mail.sg3.yahoo.com> <20121125144816.GA31110@fieldses.org>
Message-ID: <1353982692.94013.YahooMailNeo@web190603.mail.sg3.yahoo.com>
Date: Tue, 27 Nov 2012 10:18:12 +0800 (SGT)
From: Kks Kbase <kks.kbase@yahoo.in>
Reply-To: Kks Kbase <kks.kbase@yahoo.in>
Subject: Re: NFS exportfs options
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Linux NFS <linux-nfs@vger.kernel.org>
In-Reply-To: <20121125144816.GA31110@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Here is the command that I have used to mount.


mount -f nfs 1.2.3.4:/home/nfstest1 /mnt


# ls -al /mnt/
total 28
drwxr-xr-x  2 root root 4096 Nov 22 01:50 .
drwxr-xr-x 25 root root 4096 Nov 23 20:21 ..
-rw-r--r--  1 root root    0 Nov 22 01:50 1
-rw-r--r--  1 root root    0 Nov 22 01:50 2
-rw-r--r--  1 root root    0 Nov 22 01:50 3
# ls -ld /mnt/
drwxr-xr-x 2 root root 4096 Nov 22 01:50 /mnt/



Here is the output in mount command,

1.2.3.4:/home/nfstest1 on /mnt type nfs (rw,addr=1.2.3.4)




----- Original Message -----
From: J. Bruce Fields <bfields@fieldses.org>
To: Kks Kbase <kks.kbase@yahoo.in>
Cc: Linux NFS <linux-nfs@vger.kernel.org>
Sent: Sunday, 25 November 2012 8:18 PM
Subject: Re: NFS exportfs options

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

Have you checked permissions on the exported directory?  (ls -ld
/home/nfstest1).

--b.


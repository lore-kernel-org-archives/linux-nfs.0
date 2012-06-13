Return-Path: linux-nfs-owner@vger.kernel.org
Received: from nm16-vm0.bullet.mail.sp2.yahoo.com ([98.139.91.210]:40917 "HELO
	nm16-vm0.bullet.mail.sp2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751353Ab2FME6f convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Jun 2012 00:58:35 -0400
Message-ID: <1339563514.39008.YahooMailNeo@web111722.mail.gq1.yahoo.com>
Date: Tue, 12 Jun 2012 21:58:34 -0700 (PDT)
From: Mahmood Naderan <nt_mahmood@yahoo.com>
Reply-To: Mahmood Naderan <nt_mahmood@yahoo.com>
Subject: Gave up waiting for root device
To: nfs <linux-nfs@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Dear all
While setting up  a diskless cluster from this guide 

(https://help.ubuntu.com/community/DisklessUbuntuHowto), 
clients end up with this message:

Gave up waiting for root device. Common problems:
- Boot args (cat /proc/cmdline)
– Check rootdelay= (did the system wait long enough?)
– Check root =(did the system wait for right device?)
- Missing modules (cat /proc/modules; ls /dev)
ALERT! /dev/nfs does not exist. Dropping to a shell!!

In that guide /dev/nfs is used twice: 1) in /nfsroot/etc/fstab and 2) 

in /var/lib/tftpboot/pxelinux.cfg/default 


I don't know why it complain... Can somebody help?

 
// Naderan *Mahmood;

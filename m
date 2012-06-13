Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:24866 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754032Ab2FMOFS convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Jun 2012 10:05:18 -0400
Subject: Re: Gave up waiting for root device
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=windows-1252
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1339563514.39008.YahooMailNeo@web111722.mail.gq1.yahoo.com>
Date: Wed, 13 Jun 2012 10:05:14 -0400
Cc: nfs <linux-nfs@vger.kernel.org>
Message-Id: <A5B3B26F-9FD9-4F92-AE1D-157AF7B75A9F@oracle.com>
References: <1339563514.39008.YahooMailNeo@web111722.mail.gq1.yahoo.com>
To: Mahmood Naderan <nt_mahmood@yahoo.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 13, 2012, at 12:58 AM, Mahmood Naderan wrote:

> Dear all
> While setting up  a diskless cluster from this guide 
> 
> (https://help.ubuntu.com/community/DisklessUbuntuHowto), 
> clients end up with this message:
> 
> Gave up waiting for root device. Common problems:
> - Boot args (cat /proc/cmdline)
> – Check rootdelay= (did the system wait long enough?)
> – Check root =(did the system wait for right device?)
> - Missing modules (cat /proc/modules; ls /dev)
> ALERT! /dev/nfs does not exist. Dropping to a shell!!
> 
> In that guide /dev/nfs is used twice: 1) in /nfsroot/etc/fstab and 2) 
> 
> in /var/lib/tftpboot/pxelinux.cfg/default 
> 
> 
> I don't know why it complain... Can somebody help?

To start, search the archives of this mailing list.  There have been a spate of bugs in this area over the past year or so that hit only during certain edge conditions.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com





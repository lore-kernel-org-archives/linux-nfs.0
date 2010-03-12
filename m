Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f176.google.com ([209.85.223.176]:42537 "EHLO
	mail-iw0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934119Ab0CLSXM convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Mar 2010 13:23:12 -0500
Received: by iwn6 with SMTP id 6so1033188iwn.4
        for <linux-nfs@vger.kernel.org>; Fri, 12 Mar 2010 10:23:11 -0800 (PST)
In-Reply-To: <e2c9b7261003111340i4aeff44dye0c5e9928ca13dc6@mail.gmail.com>
References: <e2c9b7261003111340i4aeff44dye0c5e9928ca13dc6@mail.gmail.com>
From: Brandon Simmons <brandon.m.simmons@gmail.com>
Date: Fri, 12 Mar 2010 13:22:51 -0500
Message-ID: <e2c9b7261003121022p40a5c382r3b0ca65e91d02622@mail.gmail.com>
Subject: Very Slow Sequential Reads over NFS from an XFS disk in Amazon EC2
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I am using tiobench to test performance of an NFS mounted volume, and
notice that Sequential Reads are much slower than Random Reads. This
isn't the behavior when I run the same test on the disk mounted
locally.

For random reads I'm getting:

   50 MB/s  over NFS

v.s

   384 MB/s  when mounted locally

This is in comparison to the benchmark for _Random Reads_, in which I get:

   288 MB/s both over NFS _and_ when directly mounted

The other benchmarks seem to be in line with what I would expect, but
I'm fairly new to NFS. Why would sequential reads over NFS be sooo
much slower than random reads over NFS?

I am exporting the volume on the server like this

/export *.internal(no_subtree_check,rw,no_root_squash)

and mounting with this:

mount -o hard,intr,async,noatime,nodiratime,noacl $NFS_SERVER:/export /nfs

Additionally I am doing all this in amazon EC2, exporting an EBS
volume with the XFS file system (redundant, I know).

I have tried using jumbo frames and various other mount options, but
none seem to have much effect.

Thanks for any clues.

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:42506 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753431Ab1AUJII convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Jan 2011 04:08:08 -0500
Received: by gyb11 with SMTP id 11so463522gyb.19
        for <linux-nfs@vger.kernel.org>; Fri, 21 Jan 2011 01:08:07 -0800 (PST)
From: Giuseppe Gargiuolo <giuseppegargiuolo@gmail.com>
Date: Fri, 21 Jan 2011 10:07:47 +0100
Message-ID: <AANLkTinshRCdq_tT=1kYEuByvNZRfYoDoij0m42Oy5Ym@mail.gmail.com>
Subject: Problem with NFSv3 in inode data transfer
To: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

We are working on our personal NFS File System version 3 Extension on
Linux Kernel 2.6.34 and we have a problem.

Our problem is:

We want to add four 28-byte-chars to nfs_fattr struct to make my
client read data in the inode from the server for each file/directory
so encoded and decoded them in fs/nfs/nfs3xdr.c making them work.

Our patch works. We worked on functions encode_fattr3(), decode_fattr(),
and in costants:
nfs3_fattr_sz (21+1+(NFS3_MAXTAGLEN>>2)*4) (located in fs/nfs/nfs3xdr.c),
#define NFS3_POST_OP_ATTR_WORDS         (22+1+(NFS3_MAXTAGLEN>>2)*4)
(located in include/linux/nfs3.h).

where NFS3_MAXTAGLEN is 28 (max number of chars writable in each field).

When trying to list files in our nfs client directory, kernel returns

ls: reading directory . : Input/Output Error

even if from the dmesg log data seem transfering correctly.
Could be a problem over 20 fields?

We appreciate any help.
Thanks in advance,
Best Regards
Nicola Corriero - Giuseppe Gargiuolo
HiXOS Group
University of Bari
Italy

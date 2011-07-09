Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from m13-89.163.com ([220.181.13.89]:48024 "EHLO m13-89.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752450Ab1GIQCY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 9 Jul 2011 12:02:24 -0400
Date: Sat, 9 Jul 2011 23:47:11 +0800 (CST)
From: Janson <haozi_sdu@163.com>
To: linux-nfs@vger.kernel.org
Message-ID: <6b2497dd.90ba.1310f94bd6e.Coremail.haozi_sdu@163.com>
Subject: A problem about pnfs+ext4
Content-Type: text/plain; charset=GBK
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

In the pnfs + ext4 test,we found a problem: when writting a file in pnfs 
we can not read the contents from ext4. After studying we found that 
ext4 extent have a  initialize flag, when pnfs call fallocate, the flag will 
be set to 1, but after pnfs writting data by truncate, the flags can not 
be set to 0. If the flag is 1,ext4 can not read the content.
Now,in ext4 code,The only wan that ext4 set the flag to 0 is DIO. 
Do you know how to solve this problem?


Best regards,
Janson

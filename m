Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from snt0-omc3-s14.snt0.hotmail.com ([65.55.90.153]:55392 "EHLO
	snt0-omc3-s14.snt0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752108Ab1G2P40 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Jul 2011 11:56:26 -0400
Message-ID: <SNT124-W56CFCEE312AD1F54B60803F7370@phx.gbl>
From: Mrbuddy <buddy_sz@hotmail.com>
To: <linux-nfs@vger.kernel.org>
Subject: a BUG in mknod(./node_1077,0100777,0),
Date: Fri, 29 Jul 2011 15:56:26 +0000
Content-Type: text/plain; charset="gb2312"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



HI:
 
When I use mknod(./node_1077,0100777,0), it return a error       errno=2:No such file or directory.
Mode 0100777 means create a common file.so I compared it with touch.
 
I found that when calling nfs4_do_open,in touch the flag is 0x8482,but in mknod,the flag is 0x40.
When calling mknod,the flag come from function nfs_create,

if((nd->flags & LOOKUP_CREATE) !=0)
     open_flags = nd->intent.open.flags;

so i guess can I add a flags at here as below:

if((nd->flags & LOOKUP_CREATE) !=0)
     open_flags = nd->intent.open.flags | O_CREAT | F_WRLCK;

with this change, mknod(./node_1077,0100777,0) return success.
look forward to your reply. 		 	   		  

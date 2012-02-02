Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:60770 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754960Ab2BBJru (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Feb 2012 04:47:50 -0500
Message-ID: <4F2A5BAD.4000609@panasas.com>
Date: Thu, 2 Feb 2012 11:47:25 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: wangjing <wangjing@300.cn>
CC: linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: may i ask a question about nfs fs ? thanks a lot.
References: <201202012212229514260@300.cn> <201202020009007716206@300.cn>
In-Reply-To: <201202020009007716206@300.cn>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/01/2012 06:09 PM, wangjing wrote:
> 
> may i ask a question? thanks a lot.
> 
> the background
>    1、Linux fs has   /nfsmnt/work_pub/web and /nfsmnt/work_inwork/web ，they use NFS V3 mount
>    2、there is many process will read and write files in the dir /nfsmnt/work_pub/web 
>    3、cron will del  all files in dir  /nfsmnt/work_pub/web in period，and will copy all the files which in the dir /nfsmnt/work_inwork/web 
> 
> in some times delete all files in  /nfsmnt/work_pub/web will faild ,because there is some .nfsXXXX
> 
> 
> 
> My question is :can i modify nfs_sillyrename funncion  in the fs/nfs/dir.c , general all .nfsXXX in /tmp,and make kernel ?
> 
> 

You can't do this. /tmp on the client is on a different superblock than the nfs mount, and the point of
sillyrename is that it is a rename and not a move. (i.e same inode)

The /tmp on the server is not even accessible on the client, which does the sillyrename.

You'll have to better your scripts to loop and delete until all  .nfsXXXX go away because
these are temporarily there until the application on the client stops using the file.

Cheers
Boaz

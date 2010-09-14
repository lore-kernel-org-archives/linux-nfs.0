Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:64832 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751774Ab0INOEL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Sep 2010 10:04:11 -0400
Message-ID: <4C8F80DA.4030607@panasas.com>
Date: Tue, 14 Sep 2010 16:04:10 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: DENIEL Philippe <philippe.deniel@cea.fr>
CC: linux-nfs@vger.kernel.org, "Rees, James" <rees@umich.edu>
Subject: Re: Deploying a pNFS / LAYOUT4_BLOCK_VOLUME configuration
References: <4C8F6D39.2070406@cea.fr>
In-Reply-To: <4C8F6D39.2070406@cea.fr>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-09-14 14:40, DENIEL Philippe wrote:
> Hi,
> 
> I'd like to set up from scratch a test bed using pNFS with block devices 
> as I did a few month ago with LAYOUT4_NFSV4_1_FILES.
> My question about the kernel and nfs-utils versions to be used ? Which 
> one are the right ones ? Where could I get it ?

Hi Philippe,

The instructions are documented here:
http://wiki.linux-nfs.org/wiki/index.php/PNFS_Block_Server_Setup_Instructions

The development kernel is the current one, pnfs-all-latest branch.
and the nfs utils are here:
git://linux-nfs.org/~bhalevy/pnfs-nfs-utils.git

You'll now need the user mode daemon: blkmapd
After make and make install, see man (8) blkmapd

Jim, mind taking a look at the wiki page and update it,
in particular anything regarding blkmapd?

Benny

> 
>     Regards
> 
>        Philippe
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

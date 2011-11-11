Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:54706 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757076Ab1KKUJq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Nov 2011 15:09:46 -0500
Message-ID: <4EBD80FE.7070702@panasas.com>
Date: Fri, 11 Nov 2011 12:09:34 -0800
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Benny Halevy <benny@tonian.com>, Fred Isaman <iisaman@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] SQUASHME: pnfsd: Don't call fs_layout_return on a none-file
References: <4EBC5538.7010002@panasas.com> <1320977270.24288.21.camel@lade.trondhjem.org>
In-Reply-To: <1320977270.24288.21.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/10/2011 06:07 PM, Trond Myklebust wrote:
> On Thu, 2011-11-10 at 14:50 -0800, Boaz Harrosh wrote: 
>> So why does the Linux wonderful forgetfull client returnes it's ROC layouts on
>> inode evict() (I hit this on umount at client). Actually this is on me, because
>> it is a bug in Generic client code, but can only manifest with pnf-obj after an
>> IO error.
> 
> Client patches are still welcome...
> 

I'm on it. There is still a pnfs-objects-std-violation that I need to fix
in regards to IO errors and layout-returns. So the above will be a part
of that as well.

Thanks
Boaz

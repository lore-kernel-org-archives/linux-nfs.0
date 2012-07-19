Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:42389 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751868Ab2GSJtf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jul 2012 05:49:35 -0400
Message-ID: <5007D809.2010502@panasas.com>
Date: Thu, 19 Jul 2012 12:48:57 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>,
        Benny Halevy <bhalevy@tonian.com>, Peng Tao <bergwolf@gmail.com>
Subject: Re: [RFC 0/5] CRASHFIX: pnfs-obj: NONE-RPC LD must not call rpc_restart_call_prepare()
References: <4FD1CEA8.3090105@panasas.com> <4FFEDB17.5050001@panasas.com> <1342652848.7323.5.camel@lade.trondhjem.org>
In-Reply-To: <1342652848.7323.5.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07/19/2012 02:07 AM, Myklebust, Trond wrote:

>> NFS41: add pg_layout_private to nfs_pageio_descriptor
> 
> This one is the only patch that really affects the core NFS code, but
> I'm having trouble seeing what is defining hdr->layout_private in this
> patch series, and where it is being used.
> 
> Am I missing some dependencies here?
> 


No! It's all here:
	[patch 5/6] NFS41: add pg_layout_private to nfs_pageio_descriptor

Just adds a single hdr->layout_private member
and:
	[PATCH 6/6] pnfs-obj: Better IO pattern in case of unaligned offset

Uses above member.

In any way I have new versions of these for the merge window I'll send
them tonight.

Thanks
Boaz

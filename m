Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45861 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751557AbcGST6i (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Jul 2016 15:58:38 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "hch@infradead.org" <hch@infradead.org>
Cc: "Trond Myklebust" <trondmy@primarydata.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v4 24/28] Getattr doesn't require data sync semantics
Date: Tue, 19 Jul 2016 16:00:11 -0400
Message-ID: <F879054A-2116-40D5-90C9-473E71977E8A@redhat.com>
In-Reply-To: <20160719035843.GA24437@infradead.org>
References: <1467844205-76852-19-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-20-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-21-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-22-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-23-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-24-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-25-git-send-email-trond.myklebust@primarydata.com>
 <20160718034847.GA1195@infradead.org>
 <A9C18137-87A3-4652-ADD6-E8E1C4BAE27B@primarydata.com>
 <1468817945.5273.2.camel@primarydata.com>
 <20160719035843.GA24437@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 18 Jul 2016, at 23:58, hch@infradead.org wrote:

> On Mon, Jul 18, 2016 at 04:59:09AM +0000, Trond Myklebust wrote:
>> Actually... The problem might be that a previous attribute update is
>> marking the attribute cache as being revalidated. Does the following
>> patch help?
>
> It doesn't.  Also with your most recent linux-next branch the test
> now cause the systems to OOM with or without your patch (with mine 
> it's
> still fine).  I tested with your writeback branch from about two or
> three days ago before, and with that + your patch it also 'just fails'
> and doesn't OOM.  Looks like whatever causes the bug also creates
> a temporarily memory leak when combined with recent changes from your
> tree, most likely something from the pnfs branch.

I couldn't find the memory leak using kmemleak, but it OOMs pretty 
quick.  If I
insert an mdelay(200) just after the lookup_again: marker in
pnfs_update_layout() it doesn't OOM, but it seems stuck forever in a 
loop on
that marker:

[ 1230.635586] pnfs_find_alloc_layout Begin ino=ffff88003ef986f8 
layout=ffff8800392bca58
[ 1230.636729] pnfs_find_lseg:Begin
[ 1230.637538] pnfs_find_lseg:Return lseg           (null) ref 0
[ 1230.638582] --> send_layoutget
[ 1230.639499] --> nfs4_proc_layoutget
[ 1230.640525] --> nfs4_layoutget_prepare
[ 1230.641479] --> nfs41_setup_sequence
[ 1230.641581] <-- nfs4_proc_layoutget status=-512
[ 1230.643288] --> nfs4_alloc_slot used_slots=0000 
highest_used=4294967295 max_slots=31
[ 1230.644348] <-- nfs4_alloc_slot used_slots=0001 highest_used=0 
slotid=0
[ 1230.645373] <-- nfs41_setup_sequence slotid=0 seqid=4376
[ 1230.646356] <-- nfs4_layoutget_prepare
[ 1230.647357] encode_sequence: sessionid=1468956665:2:3:0 seqid=4376 
slotid=0 max_slotid=0 cache_this=0
[ 1230.648522] encode_layoutget: 1st type:0x5 iomode:2 off:122880 
len:4096 mc:4096
[ 1230.650182] decode_layoutget roff:122880 rlen:4096 riomode:2, 
lo_type:0x5, lo.len:48
[ 1230.651331] --> nfs4_layoutget_done
[ 1230.652233] --> nfs4_alloc_slot used_slots=0001 highest_used=0 
max_slots=31
[ 1230.653409] <-- nfs4_alloc_slot used_slots=0003 highest_used=1 
slotid=1
[ 1230.654547] nfs4_free_slot: slotid 1 highest_used_slotid 0
[ 1230.655606] nfs41_sequence_done: Error 0 free the slot
[ 1230.656635] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
[ 1230.657739] <-- nfs4_layoutget_done
[ 1230.658650] --> nfs4_layoutget_release
[ 1230.659626] <-- nfs4_layoutget_release

This debug output is identical for every cycle of the loop. Have to stop 
for the
day.. more tomorrow.

Ben

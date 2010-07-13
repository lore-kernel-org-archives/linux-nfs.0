From: Boaz Harrosh <bharrosh@panasas.com>
Subject: Re: [PATCH 0/2] pnfs-submit Re-initialize pnfs_layout_type when segs
 	list is empty
Date: Tue, 13 Jul 2010 12:02:11 +0300
Message-ID: <4C3C2B93.9050407@panasas.com>
References: <1278693571-3328-1-git-send-email-andros@netapp.com>	<4C3B395F.8080903@panasas.com>	<AANLkTinjab9XPUjRe2knYyRQg8j9pmc9Gdk_fRkGGfY2@mail.gmail.com>	<4C3B4BD3.1090308@panasas.com> <AANLkTilSPhZ1aBtU1taI8UnKQ9CddgaK3oQ1xoSMOuh3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: bhalevy@panasas.com, linux-nfs@vger.kernel.org
To: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:19096 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752714Ab0GMJCO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Jul 2010 05:02:14 -0400
In-Reply-To: <AANLkTilSPhZ1aBtU1taI8UnKQ9CddgaK3oQ1xoSMOuh3-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07/12/2010 09:07 PM, William A. (Andy) Adamson wrote:
> On Mon, Jul 12, 2010 at 1:07 PM, Boaz Harrosh <bharrosh@panasas.com> wrote:
>> >

>> > And is this a layoutdriver specific? It looks like generic business only.
> 
> The file layout driver zero's the stripe unit. I anticipate other
> fields that would need to be zeroed.
> 

The stripe_unit is per segment surly. It should be set on new segment
received. (Again the mix up between layout_type and layout_segment)
If stripe_unit also doubles for a flag that says, I have a layout.
Then zero it on free_lseg, when identified as last.

(Which also means that you are hard coding all-file-layout at heart
 of files-layout-driver)

>>
>> As I said above: on_last_segment/remove-from-client-list can call a specific
>> free_lo_stateid, could be nice for readability.
> 
> It does: I call pnfs_set_layout_stateid() with the zero_stateid. That
> is very clear.
> 
> I just don't see the need for two more states. 

You might miss-understood me. By state I meant: "a point in code where
it is identified that this is first/last segment" This already exists.
I did not mean like an NFS4 state machine.

I wish we had functions that said _on_first_seg, on_last_seg. But
that's just me.

> We have a point in the
> generic code where the layout segment list is empty. Therefore the
> pnfs_layout_type information is stale. Simply initialize and all the
> checks we have work.
> 

That is what I meant that I do not like. The initialize should be on
first_seg_insert, Not "last_seg_remove in case of re-insert". The only
check should be list-is-empty. Then on first insert, all should be initialized.

But I guess it's hard to talk about this. Submit the last fixes and I
can RFC my approach. I hope when you see it you'll be convinced.

Thanks
Boaz

> -->Andy

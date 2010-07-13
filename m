From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Subject: Re: [PATCH 0/2] pnfs-submit Re-initialize pnfs_layout_type when segs
	list is empty
Date: Tue, 13 Jul 2010 10:06:28 -0400
Message-ID: <AANLkTinBNIUOzcqwFffYLgwne1KGoZOiADhjt2IHDIFm@mail.gmail.com>
References: <1278693571-3328-1-git-send-email-andros@netapp.com>
	<4C3B395F.8080903@panasas.com>
	<AANLkTinjab9XPUjRe2knYyRQg8j9pmc9Gdk_fRkGGfY2@mail.gmail.com>
	<4C3B4BD3.1090308@panasas.com>
	<AANLkTilSPhZ1aBtU1taI8UnKQ9CddgaK3oQ1xoSMOuh3@mail.gmail.com>
	<4C3C2B93.9050407@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: bhalevy@panasas.com, linux-nfs@vger.kernel.org
To: Boaz Harrosh <bharrosh@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:62835 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756628Ab0GMOG3 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Jul 2010 10:06:29 -0400
Received: by gyh4 with SMTP id 4so318669gyh.19
        for <linux-nfs@vger.kernel.org>; Tue, 13 Jul 2010 07:06:28 -0700 (PDT)
In-Reply-To: <4C3C2B93.9050407@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 13, 2010 at 5:02 AM, Boaz Harrosh <bharrosh@panasas.com> wr=
ote:
> On 07/12/2010 09:07 PM, William A. (Andy) Adamson wrote:
>> On Mon, Jul 12, 2010 at 1:07 PM, Boaz Harrosh <bharrosh@panasas.com>=
 wrote:
>>> >
>
>>> > And is this a layoutdriver specific? It looks like generic busine=
ss only.
>>
>> The file layout driver zero's the stripe unit. I anticipate other
>> fields that would need to be zeroed.
>>
>
> The stripe_unit is per segment surly. It should be set on new segment
> received. (Again the mix up between layout_type and layout_segment)
> If stripe_unit also doubles for a flag that says, I have a layout.
> Then zero it on free_lseg, when identified as last.


When we only have full file layouts, the only two possible layout
segments are full file segments with different iomodes, and so must
have an equal stripe unit.

I can init on free_lseg - agreed.

>
> (Which also means that you are hard coding all-file-layout at heart
> =A0of files-layout-driver)
>
>>>
>>> As I said above: on_last_segment/remove-from-client-list can call a=
 specific
>>> free_lo_stateid, could be nice for readability.
>>
>> It does: I call pnfs_set_layout_stateid() with the zero_stateid. Tha=
t
>> is very clear.
>>
>> I just don't see the need for two more states.
>
> You might miss-understood me. By state I meant: "a point in code wher=
e
> it is identified that this is first/last segment" This already exists=
=2E
> I did not mean like an NFS4 state machine.
>
> I wish we had functions that said _on_first_seg, on_last_seg. But
> that's just me.
>
>> We have a point in the
>> generic code where the layout segment list is empty. Therefore the
>> pnfs_layout_type information is stale. Simply initialize and all the
>> checks we have work.
>>
>
> That is what I meant that I do not like. The initialize should be on
> first_seg_insert, Not "last_seg_remove in case of re-insert". The onl=
y
> check should be list-is-empty.

No! The layout stateid needs to be zeroed as well.

>Then on first insert, all should be initialized.

I guess we just do things differently. I for one like to clean up the
dishes after the meal, not wait until before the next meal! But that's
just me.

-->Andy

>
> But I guess it's hard to talk about this. Submit the last fixes and I
> can RFC my approach. I hope when you see it you'll be convinced.

OK.

-->Andy

>
> Thanks
> Boaz
>
>> -->Andy
>

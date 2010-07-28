Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:45366 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754764Ab0G1O3b convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Jul 2010 10:29:31 -0400
Received: by bwz1 with SMTP id 1so3983444bwz.19
        for <linux-nfs@vger.kernel.org>; Wed, 28 Jul 2010 07:29:30 -0700 (PDT)
In-Reply-To: <4C503AB5.1090204@panasas.com>
References: <DD09EF29-A704-4F17-B917-C01051355CA3@netapp.com>
	<4C500FFD.4000206@panasas.com>
	<AANLkTikf-9UDhi6_Jg0k8=wV64=JPGVm5T=scQk14xM1@mail.gmail.com>
	<4C503AB5.1090204@panasas.com>
Date: Wed, 28 Jul 2010 10:29:29 -0400
Message-ID: <AANLkTi=QtN2_HcwHefv2KTQeFa+9QTCUEHvBMUw4RrFr@mail.gmail.com>
Subject: Re: pNFS client structure and function rename suggestions
From: Fred Isaman <iisaman@umich.edu>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Andy Adamson <andros@netapp.com>, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Jul 28, 2010 at 10:12 AM, Boaz Harrosh <bharrosh@panasas.com> wrote:
> On 07/28/2010 04:48 PM, Fred Isaman wrote:
>> On Wed, Jul 28, 2010 at 7:09 AM, Boaz Harrosh <bharrosh@panasas.com> wrote:
>>>> struct nfs4_pnfs_layout_segment => pnfs_layout_range
>>>
>>> Isn't this a struct layout4 above?
>>
>> No, this is probably the most confusingly named structure of them all,
>> and one I would strongly urge be changed along the line of Andy's
>> suggestion.
>>
>> Fred
>>
>
> We are like a married couple on a freezing night. Each pulling the blanket
> to his/her side.
>
> I'm trying to pull the blanket to the side. where all these are converted
> to exactly the names and structures as stated by the standard.
> That the Linux-pnfs-workgroup tried to invent their own STD is a misfortune
> which I missed, getting so late into the game.
>
> What side of the Bed are you pulling to?
> I wish you elaborate more, and explain, instead of just saying "NO"
>

All I meant that "no, this is not the struct layout4 above."

There currently exists:

struct nfs4_pnfs_layout_segment {
	u32 iomode;
	u64 offset;
	u64 length;
};

which is used to hold range information, but which is easy to confuse
with struct pnfs_layout_segment.

I REALLY want the name nfs4_pnfs_layout_segment changed.

When possible, I'm all for changing names to coincide with those used
in the spec.  But note that those structures are most useful for XDR
encoding/decoding, and don't always correspond to the information we
need to pass around internally.

Fred


> struct layout_content {
>           layouttype4 loc_type;
>           void      *loc_body;
> };
>
> struct layout {
>           offset4                 lo_offset;
>           length4                 lo_length;
>           layoutiomode4           lo_iomode;
>           layout_content4         lo_content;
> };
>
> struct layoutget_args {
>           /* CURRENT_FH: file */
>           bool                    loga_signal_layout_avail;
>           layouttype4             loga_layout_type;
>           layoutiomode4           loga_iomode;
>           offset4                 loga_offset;
>           length4                 loga_length;
>           length4                 loga_minlength;
>           stateid4                loga_stateid;
>           count4                  loga_maxcount;
> };
>
> struct layoutget_res {
>           bool               logr_return_on_close;
>           stateid4           logr_stateid;
>           layout             logr_layout;
> };
>
> How is the above less useful then the mess we have now?
>
> Boaz
>

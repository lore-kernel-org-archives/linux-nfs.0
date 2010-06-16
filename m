From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Subject: Re: [PATCH 1/1] NFSv4.1 set NFS4_MAX_SLOT_TABLE in
	_nfs41_proc_sequence
Date: Wed, 16 Jun 2010 11:45:05 -0400
Message-ID: <AANLkTinSnJqeX0uC-qzSwzwigNUOrz2DMIxkZH6Z2km4@mail.gmail.com>
References: <1276641089-6867-1-git-send-email-andros@netapp.com>
	<1276695716.5267.8.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: bhalevy@panasas.com, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:37887 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753320Ab0FPPpG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Jun 2010 11:45:06 -0400
Received: by gwj15 with SMTP id 15so4062592gwj.19
        for <linux-nfs@vger.kernel.org>; Wed, 16 Jun 2010 08:45:05 -0700 (PDT)
In-Reply-To: <1276695716.5267.8.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 16, 2010 at 9:41 AM, Trond Myklebust
<trond.myklebust@fys.uio.no> wrote:
> On Tue, 2010-06-15 at 18:31 -0400, andros@netapp.com wrote:
>> From: Andy Adamson <andros@netapp.com>
>>
>> _nfs41_proc_sequence() kmallocs the calldata but does not set
>> calldata->res.slotid to NFS4_MAX_SLOT_TABLE, so nfs41_sequence_prepare() calls
>> nfs41_setup_sequence() with the res.sr_slotid set to a random value.
>> If nfs41_setup_sequence() sees res.sr_slotid as not set to NFS4_MAX_SLOT_TABLE,
>> it returns without actually setting up the sequence.
>
> Looks like a typo in my patch "NFSv41: Fix a memory leak in
> nfs41_proc_async_sequence()". I'll squash your patch into that. Please
> note that you will have to rebase if you try to pull the nfs-for-2.6.36
> branch again.
>
> Now.... With that said, do we really need to allow RPC calls to call
> nfs41_setup_sequence with an initialised slotid?

nfs41_setup_sequence needs to know when a slot has already been
initialized which happens when the error handlers resend.

> This initialisation is
> a serious hassle, and is easy to forget.

Agreed. I'll make it easy to remember by coding an initialization
helper function.

> When do we expect to end up hitting the res.sr_slotid !=
> NFS4_MAX_SLOT_TABLE condition in real life?

What we don't expect in real life is for session->max_req ==
NFS4_MAX_SLOT_TABLE, unless it is not initialized.
A valid slotid is any value between 0 and session->max_req e.g. slotid
!= NFS4_MAX_SLOT_TABLE, so we hit that condition every valid SEQUENCE
op.


-->Andy

>
> Cheers
>  Trond
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

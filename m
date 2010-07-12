From: Yudong Gao <stgyd@umich.edu>
Subject: Re: Implementation of delegation
Date: Mon, 12 Jul 2010 15:19:26 -0700
Message-ID: <AANLkTilKhiHmLdssHLhW4_0bzb15cJnvlAMhjC5akPVi@mail.gmail.com>
References: <AANLkTik1dbBEnyqMEw9snDhjglJiDQJKs4dFdenqXaGJ@mail.gmail.com>
	<1278971292.14605.2.camel@heimdal.trondhjem.org> <AANLkTimjFbkLIs4GIdR_S06bu7PPOV-JUj5uGAMs7IjG@mail.gmail.com>
	<1278972475.14605.9.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:33102 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754357Ab0GLWTr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Jul 2010 18:19:47 -0400
Received: by vws5 with SMTP id 5so4928208vws.19
        for <linux-nfs@vger.kernel.org>; Mon, 12 Jul 2010 15:19:46 -0700 (PDT)
In-Reply-To: <1278972475.14605.9.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I see! Thanks a lot for the pointer!

best,

Yudong

On Mon, Jul 12, 2010 at 3:07 PM, Trond Myklebust
<trond.myklebust@fys.uio.no> wrote:
> On Mon, 2010-07-12 at 15:00 -0700, Yudong Gao wrote:
>> Hi Trond,
>>
>> Thanks for the prompt reply!
>>
>> I find that in _nfs_do_open(), _nfs4_proc_open(), which do the RPC
>> call to the remote server, is always called before
>> nfs4_opendata_to_nfs4_state(), which will further invoke
>> nfs4_try_open_cached().
>>
>> Does this means that whenever is file is opened, the client always
>> need to talk to the server first?
>
> The actual RPC call is skipped if the call to can_open_cached() succeeds
> in nfs4_open_prepare(). In that case, we just grab the sequence, which
> ensures that we remain serialised w.r.t. CLOSE and OPEN_DOWNGRADE calls.
>
> Trond
>
>

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:33052 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751882AbbGVVOB convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jul 2015 17:14:01 -0400
Received: by obdeg2 with SMTP id eg2so46444930obd.0
        for <linux-nfs@vger.kernel.org>; Wed, 22 Jul 2015 14:14:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <0E5E2AA6-6FCF-4A0E-94E3-91A2D529B58B@oracle.com>
References: <1437597373-19455-1-git-send-email-trond.myklebust@primarydata.com>
	<0E5E2AA6-6FCF-4A0E-94E3-91A2D529B58B@oracle.com>
Date: Wed, 22 Jul 2015 17:14:01 -0400
Message-ID: <CAHQdGtSdvM9J2fmHv5z72q0dtWW_LdOL4-9WsabPz6BFFEj=rg@mail.gmail.com>
Subject: Re: [PATCH] SUNRPC: Fix a backchannel deadlock
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 22, 2015 at 4:40 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> Hi Trond-
>
>
> On Jul 22, 2015, at 4:36 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
>
>> xprt_alloc_bc_request() cannot call xprt_free_bc_request() without
>> deadlocking, since it already holds the xprt->bc_pa_lock.
>>
>> Reported-by: Chuck Lever <chuck.lever@oracle.com>
>> Fixes: 0d2a970d0ae55 ("SUNRPC: Fix a backchannel race")
>> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>
> That’s exactly what I did as a basic fix, and I can report that
> it successfully avoids the deadlock.
>
> If xprt_alloc_bc_request() no longer calls xprt_free_bc_request(),
> are the accounting changes introduced by 0d2a970d0ae55 still
> necessary?

The accounting changes are there to fix the race that Christoph
reported in which a valid backchannel request can be rejected by the
RPC layer if it happens to come in after the reply to the previous
request was sent, but before xprt_free_bc_request has completed. I
would therefore expect them still to be needed.

That said, I just noticed that the bc_free_count was being incorrectly
maintained. Should be fixed with v2 of the patch series.

Cheers
  Trond

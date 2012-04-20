Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vx0-f174.google.com ([209.85.220.174]:44988 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751300Ab2DTUwW convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Apr 2012 16:52:22 -0400
Received: by vcqp1 with SMTP id p1so6699982vcq.19
        for <linux-nfs@vger.kernel.org>; Fri, 20 Apr 2012 13:52:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1334951175.3295.17.camel@lade.trondhjem.org>
References: <1334947677-28864-1-git-send-email-iisaman@netapp.com>
	<1334947677-28864-19-git-send-email-iisaman@netapp.com>
	<1334951175.3295.17.camel@lade.trondhjem.org>
Date: Fri, 20 Apr 2012 16:52:22 -0400
Message-ID: <CADnza44DMDySGA5zhpn2QCzSjEmLakWB0-q9C+d-sqx+K8Rq=g@mail.gmail.com>
Subject: Re: [PATCH v3 18/25] NFS: prepare coalesce testing for directio
From: Fred Isaman <faisaman4@gmail.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "Isaman, Fred" <Fred.Isaman@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 20, 2012 at 3:46 PM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
> On Fri, 2012-04-20 at 14:47 -0400, Fred Isaman wrote:
>> The coalesce code made assumptions that will no longer be true once
>> non-page aligned io occurs.  This introduces no change in
>> current behavior, but allows for more general situations to come.
>>
>> Signed-off-by: Fred Isaman <iisaman@netapp.com>
>> ---
>>  fs/nfs/nfs4filelayout.c |   12 ++++++++++++
>>  fs/nfs/pagelist.c       |    2 +-
>>  fs/nfs/pnfs.c           |    8 ++++++++
>>  3 files changed, 21 insertions(+), 1 deletions(-)
>>
>> diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
>> index 5d01a16..b344946 100644
>> --- a/fs/nfs/pagelist.c
>> +++ b/fs/nfs/pagelist.c
>> @@ -280,7 +280,7 @@ static bool nfs_can_coalesce_requests(struct nfs_page *prev,
>>               return false;
>>       if (req->wb_context->state != prev->wb_context->state)
>>               return false;
>> -     if (req->wb_index != (prev->wb_index + 1))
>> +     if (req_offset(req) != req_offset(prev) + prev->wb_bytes)
>
> Can we micro-optimise this just a teensy bit by moving it until after
> the req->wb_base and prev->wb_base tests? Since those are
> computationally simpler, doing them first might make the "can't
> coalesce" test a little faster.
>

Sure.  Do you want a new v4 submission with just that change?

Fred

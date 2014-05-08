Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f181.google.com ([209.85.220.181]:64231 "EHLO
	mail-vc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754447AbaEHTku (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 May 2014 15:40:50 -0400
Received: by mail-vc0-f181.google.com with SMTP id ld13so3357661vcb.26
        for <linux-nfs@vger.kernel.org>; Thu, 08 May 2014 12:40:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140507192534.GD8324@fieldses.org>
References: <1397846704-14567-21-git-send-email-trond.myklebust@primarydata.com>
	<1397846704-14567-22-git-send-email-trond.myklebust@primarydata.com>
	<1397846704-14567-23-git-send-email-trond.myklebust@primarydata.com>
	<1397846704-14567-24-git-send-email-trond.myklebust@primarydata.com>
	<1397846704-14567-25-git-send-email-trond.myklebust@primarydata.com>
	<1397846704-14567-26-git-send-email-trond.myklebust@primarydata.com>
	<1397846704-14567-27-git-send-email-trond.myklebust@primarydata.com>
	<1397846704-14567-28-git-send-email-trond.myklebust@primarydata.com>
	<1397846704-14567-29-git-send-email-trond.myklebust@primarydata.com>
	<1397846704-14567-30-git-send-email-trond.myklebust@primarydata.com>
	<20140507192534.GD8324@fieldses.org>
Date: Thu, 8 May 2014 15:40:49 -0400
Message-ID: <CAHQdGtS1fidn=zbUKqS39EGy-HK2GDxM6Ho_QnsFpo9rEcAuaw@mail.gmail.com>
Subject: Re: [PATCH 29/70] NFSd: Add a struct nfs4_file field to struct nfs4_stid
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 7, 2014 at 3:25 PM, Bruce Fields <bfields@fieldses.org> wrote:
> We're adding a put without adding a corresponding get, so was there a
> leak before this patch?

No. The struct sc_file is added by this patch, and since the entire
stid is zeroed on allocation (through the use of kmem_cache_zalloc),
it is safe to add the put() in this patch.

>
> --b.
>
> On Fri, Apr 18, 2014 at 02:44:23PM -0400, Trond Myklebust wrote:
>> All stateids are associated with a nfs4_file. Let's consolidate...
>>
>> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>> ---
>>  fs/nfsd/nfs4state.c | 2 ++
>>  fs/nfsd/state.h     | 1 +
>>  2 files changed, 3 insertions(+)
>>
>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>> index 32ab3f1c83f8..5bbef4720e7c 100644
>> --- a/fs/nfsd/nfs4state.c
>> +++ b/fs/nfsd/nfs4state.c
>> @@ -474,6 +474,8 @@ static void remove_stid(struct nfs4_stid *s)
>>
>>  static void nfs4_free_stid(struct kmem_cache *slab, struct nfs4_stid *s)
>>  {
>> +     if (s->sc_file)
>> +             put_nfs4_file(s->sc_file);
>>       kmem_cache_free(slab, s);
>>  }
>>
>> diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
>> index 9d0088c244a8..c6deef936693 100644
>> --- a/fs/nfsd/state.h
>> +++ b/fs/nfsd/state.h
>> @@ -85,6 +85,7 @@ struct nfs4_stid {
>>       unsigned char sc_type;
>>       stateid_t sc_stateid;
>>       struct nfs4_client *sc_client;
>> +     struct nfs4_file *sc_file;
>>  };
>>
>>  struct nfs4_delegation {
>> --
>> 1.9.0
>>



-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:36432 "EHLO
	mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750999AbbIGQjW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Sep 2015 12:39:22 -0400
Received: by oibi136 with SMTP id i136so46239275oib.3
        for <linux-nfs@vger.kernel.org>; Mon, 07 Sep 2015 09:39:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1343580857.5999807.1441617528019.JavaMail.zimbra@desy.de>
References: <1441494418-53583-1-git-send-email-trond.myklebust@primarydata.com>
	<1343580857.5999807.1441617528019.JavaMail.zimbra@desy.de>
Date: Mon, 7 Sep 2015 12:39:22 -0400
Message-ID: <CAHQdGtSxJH-1b1YxFKVjMu5BCg1NKZbCGmmKjZjJRLn2w+KN3Q@mail.gmail.com>
Subject: Re: [PATCH 1/2] NFSv4: Express delegation limit in units of pages
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 7, 2015 at 5:18 AM, Mkrtchyan, Tigran
<tigran.mkrtchyan@desy.de> wrote:
>
>
> ----- Original Message -----
>> From: "Trond Myklebust" <trond.myklebust@primarydata.com>
>> To: linux-nfs@vger.kernel.org
>> Sent: Sunday, September 6, 2015 1:06:57 AM
>> Subject: [PATCH 1/2] NFSv4: Express delegation limit in units of pages
>
>> Since we're tracking modifications to the page cache on a per-page
>> basis, it makes sense to express the limit to how much we may cache
>> in units of pages.
>>
>> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>> ---
>> fs/nfs/delegation.c     |  5 +++--
>> fs/nfs/delegation.h     |  2 +-
>> fs/nfs/nfs4xdr.c        | 16 ++++++++++------
>> include/linux/nfs_xdr.h |  2 +-
>> 4 files changed, 15 insertions(+), 10 deletions(-)
>>
>> diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
>> index 029d688a969f..4817f66c8d47 100644
>> --- a/fs/nfs/delegation.c
>> +++ b/fs/nfs/delegation.c
>> @@ -175,7 +175,8 @@ void nfs_inode_reclaim_delegation(struct inode *inode,
>> struct rpc_cred *cred,
>>               if (delegation->inode != NULL) {
>>                       nfs4_stateid_copy(&delegation->stateid, &res->delegation);
>>                       delegation->type = res->delegation_type;
>> -                     delegation->maxsize = res->maxsize;
>> +                     delegation->pagemod_limit = res->pagemod_limit;
>> +                             ;
>
> is this extra line with semicolon intended or a typo?
>

Oops. Definitely a typo. Thanks for spotting...

Cheers
  Trond

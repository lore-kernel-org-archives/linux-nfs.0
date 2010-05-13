From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: SQUASHME: missing from FIXME: async layout return
Date: Thu, 13 May 2010 17:40:56 +0300
Message-ID: <4BEC0F78.5060203@panasas.com>
References: <4BEBBAE9.8090605@panasas.com> <AANLkTind3eXmuPw5HrKqB6bHJSSXFL3g2cDSEyyYc1n8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Boaz Harrosh <bharrosh@panasas.com>,
	NFS list <linux-nfs@vger.kernel.org>
To: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:29645 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753729Ab0EMOk7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 May 2010 10:40:59 -0400
In-Reply-To: <AANLkTind3eXmuPw5HrKqB6bHJSSXFL3g2cDSEyyYc1n8-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May. 13, 2010, 17:19 +0300, "William A. (Andy) Adamson" <androsadamson@gmail.com> wrote:
> On Thu, May 13, 2010 at 4:40 AM, Boaz Harrosh <bharrosh@panasas.com> wrote:
>> I've tested the patch:
>>        FIXME: async layout return
>>
>> And there is a missing small hunk
>>
>> I have tested with this patch and it is a very good patch
>> that should also go into 2.6.33. It is necessary in the rare
>> case when one inode have more then one open_context.
> 
> Do you mean more than one open context per open owner?

What we see is one "regular" open context and one which is the layout_commit_ctx

Benny

> 
> -->Andy
> 
>>
>> (For some reason I see that happening much more in 2.6.34
>>  I don't understand why)
>>
>> Boaz
>> ---
>> git diff --stat -p -M
>>  fs/nfs/nfs4state.c |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
>> index 15c8bc8..6dbe893 100644
>> --- a/fs/nfs/nfs4state.c
>> +++ b/fs/nfs/nfs4state.c
>> @@ -590,7 +590,7 @@ static void __nfs4_close(struct path *path, struct nfs4_state *state, fmode_t fm
>>                struct nfs_inode *nfsi = NFS_I(state->inode);
>>
>>                if (nfsi->layoutcommit_ctx)
>> -                       pnfs_layoutcommit_inode(state->inode, 0);
>> +                       pnfs_layoutcommit_inode(state->inode, wait);
>>                if (has_layout(nfsi) && nfsi->layout.roc_iomode) {
>>                        struct nfs4_pnfs_layout_segment range;
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>

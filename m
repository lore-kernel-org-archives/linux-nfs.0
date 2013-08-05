Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:33968 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753933Ab3HEUuI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Aug 2013 16:50:08 -0400
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfsd: Fix SP4_MACH_CRED negotiation in EXCHANGE_ID
Date: Mon, 5 Aug 2013 20:50:06 +0000
Message-ID: <6BD80745-EA0C-41B9-9C50-9F5FFE06C6C9@netapp.com>
References: <1375732027-4905-1-git-send-email-dros@netapp.com>
 <20130805204200.GE1583@fieldses.org>
In-Reply-To: <20130805204200.GE1583@fieldses.org>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Aug 5, 2013, at 4:42 PM, "J. Bruce Fields" <bfields@fieldses.org>
 wrote:

> On Mon, Aug 05, 2013 at 03:47:07PM -0400, Weston Andros Adamson wrote:
>> - don't BUG_ON() when not SP4_NONE
>> - calculate recv and send reserve sizes correctly
> 
> Looks good, thanks!  (Ouch to that BUG_ON...).
> 
> Could I get the client-side code you're using to test this?
> 
> It's fine if it's a mess, I just want to be able to run it once and see
> a mount work.
> 

I just posted a client side patch to the list alongside this patch - it does the basic SP4_MACH_CRED negotiation and nothing else.

I'll be posting more patches implementing specific SP4_MACH_CRED features shortly, but the already posted patch should work for you.

-dros

> --b.
> 
>> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
>> ---
>> fs/nfsd/nfs4proc.c | 2 +-
>> fs/nfsd/nfs4xdr.c  | 5 ++---
>> 2 files changed, 3 insertions(+), 4 deletions(-)
>> 
>> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
>> index 0d4c410..419572f 100644
>> --- a/fs/nfsd/nfs4proc.c
>> +++ b/fs/nfsd/nfs4proc.c
>> @@ -1524,7 +1524,7 @@ static inline u32 nfsd4_write_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
>> static inline u32 nfsd4_exchange_id_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
>> {
>> 	return (op_encode_hdr_size + 2 + 1 + /* eir_clientid, eir_sequenceid */\
>> -		1 + 1 + 0 + /* eir_flags, spr_how, SP4_NONE (for now) */\
>> +		1 + 1 + 2 + /* eir_flags, spr_how, spo_must_enforce & _allow */\
>> 		2 + /*eir_server_owner.so_minor_id */\
>> 		/* eir_server_owner.so_major_id<> */\
>> 		XDR_QUADLEN(NFS4_OPAQUE_LIMIT) + 1 +\
>> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
>> index 0c0f3ea9..c2a4701 100644
>> --- a/fs/nfsd/nfs4xdr.c
>> +++ b/fs/nfsd/nfs4xdr.c
>> @@ -3360,7 +3360,8 @@ nfsd4_encode_exchange_id(struct nfsd4_compoundres *resp, __be32 nfserr,
>> 		8 /* eir_clientid */ +
>> 		4 /* eir_sequenceid */ +
>> 		4 /* eir_flags */ +
>> -		4 /* spr_how (SP4_NONE) */ +
>> +		4 /* spr_how */ +
>> +		8 /* spo_must_enforce, spo_must_allow */ +
>> 		8 /* so_minor_id */ +
>> 		4 /* so_major_id.len */ +
>> 		(XDR_QUADLEN(major_id_sz) * 4) +
>> @@ -3372,8 +3373,6 @@ nfsd4_encode_exchange_id(struct nfsd4_compoundres *resp, __be32 nfserr,
>> 	WRITE32(exid->seqid);
>> 	WRITE32(exid->flags);
>> 
>> -	/* state_protect4_r. Currently only support SP4_NONE */
>> -	BUG_ON(exid->spa_how != SP4_NONE);
>> 	WRITE32(exid->spa_how);
>> 	switch (exid->spa_how) {
>> 	case SP4_NONE:
>> -- 
>> 1.7.12.4 (Apple Git-37)
>> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


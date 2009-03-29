From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 19/46] nfs41: use nfs4_setaclres
Date: Sun, 29 Mar 2009 20:48:22 +0300
Message-ID: <49CFB466.6070000@panasas.com>
References: <49ADBD04.2090002@panasas.com>	 <1236124518-3488-1-git-send-email-bhalevy@panasas.com> <1238347823.10999.17.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:21163 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751245AbZC2Rsf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 Mar 2009 13:48:35 -0400
In-Reply-To: <1238347823.10999.17.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mar. 29, 2009, 20:30 +0300, Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> On Tue, 2009-03-03 at 16:55 -0700, Benny Halevy wrote:
>> In preparation for nfs41 sequence processing.
>>
>> Signed-off-by: Andy Admason <andros@netapp.com>
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> ---
>>  fs/nfs/nfs4proc.c |    3 ++-
>>  fs/nfs/nfs4xdr.c  |    3 ++-
>>  2 files changed, 4 insertions(+), 2 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index 1a5fa1d..98b2e89 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -2915,10 +2915,11 @@ static int __nfs4_proc_set_acl(struct inode
>> *inode, const void *buf, size_t bufl
>>                 .acl_pages      = pages,
>>                 .acl_len        = buflen,
>>         };
>> +       struct nfs_setaclres res;
> 
> Where is the definition?

It's in "nfs41: client xdr definitions"
I can move it here if it makes it clearer.

Benny

> 
>>         struct rpc_message msg = {
>>                 .rpc_proc       =
>> &nfs4_procedures[NFSPROC4_CLNT_SETACL],
>>                 .rpc_argp       = &arg,
>> -               .rpc_resp       = NULL,
>> +               .rpc_resp       = &res,
>>         };
>>         int ret;
>>
>> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
>> index 13320af..5fb452c 100644
>> --- a/fs/nfs/nfs4xdr.c
>> +++ b/fs/nfs/nfs4xdr.c
>> @@ -3911,7 +3911,8 @@ nfs4_xdr_enc_setacl(struct rpc_rqst *req, __be32
>> *p, struct nfs_setaclargs *args
>>   * Decode SETACL response
>>   */
>>  static int
>> -nfs4_xdr_dec_setacl(struct rpc_rqst *rqstp, __be32 *p, void *res)
>> +nfs4_xdr_dec_setacl(struct rpc_rqst *rqstp, __be32 *p,
>> +                   struct nfs_setaclres *res)
>>  {
>>         struct xdr_stream xdr;
>>         struct compound_hdr hdr;
>> --
>> 1.6.1.3
>>
>>
>>

From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 27/46] NFS: update hdr->replen for every encode op
Date: Sun, 29 Mar 2009 22:25:16 +0300
Message-ID: <49CFCB1C.5010400@panasas.com>
References: <49ADBD04.2090002@panasas.com>	 <1236124713-3736-1-git-send-email-bhalevy@panasas.com> <1238348809.23986.4.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:28775 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752691AbZC2TZ2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 Mar 2009 15:25:28 -0400
In-Reply-To: <1238348809.23986.4.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mar. 29, 2009, 20:46 +0300, Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> On Tue, 2009-03-03 at 16:58 -0700, Benny Halevy wrote:
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> ---
>>  fs/nfs/nfs4xdr.c |   31 +++++++++++++++++++++++++++++++
>>  1 files changed, 31 insertions(+), 0 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
>> index 5d665a1..e6f2d84 100644
>> --- a/fs/nfs/nfs4xdr.c
>> +++ b/fs/nfs/nfs4xdr.c
>> @@ -753,6 +753,7 @@ static void encode_access(struct xdr_stream *xdr,
>> u32 access, struct compound_hd
>>         WRITE32(OP_ACCESS);
>>         WRITE32(access);
>>         hdr->nops++;
>> +       hdr->replen += decode_access_maxsz;
>>  }
>>
>>  static void encode_close(struct xdr_stream *xdr, const struct
>> nfs_closeargs *arg, struct compound_hdr *hdr)
>> @@ -764,6 +765,7 @@ static void encode_close(struct xdr_stream *xdr,
>> const struct nfs_closeargs *arg
>>         WRITE32(arg->seqid->sequence->counter);
>>         WRITEMEM(arg->stateid->data, NFS4_STATEID_SIZE);
>>         hdr->nops++;
>> +       hdr->replen += decode_close_maxsz;
>>  }
>>
>>  static void encode_commit(struct xdr_stream *xdr, const struct
>> nfs_writeargs *args, struct compound_hdr *hdr)
>> @@ -775,6 +777,7 @@ static void encode_commit(struct xdr_stream *xdr,
>> const struct nfs_writeargs *ar
>>         WRITE64(args->offset);
>>         WRITE32(args->count);
>>         hdr->nops++;
>> +       hdr->replen += decode_commit_maxsz;
>>  }
>>
>>  static void encode_create(struct xdr_stream *xdr, const struct
>> nfs4_create_arg *create, struct compound_hdr *hdr)
>> @@ -806,6 +809,7 @@ static void encode_create(struct xdr_stream *xdr,
>> const struct nfs4_create_arg *
>>         WRITE32(create->name->len);
>>         WRITEMEM(create->name->name, create->name->len);
>>         hdr->nops++;
>> +       hdr->replen += decode_create_maxsz;
>>
>>         encode_attrs(xdr, create->attrs, create->server);
>>  }
>> @@ -819,6 +823,7 @@ static void encode_getattr_one(struct xdr_stream
>> *xdr, uint32_t bitmap, struct c
>>         WRITE32(1);
>>         WRITE32(bitmap);
>>         hdr->nops++;
>> +       hdr->replen += decode_getattr_maxsz;
>>  }
>>
>>  static void encode_getattr_two(struct xdr_stream *xdr, uint32_t bm0,
>> uint32_t bm1, struct compound_hdr *hdr)
>> @@ -831,6 +836,7 @@ static void encode_getattr_two(struct xdr_stream
>> *xdr, uint32_t bm0, uint32_t bm
>>         WRITE32(bm0);
>>         WRITE32(bm1);
>>         hdr->nops++;
>> +       hdr->replen += decode_getattr_maxsz;
>>  }
> 
> Hmm... Not always true, as I pointed out w.r.t. fs_locations. Perhaps we
> should add an encode_getfattr() for the generic case, and keep
> fs_locations as special.

sounds good.

Benny

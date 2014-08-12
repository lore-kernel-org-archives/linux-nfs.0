Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35734 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750979AbaHLUkE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Aug 2014 16:40:04 -0400
Date: Tue, 12 Aug 2014 16:40:02 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSD: Convert magic number to sizeof() for encode and
 decode
Message-ID: <20140812204002.GH25914@fieldses.org>
References: <53B8C3D3.7080201@gmail.com>
 <20140707181556.GC8630@fieldses.org>
 <20140710105451.GA23266@infradead.org>
 <20140711201129.GB11931@fieldses.org>
 <20140714095944.GA25481@infradead.org>
 <20140716220629.GH2397@fieldses.org>
 <53C90B23.2080801@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <53C90B23.2080801@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 18, 2014 at 07:55:15PM +0800, Kinglong Mee wrote:
> Reported-by: Christoph Hellwig <hch@lst.de>
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>

Thanks, apologies, by the time I got to this there were conflicts that I
didn't want to sort through.

I'll publish a for-3.18 branch soon after -rc1 is out, and then you
could resend if you like.

--b.

> ---
>  fs/nfsd/nfs4acl.c      |   2 +-
>  fs/nfsd/nfs4callback.c |  18 +-
>  fs/nfsd/nfs4idmap.c    |   4 +-
>  fs/nfsd/nfs4proc.c     |  12 +-
>  fs/nfsd/nfs4state.c    |  10 +-
>  fs/nfsd/nfs4xdr.c      | 500 +++++++++++++++++++++++++------------------------
>  6 files changed, 279 insertions(+), 267 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4acl.c b/fs/nfsd/nfs4acl.c
> index 59fd766..f15dbb2 100644
> --- a/fs/nfsd/nfs4acl.c
> +++ b/fs/nfsd/nfs4acl.c
> @@ -932,7 +932,7 @@ __be32 nfs4_acl_write_who(struct xdr_stream *xdr, int who)
>  	for (i = 0; i < ARRAY_SIZE(s2t_map); i++) {
>  		if (s2t_map[i].type != who)
>  			continue;
> -		p = xdr_reserve_space(xdr, s2t_map[i].stringlen + 4);
> +		p = xdr_reserve_space(xdr, sizeof(__be32) + s2t_map[i].stringlen);
>  		if (!p)
>  			return nfserr_resource;
>  		p = xdr_encode_opaque(p, s2t_map[i].string,
> diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> index a88a93e..6307e29 100644
> --- a/fs/nfsd/nfs4callback.c
> +++ b/fs/nfsd/nfs4callback.c
> @@ -118,7 +118,7 @@ static void encode_nfs_cb_opnum4(struct xdr_stream *xdr, enum nfs_cb_opnum4 op)
>  {
>  	__be32 *p;
>  
> -	p = xdr_reserve_space(xdr, 4);
> +	p = xdr_reserve_space(xdr, sizeof(__be32));
>  	*p = cpu_to_be32(op);
>  }
>  
> @@ -133,7 +133,7 @@ static void encode_nfs_fh4(struct xdr_stream *xdr, const struct knfsd_fh *fh)
>  	__be32 *p;
>  
>  	BUG_ON(length > NFS4_FHSIZE);
> -	p = xdr_reserve_space(xdr, 4 + length);
> +	p = xdr_reserve_space(xdr, sizeof(__be32) + length);
>  	xdr_encode_opaque(p, &fh->fh_base, length);
>  }
>  
> @@ -235,7 +235,7 @@ static int decode_cb_op_status(struct xdr_stream *xdr, enum nfs_opnum4 expected,
>  	__be32 *p;
>  	u32 op;
>  
> -	p = xdr_inline_decode(xdr, 4 + 4);
> +	p = xdr_inline_decode(xdr, 2 * sizeof(__be32));
>  	if (unlikely(p == NULL))
>  		goto out_overflow;
>  	op = be32_to_cpup(p++);
> @@ -267,7 +267,7 @@ static void encode_cb_compound4args(struct xdr_stream *xdr,
>  {
>  	__be32 * p;
>  
> -	p = xdr_reserve_space(xdr, 4 + 4 + 4 + 4);
> +	p = xdr_reserve_space(xdr, 4 * sizeof(__be32));
>  	p = xdr_encode_empty_array(p);		/* empty tag */
>  	*p++ = cpu_to_be32(hdr->minorversion);
>  	*p++ = cpu_to_be32(hdr->ident);
> @@ -300,13 +300,13 @@ static int decode_cb_compound4res(struct xdr_stream *xdr,
>  	u32 length;
>  	__be32 *p;
>  
> -	p = xdr_inline_decode(xdr, 4 + 4);
> +	p = xdr_inline_decode(xdr, 2 * sizeof(__be32));
>  	if (unlikely(p == NULL))
>  		goto out_overflow;
>  	hdr->status = be32_to_cpup(p++);
>  	/* Ignore the tag */
>  	length = be32_to_cpup(p++);
> -	p = xdr_inline_decode(xdr, length + 4);
> +	p = xdr_inline_decode(xdr, sizeof(__be32) + length);
>  	if (unlikely(p == NULL))
>  		goto out_overflow;
>  	hdr->nops = be32_to_cpup(p);
> @@ -334,7 +334,7 @@ static void encode_cb_recall4args(struct xdr_stream *xdr,
>  	encode_nfs_cb_opnum4(xdr, OP_CB_RECALL);
>  	encode_stateid4(xdr, &dp->dl_stid.sc_stateid);
>  
> -	p = xdr_reserve_space(xdr, 4);
> +	p = xdr_reserve_space(xdr, sizeof(__be32));
>  	*p++ = xdr_zero;			/* truncate */
>  
>  	encode_nfs_fh4(xdr, &dp->dl_fh);
> @@ -367,7 +367,7 @@ static void encode_cb_sequence4args(struct xdr_stream *xdr,
>  	encode_nfs_cb_opnum4(xdr, OP_CB_SEQUENCE);
>  	encode_sessionid4(xdr, session);
>  
> -	p = xdr_reserve_space(xdr, 4 + 4 + 4 + 4 + 4);
> +	p = xdr_reserve_space(xdr, 5 * sizeof(__be32));
>  	*p++ = cpu_to_be32(session->se_cb_seq_nr);	/* csa_sequenceid */
>  	*p++ = xdr_zero;			/* csa_slotid */
>  	*p++ = xdr_zero;			/* csa_highest_slotid */
> @@ -413,7 +413,7 @@ static int decode_cb_sequence4resok(struct xdr_stream *xdr,
>  	 * If the server returns different values for sessionID, slotID or
>  	 * sequence number, the server is looney tunes.
>  	 */
> -	p = xdr_inline_decode(xdr, NFS4_MAX_SESSIONID_LEN + 4 + 4 + 4 + 4);
> +	p = xdr_inline_decode(xdr, NFS4_MAX_SESSIONID_LEN + 4 * sizeof(__be32));
>  	if (unlikely(p == NULL))
>  		goto out_overflow;
>  	memcpy(id.data, p, NFS4_MAX_SESSIONID_LEN);
> diff --git a/fs/nfsd/nfs4idmap.c b/fs/nfsd/nfs4idmap.c
> index a0ab0a8..4cfa16e 100644
> --- a/fs/nfsd/nfs4idmap.c
> +++ b/fs/nfsd/nfs4idmap.c
> @@ -558,7 +558,7 @@ static __be32 encode_ascii_id(struct xdr_stream *xdr, u32 id)
>  	__be32 *p;
>  
>  	len = sprintf(buf, "%u", id);
> -	p = xdr_reserve_space(xdr, len + 4);
> +	p = xdr_reserve_space(xdr, sizeof(__be32) + len);
>  	if (!p)
>  		return nfserr_resource;
>  	p = xdr_encode_opaque(p, buf, len);
> @@ -584,7 +584,7 @@ static __be32 idmap_id_to_name(struct xdr_stream *xdr,
>  		return nfserrno(ret);
>  	ret = strlen(item->name);
>  	WARN_ON_ONCE(ret > IDMAP_NAMESZ);
> -	p = xdr_reserve_space(xdr, ret + 4);
> +	p = xdr_reserve_space(xdr, sizeof(__be32) + ret);
>  	if (!p)
>  		return nfserr_resource;
>  	p = xdr_encode_opaque(p, item->name, ret);
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 29a617e..1507c29 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -1280,7 +1280,7 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
>  	svcxdr_init_encode(rqstp, resp);
>  	resp->tagp = resp->xdr.p;
>  	/* reserve space for: taglen, tag, and opcnt */
> -	xdr_reserve_space(&resp->xdr, 8 + args->taglen);
> +	xdr_reserve_space(&resp->xdr, 2 * sizeof(__be32) + args->taglen);
>  	resp->taglen = args->taglen;
>  	resp->tag = args->tag;
>  	resp->rqstp = rqstp;
> @@ -1472,19 +1472,19 @@ static inline u32 nfsd4_getattr_rsize(struct svc_rqst *rqstp,
>  		return svc_max_payload(rqstp);
>  
>  	if (bmap1 & FATTR4_WORD1_OWNER) {
> -		ret += IDMAP_NAMESZ + 4;
> +		ret += IDMAP_NAMESZ + sizeof(__be32);
>  		bmap1 &= ~FATTR4_WORD1_OWNER;
>  	}
>  	if (bmap1 & FATTR4_WORD1_OWNER_GROUP) {
> -		ret += IDMAP_NAMESZ + 4;
> +		ret += IDMAP_NAMESZ + sizeof(__be32);
>  		bmap1 &= ~FATTR4_WORD1_OWNER_GROUP;
>  	}
>  	if (bmap0 & FATTR4_WORD0_FILEHANDLE) {
> -		ret += NFS4_FHSIZE + 4;
> +		ret += NFS4_FHSIZE + sizeof(__be32);
>  		bmap0 &= ~FATTR4_WORD0_FILEHANDLE;
>  	}
>  	if (bmap2 & FATTR4_WORD2_SECURITY_LABEL) {
> -		ret += NFSD4_MAX_SEC_LABEL_LEN + 12;
> +		ret += NFSD4_MAX_SEC_LABEL_LEN + 3 * sizeof(__be32);
>  		bmap2 &= ~FATTR4_WORD2_SECURITY_LABEL;
>  	}
>  	/*
> @@ -1493,7 +1493,7 @@ static inline u32 nfsd4_getattr_rsize(struct svc_rqst *rqstp,
>  	 */
>  	ret += 16 * (hweight32(bmap0) + hweight32(bmap1) + hweight32(bmap2));
>  	/* bitmask, length */
> -	ret += 20;
> +	ret += 5 * sizeof(__be32);
>  	return ret;
>  }
>  
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index fd4deb0..9f52e06 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1070,7 +1070,15 @@ gen_sessionid(struct nfsd4_session *ses)
>   * verifier), 12 for the compound header (with zero-length tag), and 44
>   * for the SEQUENCE op response:
>   */
> -#define NFSD_MIN_HDR_SEQ_SZ  (24 + 12 + 44)
> +#define NFSD_MIN_HDR_SEQ_SZ (/* Xid, Message Type, Reply State, Flavor,
> +			      * Flavor Length, Accept State */ \
> +			     6 * sizeof(__be32) + \
> +			     /* Status, Tag Length, Operation Count */ \
> +			     3 * sizeof(__be32) + \
> +			     /* Operation Code, Status, SessionID, SequenceID,
> +			      * SlotID, Highest SlotID, Target Highest SlotID,
> +			      * Status Flags */ \
> +			     7 * sizeof(__be32) + NFS4_MAX_SESSIONID_LEN)
>  
>  static void
>  free_session_slots(struct nfsd4_session *ses)
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 01023a5..73fd09e 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -251,7 +251,7 @@ nfsd4_decode_bitmap(struct nfsd4_compoundargs *argp, u32 *bmval)
>  	bmval[1] = 0;
>  	bmval[2] = 0;
>  
> -	READ_BUF(4);
> +	READ_BUF(sizeof(__be32));
>  	bmlen = be32_to_cpup(p++);
>  	if (bmlen > 1000)
>  		goto xdr_error;
> @@ -282,12 +282,12 @@ nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval,
>  	if ((status = nfsd4_decode_bitmap(argp, bmval)))
>  		return status;
>  
> -	READ_BUF(4);
> +	READ_BUF(sizeof(__be32));
>  	expected_len = be32_to_cpup(p++);
>  
>  	if (bmval[0] & FATTR4_WORD0_SIZE) {
> -		READ_BUF(8);
> -		len += 8;
> +		READ_BUF(sizeof(__be64));
> +		len += sizeof(__be64);
>  		p = xdr_decode_hyper(p, &iattr->ia_size);
>  		iattr->ia_valid |= ATTR_SIZE;
>  	}
> @@ -295,7 +295,8 @@ nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval,
>  		u32 nace;
>  		struct nfs4_ace *ace;
>  
> -		READ_BUF(4); len += 4;
> +		READ_BUF(sizeof(__be32));
> +		len += sizeof(__be32);
>  		nace = be32_to_cpup(p++);
>  
>  		if (nace > NFS4_ACL_MAX)
> @@ -307,7 +308,8 @@ nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval,
>  
>  		(*acl)->naces = nace;
>  		for (ace = (*acl)->aces; ace < (*acl)->aces + nace; ace++) {
> -			READ_BUF(16); len += 16;
> +			READ_BUF(4 * sizeof(__be32));
> +			len += 4 * sizeof(__be32);
>  			ace->type = be32_to_cpup(p++);
>  			ace->flag = be32_to_cpup(p++);
>  			ace->access_mask = be32_to_cpup(p++);
> @@ -331,15 +333,15 @@ nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval,
>  	} else
>  		*acl = NULL;
>  	if (bmval[1] & FATTR4_WORD1_MODE) {
> -		READ_BUF(4);
> -		len += 4;
> +		READ_BUF(sizeof(__be32));
> +		len += sizeof(__be32);
>  		iattr->ia_mode = be32_to_cpup(p++);
>  		iattr->ia_mode &= (S_IFMT | S_IALLUGO);
>  		iattr->ia_valid |= ATTR_MODE;
>  	}
>  	if (bmval[1] & FATTR4_WORD1_OWNER) {
> -		READ_BUF(4);
> -		len += 4;
> +		READ_BUF(sizeof(__be32));
> +		len += sizeof(__be32);
>  		dummy32 = be32_to_cpup(p++);
>  		READ_BUF(dummy32);
>  		len += (XDR_QUADLEN(dummy32) << 2);
> @@ -349,8 +351,8 @@ nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval,
>  		iattr->ia_valid |= ATTR_UID;
>  	}
>  	if (bmval[1] & FATTR4_WORD1_OWNER_GROUP) {
> -		READ_BUF(4);
> -		len += 4;
> +		READ_BUF(sizeof(__be32));
> +		len += sizeof(__be32);
>  		dummy32 = be32_to_cpup(p++);
>  		READ_BUF(dummy32);
>  		len += (XDR_QUADLEN(dummy32) << 2);
> @@ -360,15 +362,15 @@ nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval,
>  		iattr->ia_valid |= ATTR_GID;
>  	}
>  	if (bmval[1] & FATTR4_WORD1_TIME_ACCESS_SET) {
> -		READ_BUF(4);
> -		len += 4;
> +		READ_BUF(sizeof(__be32));
> +		len += sizeof(__be32);
>  		dummy32 = be32_to_cpup(p++);
>  		switch (dummy32) {
>  		case NFS4_SET_TO_CLIENT_TIME:
>  			/* We require the high 32 bits of 'seconds' to be 0, and we ignore
>  			   all 32 bits of 'nseconds'. */
> -			READ_BUF(12);
> -			len += 12;
> +			READ_BUF(sizeof(__be32) + sizeof(__be64));
> +			len += sizeof(__be32) + sizeof(__be64);
>  			p = xdr_decode_hyper(p, &sec);
>  			iattr->ia_atime.tv_sec = (time_t)sec;
>  			iattr->ia_atime.tv_nsec = be32_to_cpup(p++);
> @@ -384,15 +386,15 @@ nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval,
>  		}
>  	}
>  	if (bmval[1] & FATTR4_WORD1_TIME_MODIFY_SET) {
> -		READ_BUF(4);
> -		len += 4;
> +		READ_BUF(sizeof(__be32));
> +		len += sizeof(__be32);
>  		dummy32 = be32_to_cpup(p++);
>  		switch (dummy32) {
>  		case NFS4_SET_TO_CLIENT_TIME:
>  			/* We require the high 32 bits of 'seconds' to be 0, and we ignore
>  			   all 32 bits of 'nseconds'. */
> -			READ_BUF(12);
> -			len += 12;
> +			READ_BUF(sizeof(__be32) + sizeof(__be64));
> +			len += sizeof(__be32) + sizeof(__be64);
>  			p = xdr_decode_hyper(p, &sec);
>  			iattr->ia_mtime.tv_sec = sec;
>  			iattr->ia_mtime.tv_nsec = be32_to_cpup(p++);
> @@ -411,14 +413,10 @@ nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval,
>  	label->len = 0;
>  #ifdef CONFIG_NFSD_V4_SECURITY_LABEL
>  	if (bmval[2] & FATTR4_WORD2_SECURITY_LABEL) {
> -		READ_BUF(4);
> -		len += 4;
> +		READ_BUF(3 * sizeof(__be32));
> +		len += 3 * sizeof(__be32);
>  		dummy32 = be32_to_cpup(p++); /* lfs: we don't use it */
> -		READ_BUF(4);
> -		len += 4;
>  		dummy32 = be32_to_cpup(p++); /* pi: we don't use it either */
> -		READ_BUF(4);
> -		len += 4;
>  		dummy32 = be32_to_cpup(p++);
>  		READ_BUF(dummy32);
>  		if (dummy32 > NFSD4_MAX_SEC_LABEL_LEN)
> @@ -459,7 +457,7 @@ nfsd4_decode_access(struct nfsd4_compoundargs *argp, struct nfsd4_access *access
>  {
>  	DECODE_HEAD;
>  
> -	READ_BUF(4);
> +	READ_BUF(sizeof(__be32));
>  	access->ac_req_access = be32_to_cpup(p++);
>  
>  	DECODE_TAIL;
> @@ -474,7 +472,7 @@ static __be32 nfsd4_decode_cb_sec(struct nfsd4_compoundargs *argp, struct nfsd4_
>  	int nr_secflavs;
>  
>  	/* callback_sec_params4 */
> -	READ_BUF(4);
> +	READ_BUF(sizeof(__be32));
>  	nr_secflavs = be32_to_cpup(p++);
>  	if (nr_secflavs)
>  		cbs->flavor = (u32)(-1);
> @@ -482,7 +480,7 @@ static __be32 nfsd4_decode_cb_sec(struct nfsd4_compoundargs *argp, struct nfsd4_
>  		/* Is this legal? Be generous, take it to mean AUTH_NONE: */
>  		cbs->flavor = 0;
>  	for (i = 0; i < nr_secflavs; ++i) {
> -		READ_BUF(4);
> +		READ_BUF(sizeof(__be32));
>  		dummy = be32_to_cpup(p++);
>  		switch (dummy) {
>  		case RPC_AUTH_NULL:
> @@ -491,7 +489,7 @@ static __be32 nfsd4_decode_cb_sec(struct nfsd4_compoundargs *argp, struct nfsd4_
>  				cbs->flavor = RPC_AUTH_NULL;
>  			break;
>  		case RPC_AUTH_UNIX:
> -			READ_BUF(8);
> +			READ_BUF(2 * sizeof(__be32));
>  			/* stamp */
>  			dummy = be32_to_cpup(p++);
>  
> @@ -501,14 +499,14 @@ static __be32 nfsd4_decode_cb_sec(struct nfsd4_compoundargs *argp, struct nfsd4_
>  			SAVEMEM(machine_name, dummy);
>  
>  			/* uid, gid */
> -			READ_BUF(8);
> +			READ_BUF(2 * sizeof(__be32));
>  			uid = be32_to_cpup(p++);
>  			gid = be32_to_cpup(p++);
>  
>  			/* more gids */
> -			READ_BUF(4);
> +			READ_BUF(sizeof(__be32));
>  			dummy = be32_to_cpup(p++);
> -			READ_BUF(dummy * 4);
> +			READ_BUF(dummy * sizeof(__be32));
>  			if (cbs->flavor == (u32)(-1)) {
>  				kuid_t kuid = make_kuid(&init_user_ns, uid);
>  				kgid_t kgid = make_kgid(&init_user_ns, gid);
> @@ -525,7 +523,7 @@ static __be32 nfsd4_decode_cb_sec(struct nfsd4_compoundargs *argp, struct nfsd4_
>  		case RPC_AUTH_GSS:
>  			dprintk("RPC_AUTH_GSS callback secflavor "
>  				"not supported!\n");
> -			READ_BUF(8);
> +			READ_BUF(2 * sizeof(__be32));
>  			/* gcbp_service */
>  			dummy = be32_to_cpup(p++);
>  			/* gcbp_handle_from_server */
> @@ -533,7 +531,7 @@ static __be32 nfsd4_decode_cb_sec(struct nfsd4_compoundargs *argp, struct nfsd4_
>  			READ_BUF(dummy);
>  			p += XDR_QUADLEN(dummy);
>  			/* gcbp_handle_from_client */
> -			READ_BUF(4);
> +			READ_BUF(sizeof(__be32));
>  			dummy = be32_to_cpup(p++);
>  			READ_BUF(dummy);
>  			break;
> @@ -549,7 +547,7 @@ static __be32 nfsd4_decode_backchannel_ctl(struct nfsd4_compoundargs *argp, stru
>  {
>  	DECODE_HEAD;
>  
> -	READ_BUF(4);
> +	READ_BUF(sizeof(__be32));
>  	bc->bc_cb_program = be32_to_cpup(p++);
>  	nfsd4_decode_cb_sec(argp, &bc->bc_cb_sec);
>  
> @@ -560,7 +558,7 @@ static __be32 nfsd4_decode_bind_conn_to_session(struct nfsd4_compoundargs *argp,
>  {
>  	DECODE_HEAD;
>  
> -	READ_BUF(NFS4_MAX_SESSIONID_LEN + 8);
> +	READ_BUF(NFS4_MAX_SESSIONID_LEN + 2 * sizeof(__be32));
>  	COPYMEM(bcts->sessionid.data, NFS4_MAX_SESSIONID_LEN);
>  	bcts->dir = be32_to_cpup(p++);
>  	/* XXX: skipping ctsa_use_conn_in_rdma_mode.  Perhaps Tom Tucker
> @@ -573,7 +571,7 @@ nfsd4_decode_close(struct nfsd4_compoundargs *argp, struct nfsd4_close *close)
>  {
>  	DECODE_HEAD;
>  
> -	READ_BUF(4);
> +	READ_BUF(sizeof(__be32));
>  	close->cl_seqid = be32_to_cpup(p++);
>  	return nfsd4_decode_stateid(argp, &close->cl_stateid);
>  
> @@ -586,7 +584,7 @@ nfsd4_decode_commit(struct nfsd4_compoundargs *argp, struct nfsd4_commit *commit
>  {
>  	DECODE_HEAD;
>  
> -	READ_BUF(12);
> +	READ_BUF(sizeof(__be32) + sizeof(__be64));
>  	p = xdr_decode_hyper(p, &commit->co_offset);
>  	commit->co_count = be32_to_cpup(p++);
>  
> @@ -598,11 +596,11 @@ nfsd4_decode_create(struct nfsd4_compoundargs *argp, struct nfsd4_create *create
>  {
>  	DECODE_HEAD;
>  
> -	READ_BUF(4);
> +	READ_BUF(sizeof(__be32));
>  	create->cr_type = be32_to_cpup(p++);
>  	switch (create->cr_type) {
>  	case NF4LNK:
> -		READ_BUF(4);
> +		READ_BUF(sizeof(__be32));
>  		create->cr_datalen = be32_to_cpup(p++);
>  		READ_BUF(create->cr_datalen);
>  		create->cr_data = svcxdr_dupstr(argp, p, create->cr_datalen);
> @@ -611,7 +609,7 @@ nfsd4_decode_create(struct nfsd4_compoundargs *argp, struct nfsd4_create *create
>  		break;
>  	case NF4BLK:
>  	case NF4CHR:
> -		READ_BUF(8);
> +		READ_BUF(2 * sizeof(__be32));
>  		create->cr_specdata1 = be32_to_cpup(p++);
>  		create->cr_specdata2 = be32_to_cpup(p++);
>  		break;
> @@ -622,7 +620,7 @@ nfsd4_decode_create(struct nfsd4_compoundargs *argp, struct nfsd4_create *create
>  		break;
>  	}
>  
> -	READ_BUF(4);
> +	READ_BUF(sizeof(__be32));
>  	create->cr_namelen = be32_to_cpup(p++);
>  	READ_BUF(create->cr_namelen);
>  	SAVEMEM(create->cr_name, create->cr_namelen);
> @@ -654,7 +652,7 @@ nfsd4_decode_link(struct nfsd4_compoundargs *argp, struct nfsd4_link *link)
>  {
>  	DECODE_HEAD;
>  
> -	READ_BUF(4);
> +	READ_BUF(sizeof(__be32));
>  	link->li_namelen = be32_to_cpup(p++);
>  	READ_BUF(link->li_namelen);
>  	SAVEMEM(link->li_name, link->li_namelen);
> @@ -672,7 +670,7 @@ nfsd4_decode_lock(struct nfsd4_compoundargs *argp, struct nfsd4_lock *lock)
>  	/*
>  	* type, reclaim(boolean), offset, length, new_lock_owner(boolean)
>  	*/
> -	READ_BUF(28);
> +	READ_BUF(3 * sizeof(__be32) + 2 * sizeof(__be64));
>  	lock->lk_type = be32_to_cpup(p++);
>  	if ((lock->lk_type < NFS4_READ_LT) || (lock->lk_type > NFS4_WRITEW_LT))
>  		goto xdr_error;
> @@ -682,12 +680,12 @@ nfsd4_decode_lock(struct nfsd4_compoundargs *argp, struct nfsd4_lock *lock)
>  	lock->lk_is_new = be32_to_cpup(p++);
>  
>  	if (lock->lk_is_new) {
> -		READ_BUF(4);
> +		READ_BUF(sizeof(__be32));
>  		lock->lk_new_open_seqid = be32_to_cpup(p++);
>  		status = nfsd4_decode_stateid(argp, &lock->lk_new_open_stateid);
>  		if (status)
>  			return status;
> -		READ_BUF(8 + sizeof(clientid_t));
> +		READ_BUF(2 * sizeof(__be32) + sizeof(clientid_t));
>  		lock->lk_new_lock_seqid = be32_to_cpup(p++);
>  		COPYMEM(&lock->lk_new_clientid, sizeof(clientid_t));
>  		lock->lk_new_owner.len = be32_to_cpup(p++);
> @@ -697,7 +695,7 @@ nfsd4_decode_lock(struct nfsd4_compoundargs *argp, struct nfsd4_lock *lock)
>  		status = nfsd4_decode_stateid(argp, &lock->lk_old_lock_stateid);
>  		if (status)
>  			return status;
> -		READ_BUF(4);
> +		READ_BUF(sizeof(__be32));
>  		lock->lk_old_lock_seqid = be32_to_cpup(p++);
>  	}
>  
> @@ -709,13 +707,13 @@ nfsd4_decode_lockt(struct nfsd4_compoundargs *argp, struct nfsd4_lockt *lockt)
>  {
>  	DECODE_HEAD;
>  		        
> -	READ_BUF(32);
> +	READ_BUF(2 * sizeof(__be32) + 2 * sizeof(__be64) + sizeof(clientid_t));
>  	lockt->lt_type = be32_to_cpup(p++);
>  	if((lockt->lt_type < NFS4_READ_LT) || (lockt->lt_type > NFS4_WRITEW_LT))
>  		goto xdr_error;
>  	p = xdr_decode_hyper(p, &lockt->lt_offset);
>  	p = xdr_decode_hyper(p, &lockt->lt_length);
> -	COPYMEM(&lockt->lt_clientid, 8);
> +	COPYMEM(&lockt->lt_clientid, sizeof(clientid_t));
>  	lockt->lt_owner.len = be32_to_cpup(p++);
>  	READ_BUF(lockt->lt_owner.len);
>  	READMEM(lockt->lt_owner.data, lockt->lt_owner.len);
> @@ -728,7 +726,7 @@ nfsd4_decode_locku(struct nfsd4_compoundargs *argp, struct nfsd4_locku *locku)
>  {
>  	DECODE_HEAD;
>  
> -	READ_BUF(8);
> +	READ_BUF(2 * sizeof(__be32));
>  	locku->lu_type = be32_to_cpup(p++);
>  	if ((locku->lu_type < NFS4_READ_LT) || (locku->lu_type > NFS4_WRITEW_LT))
>  		goto xdr_error;
> @@ -736,7 +734,7 @@ nfsd4_decode_locku(struct nfsd4_compoundargs *argp, struct nfsd4_locku *locku)
>  	status = nfsd4_decode_stateid(argp, &locku->lu_stateid);
>  	if (status)
>  		return status;
> -	READ_BUF(16);
> +	READ_BUF(2 * sizeof(__be64));
>  	p = xdr_decode_hyper(p, &locku->lu_offset);
>  	p = xdr_decode_hyper(p, &locku->lu_length);
>  
> @@ -748,7 +746,7 @@ nfsd4_decode_lookup(struct nfsd4_compoundargs *argp, struct nfsd4_lookup *lookup
>  {
>  	DECODE_HEAD;
>  
> -	READ_BUF(4);
> +	READ_BUF(sizeof(__be32));
>  	lookup->lo_len = be32_to_cpup(p++);
>  	READ_BUF(lookup->lo_len);
>  	SAVEMEM(lookup->lo_name, lookup->lo_len);
> @@ -763,7 +761,7 @@ static __be32 nfsd4_decode_share_access(struct nfsd4_compoundargs *argp, u32 *sh
>  	__be32 *p;
>  	u32 w;
>  
> -	READ_BUF(4);
> +	READ_BUF(sizeof(__be32));
>  	w = be32_to_cpup(p++);
>  	*share_access = w & NFS4_SHARE_ACCESS_MASK;
>  	*deleg_want = w & NFS4_SHARE_WANT_MASK;
> @@ -815,7 +813,7 @@ static __be32 nfsd4_decode_share_deny(struct nfsd4_compoundargs *argp, u32 *x)
>  {
>  	__be32 *p;
>  
> -	READ_BUF(4);
> +	READ_BUF(sizeof(__be32));
>  	*x = be32_to_cpup(p++);
>  	/* Note: unlinke access bits, deny bits may be zero. */
>  	if (*x & ~NFS4_SHARE_DENY_BOTH)
> @@ -829,7 +827,7 @@ static __be32 nfsd4_decode_opaque(struct nfsd4_compoundargs *argp, struct xdr_ne
>  {
>  	__be32 *p;
>  
> -	READ_BUF(4);
> +	READ_BUF(sizeof(__be32));
>  	o->len = be32_to_cpup(p++);
>  
>  	if (o->len == 0 || o->len > NFS4_OPAQUE_LIMIT)
> @@ -854,7 +852,7 @@ nfsd4_decode_open(struct nfsd4_compoundargs *argp, struct nfsd4_open *open)
>  
>  	open->op_xdr_error = 0;
>  	/* seqid, share_access, share_deny, clientid, ownerlen */
> -	READ_BUF(4);
> +	READ_BUF(sizeof(__be32));
>  	open->op_seqid = be32_to_cpup(p++);
>  	/* decode, yet ignore deleg_when until supported */
>  	status = nfsd4_decode_share_access(argp, &open->op_share_access,
> @@ -869,13 +867,13 @@ nfsd4_decode_open(struct nfsd4_compoundargs *argp, struct nfsd4_open *open)
>  	status = nfsd4_decode_opaque(argp, &open->op_owner);
>  	if (status)
>  		goto xdr_error;
> -	READ_BUF(4);
> +	READ_BUF(sizeof(__be32));
>  	open->op_create = be32_to_cpup(p++);
>  	switch (open->op_create) {
>  	case NFS4_OPEN_NOCREATE:
>  		break;
>  	case NFS4_OPEN_CREATE:
> -		READ_BUF(4);
> +		READ_BUF(sizeof(__be32));
>  		open->op_createmode = be32_to_cpup(p++);
>  		switch (open->op_createmode) {
>  		case NFS4_CREATE_UNCHECKED:
> @@ -908,12 +906,12 @@ nfsd4_decode_open(struct nfsd4_compoundargs *argp, struct nfsd4_open *open)
>  	}
>  
>  	/* open_claim */
> -	READ_BUF(4);
> +	READ_BUF(sizeof(__be32));
>  	open->op_claim_type = be32_to_cpup(p++);
>  	switch (open->op_claim_type) {
>  	case NFS4_OPEN_CLAIM_NULL:
>  	case NFS4_OPEN_CLAIM_DELEGATE_PREV:
> -		READ_BUF(4);
> +		READ_BUF(sizeof(__be32));
>  		open->op_fname.len = be32_to_cpup(p++);
>  		READ_BUF(open->op_fname.len);
>  		SAVEMEM(open->op_fname.data, open->op_fname.len);
> @@ -921,14 +919,14 @@ nfsd4_decode_open(struct nfsd4_compoundargs *argp, struct nfsd4_open *open)
>  			return status;
>  		break;
>  	case NFS4_OPEN_CLAIM_PREVIOUS:
> -		READ_BUF(4);
> +		READ_BUF(sizeof(__be32));
>  		open->op_delegate_type = be32_to_cpup(p++);
>  		break;
>  	case NFS4_OPEN_CLAIM_DELEGATE_CUR:
>  		status = nfsd4_decode_stateid(argp, &open->op_delegate_stateid);
>  		if (status)
>  			return status;
> -		READ_BUF(4);
> +		READ_BUF(sizeof(__be32));
>  		open->op_fname.len = be32_to_cpup(p++);
>  		READ_BUF(open->op_fname.len);
>  		SAVEMEM(open->op_fname.data, open->op_fname.len);
> @@ -966,7 +964,7 @@ nfsd4_decode_open_confirm(struct nfsd4_compoundargs *argp, struct nfsd4_open_con
>  	status = nfsd4_decode_stateid(argp, &open_conf->oc_req_stateid);
>  	if (status)
>  		return status;
> -	READ_BUF(4);
> +	READ_BUF(sizeof(__be32));
>  	open_conf->oc_seqid = be32_to_cpup(p++);
>  
>  	DECODE_TAIL;
> @@ -980,7 +978,7 @@ nfsd4_decode_open_downgrade(struct nfsd4_compoundargs *argp, struct nfsd4_open_d
>  	status = nfsd4_decode_stateid(argp, &open_down->od_stateid);
>  	if (status)
>  		return status;
> -	READ_BUF(4);
> +	READ_BUF(sizeof(__be32));
>  	open_down->od_seqid = be32_to_cpup(p++);
>  	status = nfsd4_decode_share_access(argp, &open_down->od_share_access,
>  					   &open_down->od_deleg_want, NULL);
> @@ -997,7 +995,7 @@ nfsd4_decode_putfh(struct nfsd4_compoundargs *argp, struct nfsd4_putfh *putfh)
>  {
>  	DECODE_HEAD;
>  
> -	READ_BUF(4);
> +	READ_BUF(sizeof(__be32));
>  	putfh->pf_fhlen = be32_to_cpup(p++);
>  	if (putfh->pf_fhlen > NFS4_FHSIZE)
>  		goto xdr_error;
> @@ -1023,7 +1021,7 @@ nfsd4_decode_read(struct nfsd4_compoundargs *argp, struct nfsd4_read *read)
>  	status = nfsd4_decode_stateid(argp, &read->rd_stateid);
>  	if (status)
>  		return status;
> -	READ_BUF(12);
> +	READ_BUF(sizeof(__be32) + sizeof(__be64));
>  	p = xdr_decode_hyper(p, &read->rd_offset);
>  	read->rd_length = be32_to_cpup(p++);
>  
> @@ -1035,9 +1033,9 @@ nfsd4_decode_readdir(struct nfsd4_compoundargs *argp, struct nfsd4_readdir *read
>  {
>  	DECODE_HEAD;
>  
> -	READ_BUF(24);
> +	READ_BUF(2 * sizeof(__be32) + sizeof(__be64) + NFS4_VERIFIER_SIZE);
>  	p = xdr_decode_hyper(p, &readdir->rd_cookie);
> -	COPYMEM(readdir->rd_verf.data, sizeof(readdir->rd_verf.data));
> +	COPYMEM(readdir->rd_verf.data, NFS4_VERIFIER_SIZE);
>  	readdir->rd_dircount = be32_to_cpup(p++);
>  	readdir->rd_maxcount = be32_to_cpup(p++);
>  	if ((status = nfsd4_decode_bitmap(argp, readdir->rd_bmval)))
> @@ -1051,7 +1049,7 @@ nfsd4_decode_remove(struct nfsd4_compoundargs *argp, struct nfsd4_remove *remove
>  {
>  	DECODE_HEAD;
>  
> -	READ_BUF(4);
> +	READ_BUF(sizeof(__be32));
>  	remove->rm_namelen = be32_to_cpup(p++);
>  	READ_BUF(remove->rm_namelen);
>  	SAVEMEM(remove->rm_name, remove->rm_namelen);
> @@ -1066,9 +1064,9 @@ nfsd4_decode_rename(struct nfsd4_compoundargs *argp, struct nfsd4_rename *rename
>  {
>  	DECODE_HEAD;
>  
> -	READ_BUF(4);
> +	READ_BUF(sizeof(__be32));
>  	rename->rn_snamelen = be32_to_cpup(p++);
> -	READ_BUF(rename->rn_snamelen + 4);
> +	READ_BUF(rename->rn_snamelen + sizeof(__be32));
>  	SAVEMEM(rename->rn_sname, rename->rn_snamelen);
>  	rename->rn_tnamelen = be32_to_cpup(p++);
>  	READ_BUF(rename->rn_tnamelen);
> @@ -1101,7 +1099,7 @@ nfsd4_decode_secinfo(struct nfsd4_compoundargs *argp,
>  {
>  	DECODE_HEAD;
>  
> -	READ_BUF(4);
> +	READ_BUF(sizeof(__be32));
>  	secinfo->si_namelen = be32_to_cpup(p++);
>  	READ_BUF(secinfo->si_namelen);
>  	SAVEMEM(secinfo->si_name, secinfo->si_namelen);
> @@ -1117,7 +1115,7 @@ nfsd4_decode_secinfo_no_name(struct nfsd4_compoundargs *argp,
>  {
>  	DECODE_HEAD;
>  
> -	READ_BUF(4);
> +	READ_BUF(sizeof(__be32));
>  	sin->sin_style = be32_to_cpup(p++);
>  	DECODE_TAIL;
>  }
> @@ -1148,15 +1146,15 @@ nfsd4_decode_setclientid(struct nfsd4_compoundargs *argp, struct nfsd4_setclient
>  	status = nfsd4_decode_opaque(argp, &setclientid->se_name);
>  	if (status)
>  		return nfserr_bad_xdr;
> -	READ_BUF(8);
> +	READ_BUF(2 * sizeof(__be32));
>  	setclientid->se_callback_prog = be32_to_cpup(p++);
>  	setclientid->se_callback_netid_len = be32_to_cpup(p++);
>  
> -	READ_BUF(setclientid->se_callback_netid_len + 4);
> +	READ_BUF(setclientid->se_callback_netid_len + sizeof(__be32));
>  	SAVEMEM(setclientid->se_callback_netid_val, setclientid->se_callback_netid_len);
>  	setclientid->se_callback_addr_len = be32_to_cpup(p++);
>  
> -	READ_BUF(setclientid->se_callback_addr_len + 4);
> +	READ_BUF(setclientid->se_callback_addr_len + sizeof(__be32));
>  	SAVEMEM(setclientid->se_callback_addr_val, setclientid->se_callback_addr_len);
>  	setclientid->se_callback_ident = be32_to_cpup(p++);
>  
> @@ -1171,8 +1169,8 @@ nfsd4_decode_setclientid_confirm(struct nfsd4_compoundargs *argp, struct nfsd4_s
>  	if (argp->minorversion >= 1)
>  		return nfserr_notsupp;
>  
> -	READ_BUF(8 + NFS4_VERIFIER_SIZE);
> -	COPYMEM(&scd_c->sc_clientid, 8);
> +	READ_BUF(sizeof(clientid_t) + NFS4_VERIFIER_SIZE);
> +	COPYMEM(&scd_c->sc_clientid, sizeof(clientid_t));
>  	COPYMEM(&scd_c->sc_confirm, NFS4_VERIFIER_SIZE);
>  
>  	DECODE_TAIL;
> @@ -1190,7 +1188,7 @@ nfsd4_decode_verify(struct nfsd4_compoundargs *argp, struct nfsd4_verify *verify
>  	/* For convenience's sake, we compare raw xdr'd attributes in
>  	 * nfsd4_proc_verify */
>  
> -	READ_BUF(4);
> +	READ_BUF(sizeof(__be32));
>  	verify->ve_attrlen = be32_to_cpup(p++);
>  	READ_BUF(verify->ve_attrlen);
>  	SAVEMEM(verify->ve_attrval, verify->ve_attrlen);
> @@ -1208,7 +1206,7 @@ nfsd4_decode_write(struct nfsd4_compoundargs *argp, struct nfsd4_write *write)
>  	status = nfsd4_decode_stateid(argp, &write->wr_stateid);
>  	if (status)
>  		return status;
> -	READ_BUF(16);
> +	READ_BUF(sizeof(__be64) + 2 * sizeof(__be32));
>  	p = xdr_decode_hyper(p, &write->wr_offset);
>  	write->wr_stable_how = be32_to_cpup(p++);
>  	if (write->wr_stable_how > 2)
> @@ -1257,7 +1255,7 @@ nfsd4_decode_release_lockowner(struct nfsd4_compoundargs *argp, struct nfsd4_rel
>  	if (argp->minorversion >= 1)
>  		return nfserr_notsupp;
>  
> -	READ_BUF(12);
> +	READ_BUF(sizeof(clientid_t) + sizeof(__be32));
>  	COPYMEM(&rlockowner->rl_clientid, sizeof(clientid_t));
>  	rlockowner->rl_owner.len = be32_to_cpup(p++);
>  	READ_BUF(rlockowner->rl_owner.len);
> @@ -1282,62 +1280,62 @@ nfsd4_decode_exchange_id(struct nfsd4_compoundargs *argp,
>  	if (status)
>  		return nfserr_bad_xdr;
>  
> -	READ_BUF(4);
> +	READ_BUF(sizeof(__be32));
>  	exid->flags = be32_to_cpup(p++);
>  
>  	/* Ignore state_protect4_a */
> -	READ_BUF(4);
> +	READ_BUF(sizeof(__be32));
>  	exid->spa_how = be32_to_cpup(p++);
>  	switch (exid->spa_how) {
>  	case SP4_NONE:
>  		break;
>  	case SP4_MACH_CRED:
>  		/* spo_must_enforce */
> -		READ_BUF(4);
> +		READ_BUF(sizeof(__be32));
>  		dummy = be32_to_cpup(p++);
> -		READ_BUF(dummy * 4);
> +		READ_BUF(dummy * sizeof(__be32));
>  		p += dummy;
>  
>  		/* spo_must_allow */
> -		READ_BUF(4);
> +		READ_BUF(sizeof(__be32));
>  		dummy = be32_to_cpup(p++);
> -		READ_BUF(dummy * 4);
> +		READ_BUF(dummy * sizeof(__be32));
>  		p += dummy;
>  		break;
>  	case SP4_SSV:
>  		/* ssp_ops */
> -		READ_BUF(4);
> +		READ_BUF(sizeof(__be32));
>  		dummy = be32_to_cpup(p++);
> -		READ_BUF(dummy * 4);
> +		READ_BUF(dummy * sizeof(__be32));
>  		p += dummy;
>  
> -		READ_BUF(4);
> +		READ_BUF(sizeof(__be32));
>  		dummy = be32_to_cpup(p++);
> -		READ_BUF(dummy * 4);
> +		READ_BUF(dummy * sizeof(__be32));
>  		p += dummy;
>  
>  		/* ssp_hash_algs<> */
> -		READ_BUF(4);
> +		READ_BUF(sizeof(__be32));
>  		tmp = be32_to_cpup(p++);
>  		while (tmp--) {
> -			READ_BUF(4);
> +			READ_BUF(sizeof(__be32));
>  			dummy = be32_to_cpup(p++);
>  			READ_BUF(dummy);
>  			p += XDR_QUADLEN(dummy);
>  		}
>  
>  		/* ssp_encr_algs<> */
> -		READ_BUF(4);
> +		READ_BUF(sizeof(__be32));
>  		tmp = be32_to_cpup(p++);
>  		while (tmp--) {
> -			READ_BUF(4);
> +			READ_BUF(sizeof(__be32));
>  			dummy = be32_to_cpup(p++);
>  			READ_BUF(dummy);
>  			p += XDR_QUADLEN(dummy);
>  		}
>  
>  		/* ssp_window and ssp_num_gss_handles */
> -		READ_BUF(8);
> +		READ_BUF(2 * sizeof(__be32));
>  		dummy = be32_to_cpup(p++);
>  		dummy = be32_to_cpup(p++);
>  		break;
> @@ -1346,7 +1344,7 @@ nfsd4_decode_exchange_id(struct nfsd4_compoundargs *argp,
>  	}
>  
>  	/* Ignore Implementation ID */
> -	READ_BUF(4);    /* nfs_impl_id4 array length */
> +	READ_BUF(sizeof(__be32));    /* nfs_impl_id4 array length */
>  	dummy = be32_to_cpup(p++);
>  
>  	if (dummy > 1)
> @@ -1354,19 +1352,19 @@ nfsd4_decode_exchange_id(struct nfsd4_compoundargs *argp,
>  
>  	if (dummy == 1) {
>  		/* nii_domain */
> -		READ_BUF(4);
> +		READ_BUF(sizeof(__be32));
>  		dummy = be32_to_cpup(p++);
>  		READ_BUF(dummy);
>  		p += XDR_QUADLEN(dummy);
>  
>  		/* nii_name */
> -		READ_BUF(4);
> +		READ_BUF(sizeof(__be32));
>  		dummy = be32_to_cpup(p++);
>  		READ_BUF(dummy);
>  		p += XDR_QUADLEN(dummy);
>  
>  		/* nii_date */
> -		READ_BUF(12);
> +		READ_BUF(sizeof(__be32) + sizeof(__be64));
>  		p += 3;
>  	}
>  	DECODE_TAIL;
> @@ -1379,13 +1377,13 @@ nfsd4_decode_create_session(struct nfsd4_compoundargs *argp,
>  	DECODE_HEAD;
>  	u32 dummy;
>  
> -	READ_BUF(16);
> -	COPYMEM(&sess->clientid, 8);
> +	READ_BUF(sizeof(clientid_t) + 2 * sizeof(__be32));
> +	COPYMEM(&sess->clientid, sizeof(clientid_t));
>  	sess->seqid = be32_to_cpup(p++);
>  	sess->flags = be32_to_cpup(p++);
>  
>  	/* Fore channel attrs */
> -	READ_BUF(28);
> +	READ_BUF(7 * sizeof(__be32));
>  	dummy = be32_to_cpup(p++); /* headerpadsz is always 0 */
>  	sess->fore_channel.maxreq_sz = be32_to_cpup(p++);
>  	sess->fore_channel.maxresp_sz = be32_to_cpup(p++);
> @@ -1394,7 +1392,7 @@ nfsd4_decode_create_session(struct nfsd4_compoundargs *argp,
>  	sess->fore_channel.maxreqs = be32_to_cpup(p++);
>  	sess->fore_channel.nr_rdma_attrs = be32_to_cpup(p++);
>  	if (sess->fore_channel.nr_rdma_attrs == 1) {
> -		READ_BUF(4);
> +		READ_BUF(sizeof(__be32));
>  		sess->fore_channel.rdma_attrs = be32_to_cpup(p++);
>  	} else if (sess->fore_channel.nr_rdma_attrs > 1) {
>  		dprintk("Too many fore channel attr bitmaps!\n");
> @@ -1402,7 +1400,7 @@ nfsd4_decode_create_session(struct nfsd4_compoundargs *argp,
>  	}
>  
>  	/* Back channel attrs */
> -	READ_BUF(28);
> +	READ_BUF(7 * sizeof(__be32));
>  	dummy = be32_to_cpup(p++); /* headerpadsz is always 0 */
>  	sess->back_channel.maxreq_sz = be32_to_cpup(p++);
>  	sess->back_channel.maxresp_sz = be32_to_cpup(p++);
> @@ -1411,14 +1409,14 @@ nfsd4_decode_create_session(struct nfsd4_compoundargs *argp,
>  	sess->back_channel.maxreqs = be32_to_cpup(p++);
>  	sess->back_channel.nr_rdma_attrs = be32_to_cpup(p++);
>  	if (sess->back_channel.nr_rdma_attrs == 1) {
> -		READ_BUF(4);
> +		READ_BUF(sizeof(__be32));
>  		sess->back_channel.rdma_attrs = be32_to_cpup(p++);
>  	} else if (sess->back_channel.nr_rdma_attrs > 1) {
>  		dprintk("Too many back channel attr bitmaps!\n");
>  		goto xdr_error;
>  	}
>  
> -	READ_BUF(4);
> +	READ_BUF(sizeof(__be32));
>  	sess->callback_prog = be32_to_cpup(p++);
>  	nfsd4_decode_cb_sec(argp, &sess->cb_sec);
>  	DECODE_TAIL;
> @@ -1454,7 +1452,7 @@ nfsd4_decode_sequence(struct nfsd4_compoundargs *argp,
>  {
>  	DECODE_HEAD;
>  
> -	READ_BUF(NFS4_MAX_SESSIONID_LEN + 16);
> +	READ_BUF(NFS4_MAX_SESSIONID_LEN + 4 * sizeof(__be32));
>  	COPYMEM(seq->sessionid.data, NFS4_MAX_SESSIONID_LEN);
>  	seq->seqid = be32_to_cpup(p++);
>  	seq->slotid = be32_to_cpup(p++);
> @@ -1471,7 +1469,7 @@ nfsd4_decode_test_stateid(struct nfsd4_compoundargs *argp, struct nfsd4_test_sta
>  	__be32 *p, status;
>  	struct nfsd4_test_stateid_id *stateid;
>  
> -	READ_BUF(4);
> +	READ_BUF(sizeof(__be32));
>  	test_stateid->ts_num_ids = ntohl(*p++);
>  
>  	INIT_LIST_HEAD(&test_stateid->ts_stateid_list);
> @@ -1504,8 +1502,8 @@ static __be32 nfsd4_decode_destroy_clientid(struct nfsd4_compoundargs *argp, str
>  {
>  	DECODE_HEAD;
>  
> -	READ_BUF(8);
> -	COPYMEM(&dc->clientid, 8);
> +	READ_BUF(sizeof(clientid_t));
> +	COPYMEM(&dc->clientid, sizeof(clientid_t));
>  
>  	DECODE_TAIL;
>  }
> @@ -1514,7 +1512,7 @@ static __be32 nfsd4_decode_reclaim_complete(struct nfsd4_compoundargs *argp, str
>  {
>  	DECODE_HEAD;
>  
> -	READ_BUF(4);
> +	READ_BUF(sizeof(__be32));
>  	rc->rca_one_fs = be32_to_cpup(p++);
>  
>  	DECODE_TAIL;
> @@ -1616,18 +1614,18 @@ nfsd4_decode_compound(struct nfsd4_compoundargs *argp)
>  	struct nfsd4_op *op;
>  	bool cachethis = false;
>  	int auth_slack= argp->rqstp->rq_auth_slack;
> -	int max_reply = auth_slack + 8; /* opcnt, status */
> +	int max_reply = auth_slack + 2 * sizeof(__be32); /* opcnt, status */
>  	int readcount = 0;
>  	int readbytes = 0;
>  	int i;
>  
> -	READ_BUF(4);
> +	READ_BUF(sizeof(__be32));
>  	argp->taglen = be32_to_cpup(p++);
> -	READ_BUF(argp->taglen + 8);
> +	READ_BUF(argp->taglen + 2 * sizeof(__be32));
>  	SAVEMEM(argp->tag, argp->taglen);
>  	argp->minorversion = be32_to_cpup(p++);
>  	argp->opcnt = be32_to_cpup(p++);
> -	max_reply += 4 + (XDR_QUADLEN(argp->taglen) << 2);
> +	max_reply += sizeof(__be32) + (XDR_QUADLEN(argp->taglen) << 2);
>  
>  	if (argp->taglen > NFSD4_MAX_TAGLEN)
>  		goto xdr_error;
> @@ -1650,7 +1648,7 @@ nfsd4_decode_compound(struct nfsd4_compoundargs *argp)
>  		op = &argp->ops[i];
>  		op->replay = NULL;
>  
> -		READ_BUF(4);
> +		READ_BUF(sizeof(__be32));
>  		op->opnum = be32_to_cpup(p++);
>  
>  		if (nfsd4_opnum_in_range(argp, op))
> @@ -1730,7 +1728,7 @@ static __be32 nfsd4_encode_components_esc(struct xdr_stream *xdr, char sep,
>  	dprintk("nfsd4_encode_components(%s)\n", components);
>  
>  	pathlen_offset = xdr->buf->len;
> -	p = xdr_reserve_space(xdr, 4);
> +	p = xdr_reserve_space(xdr, sizeof(__be32));
>  	if (!p)
>  		return nfserr_resource;
>  	p++; /* We will fill this in with @count later */
> @@ -1756,7 +1754,7 @@ static __be32 nfsd4_encode_components_esc(struct xdr_stream *xdr, char sep,
>  
>  		strlen = end - str;
>  		if (strlen) {
> -			p = xdr_reserve_space(xdr, strlen + 4);
> +			p = xdr_reserve_space(xdr, strlen + sizeof(__be32));
>  			if (!p)
>  				return nfserr_resource;
>  			p = xdr_encode_opaque(p, str, strlen);
> @@ -1767,7 +1765,8 @@ static __be32 nfsd4_encode_components_esc(struct xdr_stream *xdr, char sep,
>  		str = end;
>  	}
>  	pathlen = htonl(xdr->buf->len - pathlen_offset);
> -	write_bytes_to_xdr_buf(xdr->buf, pathlen_offset, &pathlen, 4);
> +	write_bytes_to_xdr_buf(xdr->buf, pathlen_offset,
> +				&pathlen, sizeof(pathlen));
>  	return 0;
>  }
>  
> @@ -1838,7 +1837,7 @@ static __be32 nfsd4_encode_path(struct xdr_stream *xdr,
>  		cur.dentry = dget_parent(cur.dentry);
>  	}
>  	err = nfserr_resource;
> -	p = xdr_reserve_space(xdr, 4);
> +	p = xdr_reserve_space(xdr, sizeof(__be32));
>  	if (!p)
>  		goto out_free;
>  	*p++ = cpu_to_be32(ncomponents);
> @@ -1849,7 +1848,7 @@ static __be32 nfsd4_encode_path(struct xdr_stream *xdr,
>  
>  		spin_lock(&dentry->d_lock);
>  		len = dentry->d_name.len;
> -		p = xdr_reserve_space(xdr, len + 4);
> +		p = xdr_reserve_space(xdr, len + sizeof(__be32));
>  		if (!p) {
>  			spin_unlock(&dentry->d_lock);
>  			goto out_free;
> @@ -1899,7 +1898,7 @@ static __be32 nfsd4_encode_fs_locations(struct xdr_stream *xdr,
>  	status = nfsd4_encode_fsloc_fsroot(xdr, rqstp, &exp->ex_path);
>  	if (status)
>  		return status;
> -	p = xdr_reserve_space(xdr, 4);
> +	p = xdr_reserve_space(xdr, sizeof(__be32));
>  	if (!p)
>  		return nfserr_resource;
>  	*p++ = cpu_to_be32(fslocs->locations_count);
> @@ -1948,7 +1947,7 @@ nfsd4_encode_security_label(struct xdr_stream *xdr, struct svc_rqst *rqstp,
>  {
>  	__be32 *p;
>  
> -	p = xdr_reserve_space(xdr, len + 4 + 4 + 4);
> +	p = xdr_reserve_space(xdr, len + 3 * sizeof(__be32));
>  	if (!p)
>  		return nfserr_resource;
>  
> @@ -2103,7 +2102,7 @@ nfsd4_encode_fattr(struct xdr_stream *xdr, struct svc_fh *fhp,
>  #endif /* CONFIG_NFSD_V4_SECURITY_LABEL */
>  
>  	if (bmval2) {
> -		p = xdr_reserve_space(xdr, 16);
> +		p = xdr_reserve_space(xdr, 4 * sizeof(__be32));
>  		if (!p)
>  			goto out_resource;
>  		*p++ = cpu_to_be32(3);
> @@ -2111,14 +2110,14 @@ nfsd4_encode_fattr(struct xdr_stream *xdr, struct svc_fh *fhp,
>  		*p++ = cpu_to_be32(bmval1);
>  		*p++ = cpu_to_be32(bmval2);
>  	} else if (bmval1) {
> -		p = xdr_reserve_space(xdr, 12);
> +		p = xdr_reserve_space(xdr, 3 * sizeof(__be32));
>  		if (!p)
>  			goto out_resource;
>  		*p++ = cpu_to_be32(2);
>  		*p++ = cpu_to_be32(bmval0);
>  		*p++ = cpu_to_be32(bmval1);
>  	} else {
> -		p = xdr_reserve_space(xdr, 8);
> +		p = xdr_reserve_space(xdr, 2 * sizeof(__be32));
>  		if (!p)
>  			goto out_resource;
>  		*p++ = cpu_to_be32(1);
> @@ -2126,7 +2125,7 @@ nfsd4_encode_fattr(struct xdr_stream *xdr, struct svc_fh *fhp,
>  	}
>  
>  	attrlen_offset = xdr->buf->len;
> -	p = xdr_reserve_space(xdr, 4);
> +	p = xdr_reserve_space(xdr, sizeof(__be32));
>  	if (!p)
>  		goto out_resource;
>  	p++;                /* to be backfilled later */
> @@ -2141,14 +2140,14 @@ nfsd4_encode_fattr(struct xdr_stream *xdr, struct svc_fh *fhp,
>  		if (!contextsupport)
>  			word2 &= ~FATTR4_WORD2_SECURITY_LABEL;
>  		if (!word2) {
> -			p = xdr_reserve_space(xdr, 12);
> +			p = xdr_reserve_space(xdr, 3 * sizeof(__be32));
>  			if (!p)
>  				goto out_resource;
>  			*p++ = cpu_to_be32(2);
>  			*p++ = cpu_to_be32(word0);
>  			*p++ = cpu_to_be32(word1);
>  		} else {
> -			p = xdr_reserve_space(xdr, 16);
> +			p = xdr_reserve_space(xdr, 4 * sizeof(__be32));
>  			if (!p)
>  				goto out_resource;
>  			*p++ = cpu_to_be32(3);
> @@ -2158,7 +2157,7 @@ nfsd4_encode_fattr(struct xdr_stream *xdr, struct svc_fh *fhp,
>  		}
>  	}
>  	if (bmval0 & FATTR4_WORD0_TYPE) {
> -		p = xdr_reserve_space(xdr, 4);
> +		p = xdr_reserve_space(xdr, sizeof(__be32));
>  		if (!p)
>  			goto out_resource;
>  		dummy = nfs4_file_type(stat.mode);
> @@ -2169,7 +2168,7 @@ nfsd4_encode_fattr(struct xdr_stream *xdr, struct svc_fh *fhp,
>  		*p++ = cpu_to_be32(dummy);
>  	}
>  	if (bmval0 & FATTR4_WORD0_FH_EXPIRE_TYPE) {
> -		p = xdr_reserve_space(xdr, 4);
> +		p = xdr_reserve_space(xdr, sizeof(__be32));
>  		if (!p)
>  			goto out_resource;
>  		if (exp->ex_flags & NFSEXP_NOSUBTREECHECK)
> @@ -2179,37 +2178,37 @@ nfsd4_encode_fattr(struct xdr_stream *xdr, struct svc_fh *fhp,
>  						NFS4_FH_VOL_RENAME);
>  	}
>  	if (bmval0 & FATTR4_WORD0_CHANGE) {
> -		p = xdr_reserve_space(xdr, 8);
> +		p = xdr_reserve_space(xdr, sizeof(__be64));
>  		if (!p)
>  			goto out_resource;
>  		p = encode_change(p, &stat, dentry->d_inode);
>  	}
>  	if (bmval0 & FATTR4_WORD0_SIZE) {
> -		p = xdr_reserve_space(xdr, 8);
> +		p = xdr_reserve_space(xdr, sizeof(__be64));
>  		if (!p)
>  			goto out_resource;
>  		p = xdr_encode_hyper(p, stat.size);
>  	}
>  	if (bmval0 & FATTR4_WORD0_LINK_SUPPORT) {
> -		p = xdr_reserve_space(xdr, 4);
> +		p = xdr_reserve_space(xdr, sizeof(__be32));
>  		if (!p)
>  			goto out_resource;
>  		*p++ = cpu_to_be32(1);
>  	}
>  	if (bmval0 & FATTR4_WORD0_SYMLINK_SUPPORT) {
> -		p = xdr_reserve_space(xdr, 4);
> +		p = xdr_reserve_space(xdr, sizeof(__be32));
>  		if (!p)
>  			goto out_resource;
>  		*p++ = cpu_to_be32(1);
>  	}
>  	if (bmval0 & FATTR4_WORD0_NAMED_ATTR) {
> -		p = xdr_reserve_space(xdr, 4);
> +		p = xdr_reserve_space(xdr, sizeof(__be32));
>  		if (!p)
>  			goto out_resource;
>  		*p++ = cpu_to_be32(0);
>  	}
>  	if (bmval0 & FATTR4_WORD0_FSID) {
> -		p = xdr_reserve_space(xdr, 16);
> +		p = xdr_reserve_space(xdr, 2 * sizeof(__be64));
>  		if (!p)
>  			goto out_resource;
>  		if (exp->ex_fslocs.migrated) {
> @@ -2233,19 +2232,19 @@ nfsd4_encode_fattr(struct xdr_stream *xdr, struct svc_fh *fhp,
>  		}
>  	}
>  	if (bmval0 & FATTR4_WORD0_UNIQUE_HANDLES) {
> -		p = xdr_reserve_space(xdr, 4);
> +		p = xdr_reserve_space(xdr, sizeof(__be32));
>  		if (!p)
>  			goto out_resource;
>  		*p++ = cpu_to_be32(0);
>  	}
>  	if (bmval0 & FATTR4_WORD0_LEASE_TIME) {
> -		p = xdr_reserve_space(xdr, 4);
> +		p = xdr_reserve_space(xdr, sizeof(__be32));
>  		if (!p)
>  			goto out_resource;
>  		*p++ = cpu_to_be32(nn->nfsd4_lease);
>  	}
>  	if (bmval0 & FATTR4_WORD0_RDATTR_ERROR) {
> -		p = xdr_reserve_space(xdr, 4);
> +		p = xdr_reserve_space(xdr, sizeof(__be32));
>  		if (!p)
>  			goto out_resource;
>  		*p++ = cpu_to_be32(rdattr_err);
> @@ -2254,20 +2253,20 @@ nfsd4_encode_fattr(struct xdr_stream *xdr, struct svc_fh *fhp,
>  		struct nfs4_ace *ace;
>  
>  		if (acl == NULL) {
> -			p = xdr_reserve_space(xdr, 4);
> +			p = xdr_reserve_space(xdr, sizeof(__be32));
>  			if (!p)
>  				goto out_resource;
>  
>  			*p++ = cpu_to_be32(0);
>  			goto out_acl;
>  		}
> -		p = xdr_reserve_space(xdr, 4);
> +		p = xdr_reserve_space(xdr, sizeof(__be32));
>  		if (!p)
>  			goto out_resource;
>  		*p++ = cpu_to_be32(acl->naces);
>  
>  		for (ace = acl->aces; ace < acl->aces + acl->naces; ace++) {
> -			p = xdr_reserve_space(xdr, 4*3);
> +			p = xdr_reserve_space(xdr, 3 * sizeof(__be32));
>  			if (!p)
>  				goto out_resource;
>  			*p++ = cpu_to_be32(ace->type);
> @@ -2281,63 +2280,63 @@ nfsd4_encode_fattr(struct xdr_stream *xdr, struct svc_fh *fhp,
>  	}
>  out_acl:
>  	if (bmval0 & FATTR4_WORD0_ACLSUPPORT) {
> -		p = xdr_reserve_space(xdr, 4);
> +		p = xdr_reserve_space(xdr, sizeof(__be32));
>  		if (!p)
>  			goto out_resource;
>  		*p++ = cpu_to_be32(aclsupport ?
>  			ACL4_SUPPORT_ALLOW_ACL|ACL4_SUPPORT_DENY_ACL : 0);
>  	}
>  	if (bmval0 & FATTR4_WORD0_CANSETTIME) {
> -		p = xdr_reserve_space(xdr, 4);
> +		p = xdr_reserve_space(xdr, sizeof(__be32));
>  		if (!p)
>  			goto out_resource;
>  		*p++ = cpu_to_be32(1);
>  	}
>  	if (bmval0 & FATTR4_WORD0_CASE_INSENSITIVE) {
> -		p = xdr_reserve_space(xdr, 4);
> +		p = xdr_reserve_space(xdr, sizeof(__be32));
>  		if (!p)
>  			goto out_resource;
>  		*p++ = cpu_to_be32(0);
>  	}
>  	if (bmval0 & FATTR4_WORD0_CASE_PRESERVING) {
> -		p = xdr_reserve_space(xdr, 4);
> +		p = xdr_reserve_space(xdr, sizeof(__be32));
>  		if (!p)
>  			goto out_resource;
>  		*p++ = cpu_to_be32(1);
>  	}
>  	if (bmval0 & FATTR4_WORD0_CHOWN_RESTRICTED) {
> -		p = xdr_reserve_space(xdr, 4);
> +		p = xdr_reserve_space(xdr, sizeof(__be32));
>  		if (!p)
>  			goto out_resource;
>  		*p++ = cpu_to_be32(1);
>  	}
>  	if (bmval0 & FATTR4_WORD0_FILEHANDLE) {
> -		p = xdr_reserve_space(xdr, fhp->fh_handle.fh_size + 4);
> +		p = xdr_reserve_space(xdr, fhp->fh_handle.fh_size + sizeof(__be32));
>  		if (!p)
>  			goto out_resource;
>  		p = xdr_encode_opaque(p, &fhp->fh_handle.fh_base,
>  					fhp->fh_handle.fh_size);
>  	}
>  	if (bmval0 & FATTR4_WORD0_FILEID) {
> -		p = xdr_reserve_space(xdr, 8);
> +		p = xdr_reserve_space(xdr, sizeof(__be64));
>  		if (!p)
>  			goto out_resource;
>  		p = xdr_encode_hyper(p, stat.ino);
>  	}
>  	if (bmval0 & FATTR4_WORD0_FILES_AVAIL) {
> -		p = xdr_reserve_space(xdr, 8);
> +		p = xdr_reserve_space(xdr, sizeof(__be64));
>  		if (!p)
>  			goto out_resource;
>  		p = xdr_encode_hyper(p, (u64) statfs.f_ffree);
>  	}
>  	if (bmval0 & FATTR4_WORD0_FILES_FREE) {
> -		p = xdr_reserve_space(xdr, 8);
> +		p = xdr_reserve_space(xdr, sizeof(__be64));
>  		if (!p)
>  			goto out_resource;
>  		p = xdr_encode_hyper(p, (u64) statfs.f_ffree);
>  	}
>  	if (bmval0 & FATTR4_WORD0_FILES_TOTAL) {
> -		p = xdr_reserve_space(xdr, 8);
> +		p = xdr_reserve_space(xdr, sizeof(__be64));
>  		if (!p)
>  			goto out_resource;
>  		p = xdr_encode_hyper(p, (u64) statfs.f_files);
> @@ -2348,55 +2347,55 @@ out_acl:
>  			goto out;
>  	}
>  	if (bmval0 & FATTR4_WORD0_HOMOGENEOUS) {
> -		p = xdr_reserve_space(xdr, 4);
> +		p = xdr_reserve_space(xdr, sizeof(__be32));
>  		if (!p)
>  			goto out_resource;
>  		*p++ = cpu_to_be32(1);
>  	}
>  	if (bmval0 & FATTR4_WORD0_MAXFILESIZE) {
> -		p = xdr_reserve_space(xdr, 8);
> +		p = xdr_reserve_space(xdr, sizeof(__be64));
>  		if (!p)
>  			goto out_resource;
>  		p = xdr_encode_hyper(p, exp->ex_path.mnt->mnt_sb->s_maxbytes);
>  	}
>  	if (bmval0 & FATTR4_WORD0_MAXLINK) {
> -		p = xdr_reserve_space(xdr, 4);
> +		p = xdr_reserve_space(xdr, sizeof(__be32));
>  		if (!p)
>  			goto out_resource;
>  		*p++ = cpu_to_be32(255);
>  	}
>  	if (bmval0 & FATTR4_WORD0_MAXNAME) {
> -		p = xdr_reserve_space(xdr, 4);
> +		p = xdr_reserve_space(xdr, sizeof(__be32));
>  		if (!p)
>  			goto out_resource;
>  		*p++ = cpu_to_be32(statfs.f_namelen);
>  	}
>  	if (bmval0 & FATTR4_WORD0_MAXREAD) {
> -		p = xdr_reserve_space(xdr, 8);
> +		p = xdr_reserve_space(xdr, sizeof(__be64));
>  		if (!p)
>  			goto out_resource;
>  		p = xdr_encode_hyper(p, (u64) svc_max_payload(rqstp));
>  	}
>  	if (bmval0 & FATTR4_WORD0_MAXWRITE) {
> -		p = xdr_reserve_space(xdr, 8);
> +		p = xdr_reserve_space(xdr, sizeof(__be64));
>  		if (!p)
>  			goto out_resource;
>  		p = xdr_encode_hyper(p, (u64) svc_max_payload(rqstp));
>  	}
>  	if (bmval1 & FATTR4_WORD1_MODE) {
> -		p = xdr_reserve_space(xdr, 4);
> +		p = xdr_reserve_space(xdr, sizeof(__be32));
>  		if (!p)
>  			goto out_resource;
>  		*p++ = cpu_to_be32(stat.mode & S_IALLUGO);
>  	}
>  	if (bmval1 & FATTR4_WORD1_NO_TRUNC) {
> -		p = xdr_reserve_space(xdr, 4);
> +		p = xdr_reserve_space(xdr, sizeof(__be32));
>  		if (!p)
>  			goto out_resource;
>  		*p++ = cpu_to_be32(1);
>  	}
>  	if (bmval1 & FATTR4_WORD1_NUMLINKS) {
> -		p = xdr_reserve_space(xdr, 4);
> +		p = xdr_reserve_space(xdr, sizeof(__be32));
>  		if (!p)
>  			goto out_resource;
>  		*p++ = cpu_to_be32(stat.nlink);
> @@ -2412,49 +2411,49 @@ out_acl:
>  			goto out;
>  	}
>  	if (bmval1 & FATTR4_WORD1_RAWDEV) {
> -		p = xdr_reserve_space(xdr, 8);
> +		p = xdr_reserve_space(xdr, sizeof(__be64));
>  		if (!p)
>  			goto out_resource;
>  		*p++ = cpu_to_be32((u32) MAJOR(stat.rdev));
>  		*p++ = cpu_to_be32((u32) MINOR(stat.rdev));
>  	}
>  	if (bmval1 & FATTR4_WORD1_SPACE_AVAIL) {
> -		p = xdr_reserve_space(xdr, 8);
> +		p = xdr_reserve_space(xdr, sizeof(__be64));
>  		if (!p)
>  			goto out_resource;
>  		dummy64 = (u64)statfs.f_bavail * (u64)statfs.f_bsize;
>  		p = xdr_encode_hyper(p, dummy64);
>  	}
>  	if (bmval1 & FATTR4_WORD1_SPACE_FREE) {
> -		p = xdr_reserve_space(xdr, 8);
> +		p = xdr_reserve_space(xdr, sizeof(__be64));
>  		if (!p)
>  			goto out_resource;
>  		dummy64 = (u64)statfs.f_bfree * (u64)statfs.f_bsize;
>  		p = xdr_encode_hyper(p, dummy64);
>  	}
>  	if (bmval1 & FATTR4_WORD1_SPACE_TOTAL) {
> -		p = xdr_reserve_space(xdr, 8);
> +		p = xdr_reserve_space(xdr, sizeof(__be64));
>  		if (!p)
>  			goto out_resource;
>  		dummy64 = (u64)statfs.f_blocks * (u64)statfs.f_bsize;
>  		p = xdr_encode_hyper(p, dummy64);
>  	}
>  	if (bmval1 & FATTR4_WORD1_SPACE_USED) {
> -		p = xdr_reserve_space(xdr, 8);
> +		p = xdr_reserve_space(xdr, sizeof(__be64));
>  		if (!p)
>  			goto out_resource;
>  		dummy64 = (u64)stat.blocks << 9;
>  		p = xdr_encode_hyper(p, dummy64);
>  	}
>  	if (bmval1 & FATTR4_WORD1_TIME_ACCESS) {
> -		p = xdr_reserve_space(xdr, 12);
> +		p = xdr_reserve_space(xdr, sizeof(__be64) + sizeof(__be32));
>  		if (!p)
>  			goto out_resource;
>  		p = xdr_encode_hyper(p, (s64)stat.atime.tv_sec);
>  		*p++ = cpu_to_be32(stat.atime.tv_nsec);
>  	}
>  	if (bmval1 & FATTR4_WORD1_TIME_DELTA) {
> -		p = xdr_reserve_space(xdr, 12);
> +		p = xdr_reserve_space(xdr, 3 * sizeof(__be32));
>  		if (!p)
>  			goto out_resource;
>  		*p++ = cpu_to_be32(0);
> @@ -2462,21 +2461,21 @@ out_acl:
>  		*p++ = cpu_to_be32(0);
>  	}
>  	if (bmval1 & FATTR4_WORD1_TIME_METADATA) {
> -		p = xdr_reserve_space(xdr, 12);
> +		p = xdr_reserve_space(xdr, sizeof(__be64) + sizeof(__be32));
>  		if (!p)
>  			goto out_resource;
>  		p = xdr_encode_hyper(p, (s64)stat.ctime.tv_sec);
>  		*p++ = cpu_to_be32(stat.ctime.tv_nsec);
>  	}
>  	if (bmval1 & FATTR4_WORD1_TIME_MODIFY) {
> -		p = xdr_reserve_space(xdr, 12);
> +		p = xdr_reserve_space(xdr, sizeof(__be64) + sizeof(__be32));
>  		if (!p)
>  			goto out_resource;
>  		p = xdr_encode_hyper(p, (s64)stat.mtime.tv_sec);
>  		*p++ = cpu_to_be32(stat.mtime.tv_nsec);
>  	}
>  	if (bmval1 & FATTR4_WORD1_MOUNTED_ON_FILEID) {
> -		p = xdr_reserve_space(xdr, 8);
> +		p = xdr_reserve_space(xdr, sizeof(__be64));
>  		if (!p)
>                  	goto out_resource;
>  		/*
> @@ -2495,7 +2494,7 @@ out_acl:
>  			goto out;
>  	}
>  	if (bmval2 & FATTR4_WORD2_SUPPATTR_EXCLCREAT) {
> -		p = xdr_reserve_space(xdr, 16);
> +		p = xdr_reserve_space(xdr, 4 * sizeof(__be32));
>  		if (!p)
>  			goto out_resource;
>  		*p++ = cpu_to_be32(3);
> @@ -2504,8 +2503,9 @@ out_acl:
>  		*p++ = cpu_to_be32(NFSD_SUPPATTR_EXCLCREAT_WORD2);
>  	}
>  
> -	attrlen = htonl(xdr->buf->len - attrlen_offset - 4);
> -	write_bytes_to_xdr_buf(xdr->buf, attrlen_offset, &attrlen, 4);
> +	attrlen = htonl(xdr->buf->len - attrlen_offset - sizeof(__be32));
> +	write_bytes_to_xdr_buf(xdr->buf, attrlen_offset,
> +				&attrlen, sizeof(attrlen));
>  	status = nfs_ok;
>  
>  out:
> @@ -2636,7 +2636,7 @@ nfsd4_encode_rdattr_error(struct xdr_stream *xdr, __be32 nfserr)
>  {
>  	__be32 *p;
>  
> -	p = xdr_reserve_space(xdr, 20);
> +	p = xdr_reserve_space(xdr, 5 * sizeof(__be32));
>  	if (!p)
>  		return NULL;
>  	*p++ = htonl(2);
> @@ -2671,15 +2671,15 @@ nfsd4_encode_dirent(void *ccdv, const char *name, int namlen,
>  	if (cd->cookie_offset) {
>  		wire_offset = cpu_to_be64(offset);
>  		write_bytes_to_xdr_buf(xdr->buf, cd->cookie_offset,
> -							&wire_offset, 8);
> +					&wire_offset, sizeof(wire_offset));
>  	}
>  
> -	p = xdr_reserve_space(xdr, 4);
> +	p = xdr_reserve_space(xdr, sizeof(__be32));
>  	if (!p)
>  		goto fail;
>  	*p++ = xdr_one;                             /* mark entry present */
>  	cookie_offset = xdr->buf->len;
> -	p = xdr_reserve_space(xdr, 3*4 + namlen);
> +	p = xdr_reserve_space(xdr, sizeof(__be32) + sizeof(__be64) + namlen);
>  	if (!p)
>  		goto fail;
>  	p = xdr_encode_hyper(p, NFS_OFFSET_MAX);    /* offset of next entry */
> @@ -2750,7 +2750,7 @@ nfsd4_encode_access(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_
>  	__be32 *p;
>  
>  	if (!nfserr) {
> -		p = xdr_reserve_space(xdr, 8);
> +		p = xdr_reserve_space(xdr, 2 * sizeof(__be32));
>  		if (!p)
>  			return nfserr_resource;
>  		*p++ = cpu_to_be32(access->ac_supported);
> @@ -2765,7 +2765,7 @@ static __be32 nfsd4_encode_bind_conn_to_session(struct nfsd4_compoundres *resp,
>  	__be32 *p;
>  
>  	if (!nfserr) {
> -		p = xdr_reserve_space(xdr, NFS4_MAX_SESSIONID_LEN + 8);
> +		p = xdr_reserve_space(xdr, NFS4_MAX_SESSIONID_LEN + 2 * sizeof(__be32));
>  		if (!p)
>  			return nfserr_resource;
>  		p = xdr_encode_opaque_fixed(p, bcts->sessionid.data,
> @@ -2812,7 +2812,7 @@ nfsd4_encode_create(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_
>  	__be32 *p;
>  
>  	if (!nfserr) {
> -		p = xdr_reserve_space(xdr, 32);
> +		p = xdr_reserve_space(xdr, 4 * sizeof(__be32) + 2 * sizeof(__be64));
>  		if (!p)
>  			return nfserr_resource;
>  		p = encode_cinfo(p, &create->cr_cinfo);
> @@ -2848,7 +2848,7 @@ nfsd4_encode_getfh(struct nfsd4_compoundres *resp, __be32 nfserr, struct svc_fh
>  
>  	if (!nfserr) {
>  		len = fhp->fh_handle.fh_size;
> -		p = xdr_reserve_space(xdr, len + 4);
> +		p = xdr_reserve_space(xdr, len + sizeof(__be32));
>  		if (!p)
>  			return nfserr_resource;
>  		p = xdr_encode_opaque(p, &fhp->fh_handle.fh_base, len);
> @@ -2867,7 +2867,8 @@ nfsd4_encode_lock_denied(struct xdr_stream *xdr, struct nfsd4_lock_denied *ld)
>  	__be32 *p;
>  
>  again:
> -	p = xdr_reserve_space(xdr, 32 + XDR_LEN(conf->len));
> +	p = xdr_reserve_space(xdr, 2 * sizeof(__be64) + 2 * sizeof(__be32) + \
> +				sizeof(clientid_t) + XDR_LEN(conf->len));
>  	if (!p) {
>  		/*
>  		 * Don't fail to return the result just because we can't
> @@ -2885,7 +2886,7 @@ again:
>  	p = xdr_encode_hyper(p, ld->ld_length);
>  	*p++ = cpu_to_be32(ld->ld_type);
>  	if (conf->len) {
> -		p = xdr_encode_opaque_fixed(p, &ld->ld_clientid, 8);
> +		p = xdr_encode_opaque_fixed(p, &ld->ld_clientid, sizeof(clientid_t));
>  		p = xdr_encode_opaque(p, conf->data, conf->len);
>  		kfree(conf->data);
>  	}  else {  /* non - nfsv4 lock in conflict, no clientid nor owner */
> @@ -2937,7 +2938,7 @@ nfsd4_encode_link(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_li
>  	__be32 *p;
>  
>  	if (!nfserr) {
> -		p = xdr_reserve_space(xdr, 20);
> +		p = xdr_reserve_space(xdr, sizeof(__be32) + 2 * sizeof(__be64));
>  		if (!p)
>  			return nfserr_resource;
>  		p = encode_cinfo(p, &link->li_cinfo);
> @@ -2958,7 +2959,7 @@ nfsd4_encode_open(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_op
>  	nfserr = nfsd4_encode_stateid(xdr, &open->op_stateid);
>  	if (nfserr)
>  		goto out;
> -	p = xdr_reserve_space(xdr, 40);
> +	p = xdr_reserve_space(xdr, 6 * sizeof(__be32) + 2 * sizeof(__be64));
>  	if (!p)
>  		return nfserr_resource;
>  	p = encode_cinfo(p, &open->op_cinfo);
> @@ -2975,7 +2976,7 @@ nfsd4_encode_open(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_op
>  		nfserr = nfsd4_encode_stateid(xdr, &open->op_delegate_stateid);
>  		if (nfserr)
>  			return nfserr;
> -		p = xdr_reserve_space(xdr, 20);
> +		p = xdr_reserve_space(xdr, 5 * sizeof(__be32));
>  		if (!p)
>  			return nfserr_resource;
>  		*p++ = cpu_to_be32(open->op_recall);
> @@ -2992,7 +2993,7 @@ nfsd4_encode_open(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_op
>  		nfserr = nfsd4_encode_stateid(xdr, &open->op_delegate_stateid);
>  		if (nfserr)
>  			return nfserr;
> -		p = xdr_reserve_space(xdr, 32);
> +		p = xdr_reserve_space(xdr, 8 * sizeof(__be32));
>  		if (!p)
>  			return nfserr_resource;
>  		*p++ = cpu_to_be32(0);
> @@ -3016,7 +3017,7 @@ nfsd4_encode_open(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_op
>  		switch (open->op_why_no_deleg) {
>  		case WND4_CONTENTION:
>  		case WND4_RESOURCE:
> -			p = xdr_reserve_space(xdr, 8);
> +			p = xdr_reserve_space(xdr, 2 * sizeof(__be32));
>  			if (!p)
>  				return nfserr_resource;
>  			*p++ = cpu_to_be32(open->op_why_no_deleg);
> @@ -3024,7 +3025,7 @@ nfsd4_encode_open(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_op
>  			*p++ = cpu_to_be32(0);
>  			break;
>  		default:
> -			p = xdr_reserve_space(xdr, 4);
> +			p = xdr_reserve_space(xdr, sizeof(__be32));
>  			if (!p)
>  				return nfserr_resource;
>  			*p++ = cpu_to_be32(open->op_why_no_deleg);
> @@ -3127,7 +3128,7 @@ static __be32 nfsd4_encode_readv(struct nfsd4_compoundres *resp,
>  	struct xdr_stream *xdr = &resp->xdr;
>  	u32 eof;
>  	int v;
> -	int starting_len = xdr->buf->len - 8;
> +	int starting_len = xdr->buf->len - 2 * sizeof(__be32);
>  	long len;
>  	int thislen;
>  	__be32 nfserr;
> @@ -3140,7 +3141,7 @@ static __be32 nfsd4_encode_readv(struct nfsd4_compoundres *resp,
>  	v = 0;
>  
>  	thislen = min_t(long, len, ((void *)xdr->end - (void *)xdr->p));
> -	p = xdr_reserve_space(xdr, (thislen+3)&~3);
> +	p = xdr_reserve_space(xdr, thislen);
>  	WARN_ON_ONCE(!p);
>  	resp->rqstp->rq_vec[v].iov_base = p;
>  	resp->rqstp->rq_vec[v].iov_len = thislen;
> @@ -3149,7 +3150,7 @@ static __be32 nfsd4_encode_readv(struct nfsd4_compoundres *resp,
>  
>  	while (len) {
>  		thislen = min_t(long, len, PAGE_SIZE);
> -		p = xdr_reserve_space(xdr, (thislen+3)&~3);
> +		p = xdr_reserve_space(xdr, thislen);
>  		WARN_ON_ONCE(!p);
>  		resp->rqstp->rq_vec[v].iov_base = p;
>  		resp->rqstp->rq_vec[v].iov_len = thislen;
> @@ -3162,19 +3163,21 @@ static __be32 nfsd4_encode_readv(struct nfsd4_compoundres *resp,
>  			read->rd_vlen, &maxcount);
>  	if (nfserr)
>  		return nfserr;
> -	xdr_truncate_encode(xdr, starting_len + 8 + ((maxcount+3)&~3));
> +	xdr_truncate_encode(xdr, starting_len + 2 * sizeof(__be32) + \
> +				ALIGN(maxcount, 4));
>  
>  	eof = (read->rd_offset + maxcount >=
>  	       read->rd_fhp->fh_dentry->d_inode->i_size);
>  
>  	tmp = htonl(eof);
> -	write_bytes_to_xdr_buf(xdr->buf, starting_len    , &tmp, 4);
> +	write_bytes_to_xdr_buf(xdr->buf, starting_len, &tmp, sizeof(tmp));
>  	tmp = htonl(maxcount);
> -	write_bytes_to_xdr_buf(xdr->buf, starting_len + 4, &tmp, 4);
> +	write_bytes_to_xdr_buf(xdr->buf, starting_len + sizeof(__be32),
> +				&tmp, sizeof(tmp));
>  
>  	pad = (maxcount&3) ? 4 - (maxcount&3) : 0;
> -	write_bytes_to_xdr_buf(xdr->buf, starting_len + 8 + maxcount,
> -								&zzz, pad);
> +	write_bytes_to_xdr_buf(xdr->buf, starting_len + 2 * sizeof(__be32) + \
> +				maxcount, &zzz, pad);
>  	return 0;
>  
>  }
> @@ -3194,7 +3197,7 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
>  	if (nfserr)
>  		return nfserr;
>  
> -	p = xdr_reserve_space(xdr, 8); /* eof flag and byte count */
> +	p = xdr_reserve_space(xdr, 2 * sizeof(__be32)); /* eof flag and byte count */
>  	if (!p) {
>  		WARN_ON_ONCE(resp->rqstp->rq_splice_ok);
>  		return nfserr_resource;
> @@ -3243,7 +3246,7 @@ nfsd4_encode_readlink(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd
>  	if (nfserr)
>  		return nfserr;
>  
> -	p = xdr_reserve_space(xdr, 4);
> +	p = xdr_reserve_space(xdr, sizeof(__be32));
>  	if (!p)
>  		return nfserr_resource;
>  	maxcount = PAGE_SIZE;
> @@ -3267,11 +3270,12 @@ nfsd4_encode_readlink(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd
>  	}
>  
>  	wire_count = htonl(maxcount);
> -	write_bytes_to_xdr_buf(xdr->buf, length_offset, &wire_count, 4);
> -	xdr_truncate_encode(xdr, length_offset + 4 + maxcount);
> +	write_bytes_to_xdr_buf(xdr->buf, length_offset,
> +			       &wire_count, sizeof(wire_count));
> +	xdr_truncate_encode(xdr, length_offset + sizeof(__be32) + maxcount);
>  	if (maxcount & 3)
> -		write_bytes_to_xdr_buf(xdr->buf, length_offset + 4 + maxcount,
> -						&zero, 4 - (maxcount&3));
> +		write_bytes_to_xdr_buf(xdr->buf, length_offset + maxcount + \
> +				       sizeof(__be32), &zero, 4 - (maxcount&3));
>  	return 0;
>  }
>  
> @@ -3304,7 +3308,7 @@ nfsd4_encode_readdir(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4
>  	 * final 8 bytes of the readdir and a following failed op:
>  	 */
>  	bytes_left = xdr->buf->buflen - xdr->buf->len
> -			- COMPOUND_ERR_SLACK_SPACE - 8;
> +			- COMPOUND_ERR_SLACK_SPACE - 2 * sizeof(__be32);
>  	if (bytes_left < 0) {
>  		nfserr = nfserr_resource;
>  		goto err_no_verf;
> @@ -3315,11 +3319,12 @@ nfsd4_encode_readdir(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4
>  	 * READDIR4resok structure, which includes the verifier above
>  	 * and the 8 bytes encoded at the end of this function:
>  	 */
> -	if (maxcount < 16) {
> +	if (maxcount < (2 * sizeof(__be32) + NFS4_VERIFIER_SIZE)) {
>  		nfserr = nfserr_toosmall;
>  		goto err_no_verf;
>  	}
> -	maxcount = min_t(int, maxcount-16, bytes_left);
> +	maxcount = min_t(int, maxcount - (2 * sizeof(__be32) + NFS4_VERIFIER_SIZE),
> +			 bytes_left);
>  
>  	readdir->xdr = xdr;
>  	readdir->rd_maxcount = maxcount;
> @@ -3332,9 +3337,9 @@ nfsd4_encode_readdir(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4
>  			      &readdir->common, nfsd4_encode_dirent);
>  	if (nfserr == nfs_ok &&
>  	    readdir->common.err == nfserr_toosmall &&
> -	    xdr->buf->len == starting_len + 8) {
> +	    xdr->buf->len == starting_len + 2 * sizeof(__be32)) {
>  		/* nothing encoded; which limit did we hit?: */
> -		if (maxcount - 16 < bytes_left)
> +		if (maxcount - (2 * sizeof(__be32) + NFS4_VERIFIER_SIZE) < bytes_left)
>  			/* It was the fault of rd_maxcount: */
>  			nfserr = nfserr_toosmall;
>  		else
> @@ -3347,10 +3352,10 @@ nfsd4_encode_readdir(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4
>  	if (readdir->cookie_offset) {
>  		wire_offset = cpu_to_be64(offset);
>  		write_bytes_to_xdr_buf(xdr->buf, readdir->cookie_offset,
> -							&wire_offset, 8);
> +					&wire_offset, sizeof(wire_offset));
>  	}
>  
> -	p = xdr_reserve_space(xdr, 8);
> +	p = xdr_reserve_space(xdr, 2 * sizeof(__be32));
>  	if (!p) {
>  		WARN_ON_ONCE(1);
>  		goto err_no_verf;
> @@ -3371,7 +3376,7 @@ nfsd4_encode_remove(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_
>  	__be32 *p;
>  
>  	if (!nfserr) {
> -		p = xdr_reserve_space(xdr, 20);
> +		p = xdr_reserve_space(xdr, sizeof(__be32) + 2 * sizeof(__be64));
>  		if (!p)
>  			return nfserr_resource;
>  		p = encode_cinfo(p, &remove->rm_cinfo);
> @@ -3386,7 +3391,7 @@ nfsd4_encode_rename(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_
>  	__be32 *p;
>  
>  	if (!nfserr) {
> -		p = xdr_reserve_space(xdr, 40);
> +		p = xdr_reserve_space(xdr, 2 * (sizeof(__be32) + 2 * sizeof(__be64)));
>  		if (!p)
>  			return nfserr_resource;
>  		p = encode_cinfo(p, &rename->rn_sinfo);
> @@ -3429,7 +3434,7 @@ nfsd4_do_encode_secinfo(struct xdr_stream *xdr,
>  	}
>  
>  	supported = 0;
> -	p = xdr_reserve_space(xdr, 4);
> +	p = xdr_reserve_space(xdr, sizeof(__be32));
>  	if (!p)
>  		goto out;
>  	flavorsp = p++;		/* to be backfilled later */
> @@ -3440,8 +3445,7 @@ nfsd4_do_encode_secinfo(struct xdr_stream *xdr,
>  
>  		if (rpcauth_get_gssinfo(pf, &info) == 0) {
>  			supported++;
> -			p = xdr_reserve_space(xdr, 4 + 4 +
> -					      XDR_LEN(info.oid.len) + 4 + 4);
> +			p = xdr_reserve_space(xdr, 4 * sizeof(__be32) + info.oid.len);
>  			if (!p)
>  				goto out;
>  			*p++ = cpu_to_be32(RPC_AUTH_GSS);
> @@ -3450,7 +3454,7 @@ nfsd4_do_encode_secinfo(struct xdr_stream *xdr,
>  			*p++ = cpu_to_be32(info.service);
>  		} else if (pf < RPC_AUTH_MAXFLAVOR) {
>  			supported++;
> -			p = xdr_reserve_space(xdr, 4);
> +			p = xdr_reserve_space(xdr, sizeof(__be32));
>  			if (!p)
>  				goto out;
>  			*p++ = cpu_to_be32(pf);
> @@ -3499,7 +3503,7 @@ nfsd4_encode_setattr(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4
>  	struct xdr_stream *xdr = &resp->xdr;
>  	__be32 *p;
>  
> -	p = xdr_reserve_space(xdr, 16);
> +	p = xdr_reserve_space(xdr, 4 * sizeof(__be32));
>  	if (!p)
>  		return nfserr_resource;
>  	if (nfserr) {
> @@ -3524,15 +3528,17 @@ nfsd4_encode_setclientid(struct nfsd4_compoundres *resp, __be32 nfserr, struct n
>  	__be32 *p;
>  
>  	if (!nfserr) {
> -		p = xdr_reserve_space(xdr, 8 + NFS4_VERIFIER_SIZE);
> +		p = xdr_reserve_space(xdr, sizeof(clientid_t) + \
> +						NFS4_VERIFIER_SIZE);
>  		if (!p)
>  			return nfserr_resource;
> -		p = xdr_encode_opaque_fixed(p, &scd->se_clientid, 8);
> +		p = xdr_encode_opaque_fixed(p, &scd->se_clientid,
> +						sizeof(clientid_t));
>  		p = xdr_encode_opaque_fixed(p, &scd->se_confirm,
>  						NFS4_VERIFIER_SIZE);
>  	}
>  	else if (nfserr == nfserr_clid_inuse) {
> -		p = xdr_reserve_space(xdr, 8);
> +		p = xdr_reserve_space(xdr, 2 * sizeof(__be32));
>  		if (!p)
>  			return nfserr_resource;
>  		*p++ = cpu_to_be32(0);
> @@ -3548,7 +3554,7 @@ nfsd4_encode_write(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_w
>  	__be32 *p;
>  
>  	if (!nfserr) {
> -		p = xdr_reserve_space(xdr, 16);
> +		p = xdr_reserve_space(xdr, 2 * sizeof(__be32) + NFS4_VERIFIER_SIZE);
>  		if (!p)
>  			return nfserr_resource;
>  		*p++ = cpu_to_be32(write->wr_bytes_written);
> @@ -3588,17 +3594,14 @@ nfsd4_encode_exchange_id(struct nfsd4_compoundres *resp, __be32 nfserr,
>  	server_scope_sz = strlen(server_scope);
>  
>  	p = xdr_reserve_space(xdr,
> -		8 /* eir_clientid */ +
> -		4 /* eir_sequenceid */ +
> -		4 /* eir_flags */ +
> -		4 /* spr_how */);
> +		sizeof(clientid_t) /* eir_clientid */ +
> +		3 * sizeof(__be32) /* eir_sequenceid, eir_flags, spr_how */);
>  	if (!p)
>  		return nfserr_resource;
>  
> -	p = xdr_encode_opaque_fixed(p, &exid->clientid, 8);
> +	p = xdr_encode_opaque_fixed(p, &exid->clientid, sizeof(clientid_t));
>  	*p++ = cpu_to_be32(exid->seqid);
>  	*p++ = cpu_to_be32(exid->flags);
> -
>  	*p++ = cpu_to_be32(exid->spa_how);
>  
>  	switch (exid->spa_how) {
> @@ -3606,7 +3609,7 @@ nfsd4_encode_exchange_id(struct nfsd4_compoundres *resp, __be32 nfserr,
>  		break;
>  	case SP4_MACH_CRED:
>  		/* spo_must_enforce, spo_must_allow */
> -		p = xdr_reserve_space(xdr, 16);
> +		p = xdr_reserve_space(xdr, 4 * sizeof(__be32));
>  		if (!p)
>  			return nfserr_resource;
>  
> @@ -3623,12 +3626,12 @@ nfsd4_encode_exchange_id(struct nfsd4_compoundres *resp, __be32 nfserr,
>  	}
>  
>  	p = xdr_reserve_space(xdr,
> -		8 /* so_minor_id */ +
> -		4 /* so_major_id.len */ +
> -		(XDR_QUADLEN(major_id_sz) * 4) +
> -		4 /* eir_server_scope.len */ +
> -		(XDR_QUADLEN(server_scope_sz) * 4) +
> -		4 /* eir_server_impl_id.count (0) */);
> +		sizeof(__be64) /* so_minor_id */ +
> +		sizeof(__be32) /* so_major_id.len */ +
> +		ALIGN(major_id_sz, 4) +
> +		sizeof(__be32) /* eir_server_scope.len */ +
> +		ALIGN(server_scope_sz, 4) +
> +		sizeof(__be32) /* eir_server_impl_id.count (0) */);
>  	if (!p)
>  		return nfserr_resource;
>  
> @@ -3655,7 +3658,7 @@ nfsd4_encode_create_session(struct nfsd4_compoundres *resp, __be32 nfserr,
>  	if (nfserr)
>  		return nfserr;
>  
> -	p = xdr_reserve_space(xdr, 24);
> +	p = xdr_reserve_space(xdr, NFS4_MAX_SESSIONID_LEN + 2 * sizeof(__be32));
>  	if (!p)
>  		return nfserr_resource;
>  	p = xdr_encode_opaque_fixed(p, sess->sessionid.data,
> @@ -3663,7 +3666,7 @@ nfsd4_encode_create_session(struct nfsd4_compoundres *resp, __be32 nfserr,
>  	*p++ = cpu_to_be32(sess->seqid);
>  	*p++ = cpu_to_be32(sess->flags);
>  
> -	p = xdr_reserve_space(xdr, 28);
> +	p = xdr_reserve_space(xdr, 7 * sizeof(__be32));
>  	if (!p)
>  		return nfserr_resource;
>  	*p++ = cpu_to_be32(0); /* headerpadsz */
> @@ -3675,13 +3678,13 @@ nfsd4_encode_create_session(struct nfsd4_compoundres *resp, __be32 nfserr,
>  	*p++ = cpu_to_be32(sess->fore_channel.nr_rdma_attrs);
>  
>  	if (sess->fore_channel.nr_rdma_attrs) {
> -		p = xdr_reserve_space(xdr, 4);
> +		p = xdr_reserve_space(xdr, sizeof(__be32));
>  		if (!p)
>  			return nfserr_resource;
>  		*p++ = cpu_to_be32(sess->fore_channel.rdma_attrs);
>  	}
>  
> -	p = xdr_reserve_space(xdr, 28);
> +	p = xdr_reserve_space(xdr, 7 * sizeof(__be32));
>  	if (!p)
>  		return nfserr_resource;
>  	*p++ = cpu_to_be32(0); /* headerpadsz */
> @@ -3693,7 +3696,7 @@ nfsd4_encode_create_session(struct nfsd4_compoundres *resp, __be32 nfserr,
>  	*p++ = cpu_to_be32(sess->back_channel.nr_rdma_attrs);
>  
>  	if (sess->back_channel.nr_rdma_attrs) {
> -		p = xdr_reserve_space(xdr, 4);
> +		p = xdr_reserve_space(xdr, sizeof(__be32));
>  		if (!p)
>  			return nfserr_resource;
>  		*p++ = cpu_to_be32(sess->back_channel.rdma_attrs);
> @@ -3711,7 +3714,7 @@ nfsd4_encode_sequence(struct nfsd4_compoundres *resp, __be32 nfserr,
>  	if (nfserr)
>  		return nfserr;
>  
> -	p = xdr_reserve_space(xdr, NFS4_MAX_SESSIONID_LEN + 20);
> +	p = xdr_reserve_space(xdr, NFS4_MAX_SESSIONID_LEN + 5 * sizeof(__be32));
>  	if (!p)
>  		return nfserr_resource;
>  	p = xdr_encode_opaque_fixed(p, seq->sessionid.data,
> @@ -3738,7 +3741,7 @@ nfsd4_encode_test_stateid(struct nfsd4_compoundres *resp, __be32 nfserr,
>  	if (nfserr)
>  		return nfserr;
>  
> -	p = xdr_reserve_space(xdr, 4 + (4 * test_stateid->ts_num_ids));
> +	p = xdr_reserve_space(xdr, sizeof(__be32) + (sizeof(__be32) * test_stateid->ts_num_ids));
>  	if (!p)
>  		return nfserr_resource;
>  	*p++ = htonl(test_stateid->ts_num_ids);
> @@ -3863,7 +3866,7 @@ nfsd4_encode_operation(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
>  	nfsd4_enc encoder;
>  	__be32 *p;
>  
> -	p = xdr_reserve_space(xdr, 8);
> +	p = xdr_reserve_space(xdr, 2 * sizeof(__be32));
>  	if (!p) {
>  		WARN_ON_ONCE(1);
>  		return;
> @@ -3917,7 +3920,8 @@ nfsd4_encode_operation(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
>  	}
>  status:
>  	/* Note that op->status is already in network byte order: */
> -	write_bytes_to_xdr_buf(xdr->buf, post_err_offset - 4, &op->status, 4);
> +	write_bytes_to_xdr_buf(xdr->buf, post_err_offset - sizeof(__be32),
> +				&op->status, sizeof(op->status));
>  }
>  
>  /* 
> @@ -3936,7 +3940,7 @@ nfsd4_encode_replay(struct xdr_stream *xdr, struct nfsd4_op *op)
>  
>  	BUG_ON(!rp);
>  
> -	p = xdr_reserve_space(xdr, 8 + rp->rp_buflen);
> +	p = xdr_reserve_space(xdr, 2 * sizeof(__be32) + rp->rp_buflen);
>  	if (!p) {
>  		WARN_ON_ONCE(1);
>  		return;
> -- 
> 1.9.3
> 

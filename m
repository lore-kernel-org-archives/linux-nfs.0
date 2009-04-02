From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 0/21] nfsd41-for-2.6.30 review cleanup
Date: Fri, 03 Apr 2009 01:33:40 +0300
Message-ID: <49D53D44.4030102@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: pNFS Mailing List <pnfs@linux-nfs.org>,
	NFS list <linux-nfs@vger.kernel.org>,
	Andy Adamson <andros@netapp.com>
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:24936 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753172AbZDBWeg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 18:34:36 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bruce,

The following patches fix non-DRC review comments.
They are untested yet, but I wanted to send them out ASAP
so that people will have some time to comment on them before I
squash them in.

[PATCH 01/21] SQUASHME: nfsd41: conditionally decode_sequence in nfs4_xdr_dec_cb_recall
[PATCH 02/21] nfsd41: control nfsv4.1 svc via /proc/fs/nfsd/versions
[PATCH 03/21] SQUASHME: nfsd41: disable support for minorversion by default
[PATCH 04/21] SQUASHME: nfs41: reverse EXCHGID4_INVAL_FLAG_MASK_{A,R}
[PATCH 05/21] SQUASHME: nfsd41: reverse use of EXCHGID4_INVAL_FLAG_MASK_A
[PATCH 06/21] SQUASHME: nfsd41: simplify match_clientid_establishment logic
[PATCH 07/21] SQUASHME: simplify nfsd4_encode_sequence error handling
[PATCH 08/21] SQUASHME: simplify nfsd4_encode_create_session error handling
[PATCH 09/21] SQUASHME: simplify nfsd4_encode_exchange_id error handling
[PATCH 10/21] SQUASHME: nfsd41: document unenforced nfs41 compound ordering rules.
[PATCH 11/21] SQUASHME: nfsd41: embed an xdr_netobj in nfsd4_exchange_id
[PATCH 12/21] SQUASHME: nfsd41: return nfserr_serverfault for spa_how == SP4_MACH_CRED
[PATCH 13/21] SQUASHME: nfsd41: fix comment style in init_forechannel_attrs
[PATCH 14/21] SQUASHME: nfsd41: allocate struct nfsd4_session and slot table in one piece
[PATCH 15/21] SQUASHME: nfsd41: no need to INIT_LIST_HEAD in alloc_init_session just prior to list_add
[PATCH 16/21] SQUASHME: nfsd41: pass nfsd4_compoundres * to nfsd4_process_open1
[PATCH 17/21] nfsd: pass nfsd4_compound_state* to nfs4_preprocess_{state,seq}id_op
[PATCH 18/21] SQUASHME: nfsd41: calculate HAS_SESSION in nfs4_preprocess_stateid_op
[PATCH 19/21] SQUASHME: nfsd41: calculate HAS_SESSION in nfs4_preprocess_seqid_op
[PATCH 20/21] SQUASHME: Revert "nfsd41: Add Kconfig symbols for NFSv4.1"
[PATCH 21/21] SQUASHME: get rid of CONFIG_NFSD_V4_1

The review comments that were fixed are listed below.

Benny

================================================================================
Re: [pnfs] [PATCH 0/47] NFSv4.1 Sessions server code for 2.6.30
	fix nfs4_xdr_dec_cb_recall rpc_res==NULL case

[PATCH 01/21] SQUASHME: nfsd41: conditionally decode_sequence in nfs4_xdr_dec_cb_recall

================================================================================
Re: [PATCH v2 04/47] nfs41: common protocol definitions
> Would it be less confusing just to use !EXCHGID_FLAG_MASK_A and
> !EXCHGID_FLAG_MASK_R everywhere?

[PATCH 04/21] SQUASHME: nfs41: reverse EXCHGID4_INVAL_FLAG_MASK_{A,R}
[PATCH 05/21] SQUASHME: nfsd41: reverse use of EXCHGID4_INVAL_FLAG_MASK_A

================================================================================
Re: [PATCH v2 06/47] nfsd41: Add Kconfig symbols for NFSv4.1
> Stupid question: do we need CONFIG_NFSD_V4_1 at all?  How many people
> > will want to build a kernel with v4.0 but not v4.1?

> (And: do we have an interface that allows turning off 4.1 at run-time?
> > > That's more important than the config option.)

[PATCH 02/21] nfsd41: control nfsv4.1 svc via /proc/fs/nfsd/versions
[PATCH 20/21] SQUASHME: Revert "nfsd41: Add Kconfig symbols for NFSv4.1"
[PATCH 21/21] SQUASHME: get rid of CONFIG_NFSD_V4_1

================================================================================
Re: [PATCH v2 07/47] nfsd41: define nfs41 error codes
fix NFSERR_REPLAY_ME on rebase

Fixed in rebase

================================================================================
RE: [pnfs] [PATCH v2 15/47] nfsd41: exchange_id operation
> Would it simplify things just to embed an xdr_netobj in
> nfsd4_exchange_id?

[PATCH 11/21] SQUASHME: nfsd41: embed an xdr_netobj in nfsd4_exchange_id

================================================================================
RE: [pnfs] [PATCH v2 15/47] nfsd41: exchange_id operation (cont.)

>> +	/* Currently only support SP4_NONE */
>> >> +	if (exid->spa_how != SP4_NONE)
>> >> +		return nfserr_encr_alg_unsupp;
> > 
> > Isn't support for the others mandatory?  Let's just make this
> > serverfault, in that case--this is a bug in the server.  It'll be a
> > reminder that we need to fix this....

True. nfserr_encr_alg_unsupp is valid only for ssp_encr_algs.
Andy, I believe you're the author of this. OK with you to return
nfserr_serverfault instead?

[PATCH 12/21] SQUASHME: nfsd41: return nfserr_serverfault for spa_how == SP4_MACH_CRED

================================================================================
Re: [pnfs] [PATCH v2 16/47] nfsd41: match clientid establishment method
simplify match_clientid_establishment, bool use_exchange_id

[PATCH 06/21] SQUASHME: nfsd41: simplify match_clientid_establishment logic

================================================================================
Re: [PATCH v2 17/47] nfsd41: sequence operation
nfsd4_encode_sequence
> +	if (nfserr)
> > +		goto out;
Just 'return nfserr'.  I don't see the point of the goto if it's
literally just replacing a return.

[PATCH 07/21] SQUASHME: simplify nfsd4_encode_sequence error handling
[PATCH 08/21] SQUASHME: simplify nfsd4_encode_create_session error handling
[PATCH 09/21] SQUASHME: simplify nfsd4_encode_exchange_id error handling

================================================================================
Re: [pnfs] [PATCH v2 18/47] nfsd41: enforce NFS4ERR_SEQUENCE_POS operation order rules
update Doc and wiki TODO about need to enforce rules for EXCHANGE_ID as
last op and NFS4ERR_NOT_ONLY_OP.

[PATCH 10/21] SQUASHME: nfsd41: document unenforced nfs41 compound ordering rules.

================================================================================
Re: [PATCH v2 23/47] nfsd41: create_session operation
fixup style comments.

[PATCH 13/21] SQUASHME: nfsd41: fix comment style in init_forechannel_attrs

fix alloc_init_session

[PATCH 14/21] SQUASHME: nfsd41: allocate struct nfsd4_session and slot table in one piece
[PATCH 15/21] SQUASHME: nfsd41: no need to INIT_LIST_HEAD in alloc_init_session just prior to list_add

================================================================================
Re: [PATCH v2 27/47] nfsd41: stateid handling
> +	status = nfsd4_process_open1(rqstp, open);
Seems all your using is the cstate--maybe pass that instead?

[PATCH 16/21] SQUASHME: nfsd41: pass nfsd4_compoundres * to nfsd4_process_open1

================================================================================
Re: [PATCH v2 27/47] nfsd41: stateid handling (cont.)
> +	if (nfsd4_has_session(cstate))
> > +		flags |= HAS_SESSION;
> >  	nfs4_lock_state();
> >  	/* check stateid */
> >  	if ((status = nfs4_preprocess_stateid_op(&cstate->current_fh,
You could pass the cstate to preprocess_stateid_op instead of
current_fh, and let it do the nfsd4_has_session check instead of making
all the callers do it.

[PATCH 17/21] nfsd: pass nfsd4_compound_state* to nfs4_preprocess_{state,seq}id_op
[PATCH 18/21] SQUASHME: nfsd41: calculate HAS_SESSION in nfs4_preprocess_stateid_op
[PATCH 19/21] SQUASHME: nfsd41: calculate HAS_SESSION in nfs4_preprocess_seqid_op



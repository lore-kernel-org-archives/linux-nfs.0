From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] compound header status
Date: Thu, 21 Feb 2008 16:37:56 -0600
Message-ID: <47BDFD44.9020301@panasas.com>
References: <E472128B1EB43941B4E7FB268020C89B054968F1@riverside.int.panasas.com> <1203628540.8258.28.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org, nfsv4@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.224]:35440 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935118AbYBUWiE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Feb 2008 17:38:04 -0500
Received: by wr-out-0506.google.com with SMTP id c48so315405wra.23
        for <linux-nfs@vger.kernel.org>; Thu, 21 Feb 2008 14:38:03 -0800 (PST)
In-Reply-To: <1203628540.8258.28.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Feb. 21, 2008, 15:15 -0600, Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> On Thu, 2008-02-21 at 00:18 -0500, Halevy, Benny wrote:
>> Trond, we had a discussion today in Austin about the COMPOUND result header
>> status.  Looking at fs/nfs/nfs4xdr.c we saw that some decoding routines
>> return an error based on hdr.status after all the compound operations
>> decoding completed successfully.
>>
>> For example:
>> static int nfs4_xdr_dec_setclientid_confirm(struct rpc_rqst *req, __be32 *p, struct nfs_fsinfo *fsinfo)
>> {
>> 	struct xdr_stream xdr;
>> 	struct compound_hdr hdr;
>> 	int status;
>>
>> 	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
>> 	status = decode_compound_hdr(&xdr, &hdr);
>> 	if (!status)
>> 		status = decode_setclientid_confirm(&xdr);
>> 	if (!status)
>> 		status = decode_putrootfh(&xdr);
>> 	if (!status)
>> 		status = decode_fsinfo(&xdr, fsinfo);
>> 	if (!status)
>> 		status = -nfs4_stat_to_errno(hdr.status);
>> 		                             ^^^^^^^^^^
>> 	return status;
>> }
>>
>> It seems like this is unneeded since hdr.status must be NFS_OK if all operations
>> in the compound succeeded (and assuming we decode the results from all ops we sent).
>> The first error will be found by decode_op_hdr called by any of the decoding
>> routines for the individual ops.
>> If hdr.status contains an error in this case, the server must be broken, isn't it?
> 
> Agreed. I can only see 3 cases where we do this, but it would be nice to
> fix them.

Cool. The cases we do need to look at hdr.status are when we fail to
decode the op header, i.e. we ran out of bytes to code, or the opnum
doesn't match what we expect.  Then, if hdr.status != NFS_OK we should
translate and return this error rather than a generic -EIO;

> 
>> One more thing, all use sites for nfs4_stat_to_errno negate its return value
>> so it might make sense to return a negative error from nfs4_stat_to_errno rather
>> than negating its return value everywhere.
> 
> If we do, then we should fix up nfs_stat_to_errno() too. It will just
> get confusing if we establish differing standards between NFSv2/v3 and
> NFSv4.

Agreed.  This will be in a separate patch of course.

Benny

> 
> Trond
> _______________________________________________
> pNFS mailing list
> pNFS@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/pnfs


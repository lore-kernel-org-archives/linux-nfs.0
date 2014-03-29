Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f181.google.com ([209.85.213.181]:34794 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751844AbaC2TtI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 29 Mar 2014 15:49:08 -0400
Received: by mail-ig0-f181.google.com with SMTP id h18so2123648igc.8
        for <linux-nfs@vger.kernel.org>; Sat, 29 Mar 2014 12:49:08 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: [PATCH 2/2] nfsd: Don't return NFS4ERR_RESTOREFH for NFSv4.1+
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <20140329193456.GE11085@fieldses.org>
Date: Sat, 29 Mar 2014 15:49:05 -0400
Cc: Idan Kedar <idank@primarydata.com>, linux-nfs@vger.kernel.org
Message-Id: <CDBA9E4B-1C09-4952-B285-83B1580397D7@primarydata.com>
References: <1396118619-12771-1-git-send-email-trond.myklebust@primarydata.com> <1396118619-12771-2-git-send-email-trond.myklebust@primarydata.com> <20140329193456.GE11085@fieldses.org>
To: Dr Fields James Bruce <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 29, 2014, at 15:34, J. Bruce Fields <bfields@fieldses.org> wrote:

> On Sat, Mar 29, 2014 at 02:43:39PM -0400, Trond Myklebust wrote:
>> RFC5661 obsoletes NFS4ERR_RESTOREFH in favour of NFS4ERR_NOFILEHANDLE.
> 
> Looks right.  Any objection to just making this nfserr_restorefh in the
> 4.0 case as well?  Hard to imagine how that could cause a 4.0 client any
> problem.

You mean make both cases return nfserr_nofilehandle (as per RFC5661), right? So, I agree that most clients should handle that, but the problem is that RFC3530bis does not allow it.

> 
> --b.
> 
>> 
>> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>> ---
>> fs/nfsd/nfs4proc.c | 5 ++++-
>> 1 file changed, 4 insertions(+), 1 deletion(-)
>> 
>> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
>> index 82189b208af3..eeee4418d44a 100644
>> --- a/fs/nfsd/nfs4proc.c
>> +++ b/fs/nfsd/nfs4proc.c
>> @@ -536,8 +536,11 @@ static __be32
>> nfsd4_restorefh(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>> 		void *arg)
>> {
>> -	if (!cstate->save_fh.fh_dentry)
>> +	if (!cstate->save_fh.fh_dentry) {
>> +		if (nfsd4_has_session(cstate))
>> +			return nfserr_nofilehandle;
>> 		return nfserr_restorefh;
>> +	}
>> 
>> 	fh_dup2(&cstate->current_fh, &cstate->save_fh);
>> 	if (HAS_STATE_ID(cstate, SAVED_STATE_ID_FLAG)) {
>> -- 
>> 1.9.0
>> 

_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:47630 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752655Ab1GHUDU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Jul 2011 16:03:20 -0400
Date: Fri, 8 Jul 2011 16:03:19 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/2 v2] nfsd41: check the size of request
Message-ID: <20110708200319.GC13886@fieldses.org>
References: <4E0EDEBE.8040902@cn.fujitsu.com>
 <20110706164306.GC30349@fieldses.org>
 <4E16CA48.3030308@cn.fujitsu.com>
Content-Type: text/plain; charset=utf-8
In-Reply-To: <4E16CA48.3030308@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Jul 08, 2011 at 05:13:44PM +0800, Mi Jinlong wrote:
> 
> 
> J. Bruce Fields 写道:
> > On Sat, Jul 02, 2011 at 05:02:54PM +0800, Mi Jinlong wrote:
> >> This patch just check request's size when it consists SEQUENCE.
> >>
> >> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
> >> ---
> >>  fs/nfsd/nfs4state.c |   16 ++++++++++++++++
> >>  1 files changed, 16 insertions(+), 0 deletions(-)
> >>
> >> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> >> index e98f3c2..17e30bf 100644
> >> --- a/fs/nfsd/nfs4state.c
> >> +++ b/fs/nfsd/nfs4state.c
> >> @@ -1736,6 +1736,21 @@ static bool nfsd4_session_too_many_ops(struct svc_rqst *rqstp, struct nfsd4_sess
> >>  	return args->opcnt > session->se_fchannel.maxops;
> >>  }
> >>  
> >> +static int nfsd4_check_request_size(struct nfsd4_compoundargs *args,
> >> +				    struct nfsd4_session *session)
> >> +{
> >> +	struct xdr_buf *xb = &args->rqstp->rq_arg;
> >> +
> >> +	/* Only SEQUENCE operation */
> >> +	if (args->opcnt == 1)
> >> +		return 0;
> > 
> > Do we need this special check?
> > 
> > Sure, it's possible that a crazy client could set se_fchannel.maxreq_sz
> > too small, and then we'd get a failure here even when they only sent a
> > single sequence.  Such a client gets what it deserves.
> 
>   If kernel err out when crazy client sets maxreq_sz to small, 
>   only SEQUENCE operation's size will never exceed maxreq_sz.
> 
>   According to RFC5661 18.36.3, if client set maxreq_sz too small, 
>   the server SHOULD return NFS4ERR_TOOSMALL in the CREATE_SESSION reply.

The rpc header size can vary.  If you reject any CREATE_SESSION attempts
with maxreq_sz smaller than

	largest possible rpc header + SEQUENCE

then you risk rejecting some legitimate CREATE_SESSIONs.

But if you allow maxreq_sz's less than that, then it becomes possible
for a client to send a single-SEQUENCE compound that still exceeds
maxreq_sz.

So let's not try to safe every broken client from itself.  Instead,
let's keep things simple, catch those client errors that are easy to
catch, and that we know are errors, and don't worry about the rest.

--b.

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:60550 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932820AbcHXNid (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 24 Aug 2016 09:38:33 -0400
Date: Wed, 24 Aug 2016 09:38:30 -0400
From: Fields Bruce James <bfields@fieldses.org>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: Lever Chuck <chuck.lever@oracle.com>,
        Schumaker Anna <anna.schumaker@netapp.com>,
        List Linux RDMA Mailing <linux-rdma@vger.kernel.org>,
        List Linux NFS Mailing <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 1/6] SUNRPC: Silence WARN_ON when NFSv4.1 over RDMA is
 in use
Message-ID: <20160824133830.GD3938@fieldses.org>
References: <20160822185459.12076.43516.stgit@klimt.1015granger.net>
 <20160822185742.12076.34446.stgit@klimt.1015granger.net>
 <3E0207D8-CFB2-4233-B92B-165B10E9920E@oracle.com>
 <20160823205355.GA29452@fieldses.org>
 <AD25F201-01A4-4F4F-BAE7-9E984E12EE8D@oracle.com>
 <BB84506B-BC92-4325-A81C-4BC7D39F471C@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <BB84506B-BC92-4325-A81C-4BC7D39F471C@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 23, 2016 at 10:21:40PM +0000, Trond Myklebust wrote:
> 
> > On Aug 23, 2016, at 17:05, Chuck Lever <chuck.lever@oracle.com> wrote:
> > 
> >> 
> >> On Aug 23, 2016, at 4:53 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> >> 
> >> On Tue, Aug 23, 2016 at 01:39:15PM -0400, Chuck Lever wrote:
> >>> Hi Bruce-
> >>> 
> >>> 
> >>>> On Aug 22, 2016, at 2:57 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> >>>> 
> >>>> Using NFSv4.1 on RDMA should be safe, so broaden the new checks in
> >>>> rpc_create().
> >>>> 
> >>>> WARN_ON_ONCE is used, matching most other WARN call sites in clnt.c.
> >>>> 
> >>>> Fixes: 39a9beab5acb ("rpc: share one xps between all backchannels")
> >>>> Fixes: d50039ea5ee6 ("nfsd4/rpc: move backchannel create logic...")
> >>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> >>>> ---
> >>> 
> >>> Do you want to take this, or should it go through Trond/Anna ?
> >> 
> >> I don't care, feel free to add my reviewed-by: if it goes through
> >> someone else.
> >> 
> >> Looks like this should be for 4.8 (and stable), not 4.9?
> > 
> > I won't disagree with that.
> > 
> > I think Trond or Anna need to weigh in on all questions
> > (who takes it, does it go to stable as well).
> 
> If you want it in for 4.8, then I can pull it in together with the current bugfixes. Does that work for everyone?

That'd be great, thanks.--b.

> 
> > 
> > 
> >> --b.
> >> 
> >>> 
> >>> 
> >>>> net/sunrpc/clnt.c |    4 ++--
> >>>> 1 file changed, 2 insertions(+), 2 deletions(-)
> >>>> 
> >>>> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> >>>> index 7f79fb7..66f23b3 100644
> >>>> --- a/net/sunrpc/clnt.c
> >>>> +++ b/net/sunrpc/clnt.c
> >>>> @@ -453,7 +453,7 @@ static struct rpc_clnt *rpc_create_xprt(struct rpc_create_args *args,
> >>>> 	struct rpc_xprt_switch *xps;
> >>>> 
> >>>> 	if (args->bc_xprt && args->bc_xprt->xpt_bc_xps) {
> >>>> -		WARN_ON(args->protocol != XPRT_TRANSPORT_BC_TCP);
> >>>> +		WARN_ON_ONCE(!(args->protocol & XPRT_TRANSPORT_BC));
> >>>> 		xps = args->bc_xprt->xpt_bc_xps;
> >>>> 		xprt_switch_get(xps);
> >>>> 	} else {
> >>>> @@ -520,7 +520,7 @@ struct rpc_clnt *rpc_create(struct rpc_create_args *args)
> >>>> 	char servername[48];
> >>>> 
> >>>> 	if (args->bc_xprt) {
> >>>> -		WARN_ON(args->protocol != XPRT_TRANSPORT_BC_TCP);
> >>>> +		WARN_ON_ONCE(!(args->protocol & XPRT_TRANSPORT_BC));
> >>>> 		xprt = args->bc_xprt->xpt_bc_xprt;
> >>>> 		if (xprt) {
> >>>> 			xprt_get(xprt);
> >>>> 
> >>>> --
> >>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> >>>> the body of a message to majordomo@vger.kernel.org
> >>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >>> 
> >>> --
> >>> Chuck Lever
> > 
> > --
> > Chuck Lever

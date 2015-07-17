Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:36184 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753936AbbGQPyY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Jul 2015 11:54:24 -0400
Date: Fri, 17 Jul 2015 11:54:23 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 01/14] nfsd: Add layouts checking for state resources
Message-ID: <20150717155423.GB6263@fieldses.org>
References: <55A384B1.8030207@gmail.com>
 <55A384DD.1000800@gmail.com>
 <20150715150311.GA19616@fieldses.org>
 <55A7174D.3070007@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <55A7174D.3070007@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 16, 2015 at 10:30:37AM +0800, Kinglong Mee wrote:
> On 7/15/2015 23:03, J. Bruce Fields wrote:
> > On Mon, Jul 13, 2015 at 05:29:01PM +0800, Kinglong Mee wrote:
> >> Layout is a state resource, nfsd should check it too.
> >>
> >> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> >> ---
> >>  fs/nfsd/nfs4state.c | 6 ++++--
> >>  1 file changed, 4 insertions(+), 2 deletions(-)
> >>
> >> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> >> index 61dfb33..e0a4556 100644
> >> --- a/fs/nfsd/nfs4state.c
> >> +++ b/fs/nfsd/nfs4state.c
> >> @@ -2241,6 +2241,7 @@ static bool client_has_state(struct nfs4_client *clp)
> >>  	 * Also note we should probably be using this in 4.0 case too.
> >>  	 */
> >>  	return !list_empty(&clp->cl_openowners)
> >> +		|| !list_empty(&clp->cl_lo_states)
> >>  		|| !list_empty(&clp->cl_delegations)
> >>  		|| !list_empty(&clp->cl_sessions);
> >>  }
> >> @@ -4257,8 +4258,9 @@ nfsd4_renew(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> >>  		goto out;
> >>  	clp = cstate->clp;
> >>  	status = nfserr_cb_path_down;
> >> -	if (!list_empty(&clp->cl_delegations)
> >> -			&& clp->cl_cb_state != NFSD4_CB_UP)
> >> +	if ((!list_empty(&clp->cl_delegations)
> >> +	     || !list_empty(&clp->cl_lo_states))
> > 
> > nfsd4_renew is NFSv4.0 only, so I don't think this part is necessary.
> > 
> > That said, it's harmless--why don't we just call client_has_state() here
> > instead?
> 
> I don't think so.
> 
> NFSv4.0's callback path is used for delegation recalling only,
> without delegation, callback path is useless.
> 
> Also, describing in rfc3530,
> 
>    When the client holds delegations, it needs to use RENEW to detect
>    when the server has determined that the callback path is down.  When
>    the server has made such a determination, only the RENEW operation
>    will renew the lease on delegations.  If the server determines the
>    callback path is down, it returns NFS4ERR_CB_PATH_DOWN.  Even though
>    it returns NFS4ERR_CB_PATH_DOWN, the server MUST renew the lease on
>    the record locks and share reservations that the client has
>    established on the server.
> 
> I will drop the second modify in version 2.

Oh, you're right, the cl_openowners check would be wrong for the renew
case.

Applying v2, thanks.--b.

> 
> thanks,
> Kinglong Mee

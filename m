Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:36186 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752046AbbGQP6q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Jul 2015 11:58:46 -0400
Date: Fri, 17 Jul 2015 11:58:46 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 02/14] nfsd: Add missing gen_confirm in
 nfsd4_setclientid()
Message-ID: <20150717155846.GC6263@fieldses.org>
References: <55A384B1.8030207@gmail.com>
 <55A38505.6040405@gmail.com>
 <20150715204748.GA21669@fieldses.org>
 <20150715204950.GB21669@fieldses.org>
 <55A726A0.5090907@gmail.com>
 <55A72A1F.7060507@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <55A72A1F.7060507@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 16, 2015 at 11:50:55AM +0800, Kinglong Mee wrote:
> On 7/16/2015 11:36, Kinglong Mee wrote:
> > On 7/16/2015 04:49, J. Bruce Fields wrote:
> >> On Wed, Jul 15, 2015 at 04:47:48PM -0400, J. Bruce Fields wrote:
> >>> On Mon, Jul 13, 2015 at 05:29:41PM +0800, Kinglong Mee wrote:
> >>>> Commit 294ac32e99 "nfsd: protect clid and verifier generation with client_lock"
> >>>> have moved gen_confirm() to gen_clid().
> >>>
> >>> This means the statement in that earlier commit is wrong:
> >>>
> >>> 	
> >>> 	With this, there's no need to keep two counters as they'd always
> >>> 	be in sync anyway, so just use the clientid_counter for both.
> >>>
> >>> Looks to me like this may need a separate counter to eliminate the
> >>> possibibility of returning the same confirm twice for a one clientid?
> > 
> > Yes, nfsd will generate same confirm for one clientid in one second.
> > 
> >  verf[0] = (__force __be32)jiffies;
> >  verf[1] = (__force __be32)nn->clientid_counter;
> > 
> > for case 1: probable callback update, the new unconf client needs
> > a different confirm.
> 
> Ignore this patch, and just revert commit 294ac32e99 
> "nfsd: protect clid and verifier generation with client_lock"
> is a better solve.

We can't revert that completely, it does fix a real locking bug at
least, I think.

I'd agree to reinstating a separate counter for the verifier.  That
verifier probably also needs to be per-network namespace to make the
per-network-namespace locking correct.

--b.

> 
> thanks,
> Kinglong Mee
> 
> > 
> > Rereading rfc7530,
> >    x  be the value of the client.id subfield of the SETCLIENTID4args
> >       structure.
> > 
> >    v  be the value of the client.verifier subfield of the
> >       SETCLIENTID4args structure.
> > 
> >    c  be the value of the client ID field returned in the
> >       SETCLIENTID4resok structure.
> > 
> >    k  represent the value combination of the callback and callback_ident
> >       fields of the SETCLIENTID4args structure.
> > 
> >    s  be the setclientid_confirm value returned in the SETCLIENTID4resok
> >       structure.
> > 
> >    { v, x, c, k, s }  be a quintuple for a client record.  A client
> >       record is confirmed if there has been a SETCLIENTID_CONFIRM
> >       operation to confirm it.  Otherwise, it is unconfirmed.  An
> >       unconfirmed record is established by a SETCLIENTID call.
> > 
> > ... /* case 1: probable callback update */ ... 
> > 
> >    o  The server checks if it has recorded a confirmed record for { v,
> >       x, c, l, s }, where l may or may not equal k.  If so, and since
> >       the id verifier v of the request matches that which is confirmed
> >       and recorded, the server treats this as a probable callback
> >       information update and records an unconfirmed { v, x, c, k, t }
> >       and leaves the confirmed { v, x, c, l, s } in place, such that
> >       t != s.  It does not matter whether k equals l or not.  Any
> >       pre-existing unconfirmed { v, x, c, *, * } is removed.
> > 
> >       The server returns { c, t }.  It is indeed returning the old
> >       clientid4 value c, because the client apparently only wants to
> >       update callback value k to value l.  It's possible this request is
> >       one from the Byzantine router that has stale callback information,
> >       but this is not a problem.  The callback information update is
> >       only confirmed if followed up by a SETCLIENTID_CONFIRM { c, t }.
> > 
> >       The server awaits confirmation of k via SETCLIENTID_CONFIRM
> >       { c, t }.
> > 
> >       The server does NOT remove client (lock/share/delegation) state
> >       for x.
> > 
> >>
> >> (but frankly I can never completely review changes to the
> >> setclientid/setclientid_confirm behavior without rereading RFC 7530
> >> 16.33.5 every time, which is a slog.  Might help to contrive a pynfs
> >> test derived from that text which tests for this particular behavior.)
> >>
> > 
> > Make sense.
> > I will make it later.
> > 
> > thanks,
> > Kinglong Mee
> > 
> > 
> >>>
> >>> --b.
> >>>
> >>>>
> >>>> After it, setclientid will return a bad reply with all zero confirms
> >>>> after copy_clid().
> >>>>
> >>>> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> >>>> ---
> >>>>  fs/nfsd/nfs4state.c | 5 +++--
> >>>>  1 file changed, 3 insertions(+), 2 deletions(-)
> >>>>
> >>>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> >>>> index e0a4556..b1f84fc 100644
> >>>> --- a/fs/nfsd/nfs4state.c
> >>>> +++ b/fs/nfsd/nfs4state.c
> >>>> @@ -3042,10 +3042,11 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> >>>>  	unconf = find_unconfirmed_client_by_name(&clname, nn);
> >>>>  	if (unconf)
> >>>>  		unhash_client_locked(unconf);
> >>>> -	if (conf && same_verf(&conf->cl_verifier, &clverifier))
> >>>> +	if (conf && same_verf(&conf->cl_verifier, &clverifier)) {
> >>>>  		/* case 1: probable callback update */
> >>>>  		copy_clid(new, conf);
> >>>> -	else /* case 4 (new client) or cases 2, 3 (client reboot): */
> >>>> +		gen_confirm(new, nn);
> >>>> +	} else /* case 4 (new client) or cases 2, 3 (client reboot): */
> >>>>  		gen_clid(new, nn);
> >>>>  	new->cl_minorversion = 0;
> >>>>  	gen_callback(new, setclid, rqstp);
> >>>> -- 
> >>>> 2.4.3
> >>
> > 

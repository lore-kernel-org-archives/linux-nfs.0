From: "Labiaga, Ricardo" <Ricardo.Labiaga@netapp.com>
Subject: RE: [PATCH v2 40/47] nfsd41: cb_sequence callback
Date: Thu, 2 Apr 2009 18:06:55 -0700
Message-ID: <273FE88A07F5D445824060902F70034405026F00@SACMVEXC1-PRD.hq.netapp.com>
References: <20090402205408.GA18195@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <linux-nfs@vger.kernel.org>, <pnfs@linux-nfs.org>
To: "J. Bruce Fields" <bfields@fieldses.org>,
	"Benny Halevy" <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:6345 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752148AbZDCBHs convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 21:07:48 -0400
In-Reply-To: <20090402205408.GA18195@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: J. Bruce Fields [mailto:bfields@fieldses.org]
> Sent: Thursday, April 02, 2009 1:54 PM
> To: Benny Halevy
> Cc: linux-nfs@vger.kernel.org; pnfs@linux-nfs.org; Labiaga, Ricardo
> Subject: Re: [PATCH v2 40/47] nfsd41: cb_sequence callback
> 
> On Thu, Apr 02, 2009 at 10:34:55PM +0300, Benny Halevy wrote:
> > On Apr. 02, 2009, 22:27 +0300, "J. Bruce Fields"
<bfields@fieldses.org>
> wrote:
> > > On Thu, Apr 02, 2009 at 10:20:08PM +0300, Benny Halevy wrote:
> > >> On Apr. 02, 2009, 21:51 +0300, "J. Bruce Fields"
> <bfields@fieldses.org> wrote:
> > >>> On Thu, Apr 02, 2009 at 11:47:24AM +0300, Benny Halevy wrote:
> > >>>> On Apr. 01, 2009, 7:39 +0300, "J. Bruce Fields"
> <bfields@fieldses.org> wrote:
> > >>>>>> @@ -503,6 +589,38 @@ nfsd4_probe_callback(struct nfs4_client
> *clp)
> > >>>>>>  	return;
> > >>>>>>  }
> > >>>>>>
> > >>>>>> +#if defined(CONFIG_NFSD_V4_1)
> > >>>>>> +/*
> > >>>>>> + * FIXME: cb_sequence should support referring call lists,
> cachethis, and
> > >>>>>> + * multiple slots
> > >>>>>> + */
> > >>>>>> +static int
> > >>>>>> +nfs41_cb_sequence_setup(struct nfs4_client *clp, struct
> nfsd4_cb_sequence *args)
> > >>>>>> +{
> > >>>>>> +	u32 *ptr = (u32 *)clp->cl_sessionid.data;
> > >>>>>> +
> > >>>>>> +	dprintk("%s: %u:%u:%u:%u\n", __func__,
> > >>>>>> +		ptr[0], ptr[1], ptr[2], ptr[3]);
> > >>>>>> +
> > >>>>>> +	mutex_lock(&clp->cl_cb_mutex);
> > >>>>> We shouldn't be holding a mutex across a callback.  Why is
this
> needed?
> > >>>> Just a simple way to limit concurrency to 1 and not deal with
> > >>>> multiple slots on the callback path.
> > >>> OK.  We should work out some sort of asynchronous equivalent.
> > >> OK.
> > >>
> > >>> How is the client side currently waiting on slots?
> > >> Currently it has a single slot and a single
> > >> (NFS41_BC_MIN_CALLBACKS) preallocated rpc_rqst.
> > >> If it gets more calls than that, concurrently, it will
> > >> drop its end of the line using
> > >> set_bit(XPRT_CLOSE_WAIT, &xprt->state)
> > >>
> > >> (Ricardo, please keep me honest :)
> > >
> > > I was wondering about the rpc client as used on the nfs client,
not
> the
> >
> > you mean rpc client as used on the nfs server? :)
> 
> I meant the rpc client on the nfs client: when the nfs client sends an
> rpc on the forechannel it has to wait for a session slot.  How does it
> do it (is it putting the rpc task on some queue?), and can the
callback
> client (on the nfs server) do the same thing?
> 

Yes, the NFS client uses a slot table for the forechannel 'struct
nfs4_slot_table' and a slot table for the backchannel.  Tasks sleep on
an rpc_wait_queue if there are no available slots.  Used/ unused slots
are tracked with a bit map array.  When the reply is received on a slot,
the next available task is awaken.

Yes, the callback client can certainly do the same thing.  Today, the
Linux client backchannel only advertises a single slot (need to check
what Solaris does).  So against Linux, having more than one slot doesn't
buy the server much right now.

Is this something that can be addressed as an enhancement later on, or
do you need this implemented right away?

- ricardo

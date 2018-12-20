Return-Path: <SRS0=5+aP=O5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9997FC43387
	for <linux-nfs@archiver.kernel.org>; Thu, 20 Dec 2018 17:29:57 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 676DA217D8
	for <linux-nfs@archiver.kernel.org>; Thu, 20 Dec 2018 17:29:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1545326997;
	bh=3VrEFpRLadK4E8ND27unowX5zQLfMlUgQUDjttcYZR0=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:List-ID:From;
	b=Gjz6DGSjtGOG6yDyvB+HChQx7FpSB4S2d1nXyJOcDiGQ7JyyF4PuAtutOLtFdvhQj
	 UWUC+j158NnffMbQEF0UT/nX8TVj79jLMgkKOisBPUXCq8mw+n9LTQXkkDuWCICEYs
	 9yNfNETubKFYNWOPhwjB9b8LSltuM6wAhN6v358g=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1731586AbeLTR34 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 20 Dec 2018 12:29:56 -0500
Received: from mail.kernel.org ([198.145.29.99]:33172 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728221AbeLTR34 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 20 Dec 2018 12:29:56 -0500
Received: from tleilax.poochiereds.net (cpe-71-70-156-158.nc.res.rr.com [71.70.156.158])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id AE44F20811;
        Thu, 20 Dec 2018 17:29:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1545326995;
        bh=3VrEFpRLadK4E8ND27unowX5zQLfMlUgQUDjttcYZR0=;
        h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
        b=BjlZYNzqcoUW6442n1EvBgNfktMPw8R7bbx7ovzlRrAOctaz5Ms/k/GROsHiIrQG9
         3vZsJ0ONn0au7pE0Lr1Pz44fHtm4U6oi6ByvmnMP3qtEVG1ygdtV2Q0HWdS3dBAVEz
         Fa37QDbkSo1upL3/vlTxTpRrc5pZX3SNjaLtG0Fs=
Message-ID: <901adec26f1fd20259bd3e50d963f304b903d312.camel@kernel.org>
Subject: Re: [PATCH v2 3/3] nfsd: keep a tally of RECLAIM_COMPLETE
 operations when using nfsdcld
From:   Jeff Layton <jlayton@kernel.org>
To:     "J. Bruce Fields" <bfields@fieldses.org>,
        Scott Mayhew <smayhew@redhat.com>
Cc:     linux-nfs@vger.kernel.org
Date:   Thu, 20 Dec 2018 12:29:43 -0500
In-Reply-To: <20181219222147.GA31570@fieldses.org>
References: <20181218142926.27933-1-smayhew@redhat.com>
         <20181218142926.27933-4-smayhew@redhat.com>
         <20181219183600.GC28626@fieldses.org>
         <20181219220545.GS27213@coeurl.usersys.redhat.com>
         <20181219222147.GA31570@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.3 (3.30.3-1.fc29) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, 2018-12-19 at 17:21 -0500, J. Bruce Fields wrote:
> On Wed, Dec 19, 2018 at 05:05:45PM -0500, Scott Mayhew wrote:
> > On Wed, 19 Dec 2018, J. Bruce Fields wrote:
> > 
> > > On Tue, Dec 18, 2018 at 09:29:26AM -0500, Scott Mayhew wrote:
> > > > +	if (!nfsd4_find_reclaim_client(clp->cl_name, nn))
> > > > +		return;
> > > > +	if (atomic_inc_return(&nn->nr_reclaim_complete) ==
> > > > +			nn->reclaim_str_hashtbl_size) {
> > > > +		printk(KERN_INFO "NFSD: all clients done reclaiming, ending NFSv4 grace period (net %x)\n",
> > > > +				clp->net->ns.inum);
> > > > +		nfsd4_end_grace(nn);
> > > > +	}
> > > > +}
> > > > +
> > > > +static void dec_reclaim_complete(struct nfs4_client *clp)
> > > > +{
> > > > +	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
> > > > +
> > > > +	if (!nn->track_reclaim_completes)
> > > > +		return;
> > > > +	if (!test_bit(NFSD4_CLIENT_RECLAIM_COMPLETE, &clp->cl_flags))
> > > > +		return;
> > > > +	if (nfsd4_find_reclaim_client(clp->cl_name, nn))
> > > > +		atomic_dec(&nn->nr_reclaim_complete);
> > > > +}
> > > > +
> > > >  static void expire_client(struct nfs4_client *clp)
> > > >  {
> > > >  	unhash_client(clp);
> > > >  	nfsd4_client_record_remove(clp);
> > > > +	dec_reclaim_complete(clp);
> > > >  	__destroy_client(clp);
> > > >  }
> > > 
> > > This doesn't look right to me.  If a client reclaims and then
> > > immediately calls DESTROY_CLIENTID or something--that should still count
> > > as a reclaim, and that shouldn't prevent us from ending the grace period
> > > early.
> > > 
> > > I think dec_reclaim_complete is unnecessary.
> > 
> > What if a client sends a RECLAIM_COMPLETE, then reboots and sends an
> > EXCHANGE_ID, CREATE_SESSION, and RECLAIM_COMPLETE while the server is
> > still in grace?  The count would be too high then and the server could
> > exit grace before all the clients have reclaimed.  I actually added
> > that at Jeff's suggestion because he was seeing it with nfs-ganesha.  
> 
> Oh boy.
> 
> (Thinks.)
> 
> Once it issues a DESTROY_CLIENTID or an EXCHANGE_ID that removes the
> previous client instance's state, it's got no locks to reclaim any more.
> (It can't have gotten any *new* ones, since we're still in the grace
> period.)
> 
> It's effectively a brand new client.  Only reclaiming clients should
> bump that counter.
> 
> We certainly shouldn't be waiting for it to RECLAIM_COMPLETE to end the
> grace period, that client just doesn't matter any more.
> 
> I think?
> 

That wasn't my thinking here.

Suppose we have a client that holds some locks. Server reboots and we do
EXCHANGE_ID and start reclaiming, and eventually send a
RECLAIM_COMPLETE.

Now, there is a network partition and we lose contact with the server
for more than a lease period. The client record gets tossed out. Client
eventually reestablishes the connection before the grace period ends and
attempts to reclaim.

That reclaim should succeed, IMO, as there is no reason that it
shouldn't. Nothing can have claimed competing state since we're still in
the grace period.

The thing you don't want to do here is to double count the
RECLAIM_COMPLETE for this client. So decrementing the counter when you
tear down a client is reasonable.

-- 
Jeff Layton <jlayton@kernel.org>


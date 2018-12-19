Return-Path: <SRS0=a7kO=O4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1098C43387
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 22:21:49 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7745A2086C
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 22:21:49 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728426AbeLSWVs (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 19 Dec 2018 17:21:48 -0500
Received: from fieldses.org ([173.255.197.46]:47376 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725267AbeLSWVs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 19 Dec 2018 17:21:48 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 03B2F1C83; Wed, 19 Dec 2018 17:21:48 -0500 (EST)
Date:   Wed, 19 Dec 2018 17:21:47 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Scott Mayhew <smayhew@redhat.com>
Cc:     jlayton@kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 3/3] nfsd: keep a tally of RECLAIM_COMPLETE operations
 when using nfsdcld
Message-ID: <20181219222147.GA31570@fieldses.org>
References: <20181218142926.27933-1-smayhew@redhat.com>
 <20181218142926.27933-4-smayhew@redhat.com>
 <20181219183600.GC28626@fieldses.org>
 <20181219220545.GS27213@coeurl.usersys.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181219220545.GS27213@coeurl.usersys.redhat.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Dec 19, 2018 at 05:05:45PM -0500, Scott Mayhew wrote:
> On Wed, 19 Dec 2018, J. Bruce Fields wrote:
> 
> > On Tue, Dec 18, 2018 at 09:29:26AM -0500, Scott Mayhew wrote:
> > > +	if (!nfsd4_find_reclaim_client(clp->cl_name, nn))
> > > +		return;
> > > +	if (atomic_inc_return(&nn->nr_reclaim_complete) ==
> > > +			nn->reclaim_str_hashtbl_size) {
> > > +		printk(KERN_INFO "NFSD: all clients done reclaiming, ending NFSv4 grace period (net %x)\n",
> > > +				clp->net->ns.inum);
> > > +		nfsd4_end_grace(nn);
> > > +	}
> > > +}
> > > +
> > > +static void dec_reclaim_complete(struct nfs4_client *clp)
> > > +{
> > > +	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
> > > +
> > > +	if (!nn->track_reclaim_completes)
> > > +		return;
> > > +	if (!test_bit(NFSD4_CLIENT_RECLAIM_COMPLETE, &clp->cl_flags))
> > > +		return;
> > > +	if (nfsd4_find_reclaim_client(clp->cl_name, nn))
> > > +		atomic_dec(&nn->nr_reclaim_complete);
> > > +}
> > > +
> > >  static void expire_client(struct nfs4_client *clp)
> > >  {
> > >  	unhash_client(clp);
> > >  	nfsd4_client_record_remove(clp);
> > > +	dec_reclaim_complete(clp);
> > >  	__destroy_client(clp);
> > >  }
> > 
> > This doesn't look right to me.  If a client reclaims and then
> > immediately calls DESTROY_CLIENTID or something--that should still count
> > as a reclaim, and that shouldn't prevent us from ending the grace period
> > early.
> > 
> > I think dec_reclaim_complete is unnecessary.
> 
> What if a client sends a RECLAIM_COMPLETE, then reboots and sends an
> EXCHANGE_ID, CREATE_SESSION, and RECLAIM_COMPLETE while the server is
> still in grace?  The count would be too high then and the server could
> exit grace before all the clients have reclaimed.  I actually added
> that at Jeff's suggestion because he was seeing it with nfs-ganesha.  

Oh boy.

(Thinks.)

Once it issues a DESTROY_CLIENTID or an EXCHANGE_ID that removes the
previous client instance's state, it's got no locks to reclaim any more.
(It can't have gotten any *new* ones, since we're still in the grace
period.)

It's effectively a brand new client.  Only reclaiming clients should
bump that counter.

We certainly shouldn't be waiting for it to RECLAIM_COMPLETE to end the
grace period, that client just doesn't matter any more.

I think?

--b.

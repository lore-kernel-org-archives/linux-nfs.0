Return-Path: <SRS0=a7kO=O4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8B44AC43387
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 21:57:39 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 583F020869
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 21:57:39 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728836AbeLSV5i (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 19 Dec 2018 16:57:38 -0500
Received: from mx1.redhat.com ([209.132.183.28]:7595 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728781AbeLSV5i (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 19 Dec 2018 16:57:38 -0500
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 41748432C8;
        Wed, 19 Dec 2018 21:57:38 +0000 (UTC)
Received: from coeurl.usersys.redhat.com (ovpn-125-147.rdu2.redhat.com [10.10.125.147])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 21B2C60DB7;
        Wed, 19 Dec 2018 21:57:37 +0000 (UTC)
Received: by coeurl.usersys.redhat.com (Postfix, from userid 1000)
        id 9A4302074C; Wed, 19 Dec 2018 16:57:37 -0500 (EST)
Date:   Wed, 19 Dec 2018 16:57:37 -0500
From:   Scott Mayhew <smayhew@redhat.com>
To:     "J. Bruce Fields" <bfields@fieldses.org>
Cc:     jlayton@kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 3/3] nfsd: keep a tally of RECLAIM_COMPLETE operations
 when using nfsdcld
Message-ID: <20181219215737.GQ27213@coeurl.usersys.redhat.com>
References: <20181218142926.27933-1-smayhew@redhat.com>
 <20181218142926.27933-4-smayhew@redhat.com>
 <20181219174648.GA28626@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181219174648.GA28626@fieldses.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Wed, 19 Dec 2018 21:57:38 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, 19 Dec 2018, J. Bruce Fields wrote:

> On Tue, Dec 18, 2018 at 09:29:26AM -0500, Scott Mayhew wrote:
> > +skip_grace:
> > +	printk(KERN_INFO "NFSD: no clients to reclaim, skipping NFSv4 grace period (net %x)\n",
> > +			net->ns.inum);
> > +	queue_delayed_work(laundry_wq, &nn->laundromat_work, nn->nfsd4_lease * HZ);
> > +	/*
> > +	 * we could call nfsd4_end_grace() here, but it has a dprintk()
> > +	 * that would be confusing if debug logging is enabled
> > +	 */
> 
> In that case, I'd rather pull the dprintk out of nfsd4_end_grace into
> its only other caller (nfs4_laundromat), instead of duplicating this
> stuff.

Okay, will do.

-Scott
> 
> > +	nn->grace_ended = true;
> > +	nfsd4_record_grace_done(nn);
> > +	locks_end_grace(&nn->nfsd4_manager);
> 
> (Yes, it's only three lines, but it's a little subtle, I'd rather have
> it all in one place.)
> 
> --b.
> 
> > +	return 0;
> >  }
> >  
> >  /* initialization to perform when the nfsd service is started: */
> > diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> > index 6384c9b94898..950ac6683be9 100644
> > --- a/fs/nfsd/nfsctl.c
> > +++ b/fs/nfsd/nfsctl.c
> > @@ -1240,6 +1240,7 @@ static __net_init int nfsd_init_net(struct net *net)
> >  	nn->nfsd4_lease = 45;	/* default lease time */
> >  	nn->nfsd4_grace = 45;
> >  	nn->somebody_reclaimed = false;
> > +	nn->track_reclaim_completes = false;
> >  	nn->clverifier_counter = prandom_u32();
> >  	nn->clientid_counter = prandom_u32();
> >  	nn->s2s_cp_cl_id = nn->clientid_counter++;
> > -- 
> > 2.17.1

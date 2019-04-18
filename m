Return-Path: <SRS0=DJTG=SU=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 14C66C10F0E
	for <linux-nfs@archiver.kernel.org>; Thu, 18 Apr 2019 20:50:33 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E104B214DA
	for <linux-nfs@archiver.kernel.org>; Thu, 18 Apr 2019 20:50:32 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2388346AbfDRUuc (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 18 Apr 2019 16:50:32 -0400
Received: from mx1.redhat.com ([209.132.183.28]:37664 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728531AbfDRUub (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 18 Apr 2019 16:50:31 -0400
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id A6E35C05681F;
        Thu, 18 Apr 2019 20:50:26 +0000 (UTC)
Received: from coeurl.usersys.redhat.com (ovpn-121-236.rdu2.redhat.com [10.10.121.236])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 80B5F5D9CC;
        Thu, 18 Apr 2019 20:50:25 +0000 (UTC)
Received: by coeurl.usersys.redhat.com (Postfix, from userid 1000)
        id E296120F5A; Thu, 18 Apr 2019 16:50:24 -0400 (EDT)
Date:   Thu, 18 Apr 2019 16:50:24 -0400
From:   Scott Mayhew <smayhew@redhat.com>
To:     "J. Bruce Fields" <bfields@fieldses.org>
Cc:     jlayton@kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: CB_RECALL can race with FREE_STATEID
Message-ID: <20190418205024.GB15226@coeurl.usersys.redhat.com>
References: <20190418132400.24161-1-smayhew@redhat.com>
 <20190418151312.GB29274@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190418151312.GB29274@fieldses.org>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Thu, 18 Apr 2019 20:50:31 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, 18 Apr 2019, J. Bruce Fields wrote:

> On Thu, Apr 18, 2019 at 09:24:00AM -0400, Scott Mayhew wrote:
> > While trying to track down some issues involving large numbers of
> > delegations being recalled/revoked, I caught the server setting
> > SEQ4_STATUS_CB_PATH_DOWN while the client was actively responding to
> > CB_RECALLs.  It turns out that the client had already done a
> > TEST_STATEID and FREE_STATEID for a delegation being recalled by the
> > time it received the CB_RECALL.
> 
> That's interesting, thanks!
> 
> This exception seems awfully narrow, though.
> 
> If we get back any NFS-level error at all, then I think the callback
> channel is working (am I wrong?)

Correct, if the client replies with either NFS4ERR_DELAY or
NFS4ERR_BAD_STATEID, the server will retry 1 time (see dl_retries).
After that, we fall thru and nfsd4_cb_recall_done() returns -1 which
causes the SEQ4_STATUS_CB_PATH_DOWN flag to be set.

> and telling the client to set up a new
> one is probably not going to help.  The best we can do is probably just
> give up

That's what the patch is essentially doing.  Or are you saying don't
even bother with the checks but still return 1 so we don't set the
SEQ4_STATUS_CB_PATH_DOWN flag?

> and let the client deal with the ensuing
> RECALLABLE_STATE_REVOKED flag.

The client's already dealing with the RECALLABLE_STATE_REVOKED flag,
that's why it sent a TEST_STATEID and FREE_STATEID before it got this
particular CB_RECALL.  The idea behind the patch is to not give the
state manager on the client additional work by setting CB_PATH_DOWN when
the callback channel is clearly working...

-Scott
> 
> --b.
> 
> > 
> > Signed-off-by: Scott Mayhew <smayhew@redhat.com>
> > ---
> >  fs/nfsd/nfs4state.c | 8 ++++++++
> >  1 file changed, 8 insertions(+)
> > 
> > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > index 6a45fb00c5fc..e88e429133a8 100644
> > --- a/fs/nfsd/nfs4state.c
> > +++ b/fs/nfsd/nfs4state.c
> > @@ -3958,6 +3958,14 @@ static int nfsd4_cb_recall_done(struct nfsd4_callback *cb,
> >  			rpc_delay(task, 2 * HZ);
> >  			return 0;
> >  		}
> > +		/*
> > +		 * Race: client may have done a FREE_STATEID before
> > +		 * receiving the CB_RECALL.
> > +		 */
> > +		if (dp->dl_stid.sc_type == NFS4_REVOKED_DELEG_STID &&
> > +				refcount_read(&dp->dl_stid.sc_count) == 1 &&
> > +				list_empty(&dp->dl_recall_lru))
> > +			return 1;
> >  		/*FALLTHRU*/
> >  	default:
> >  		return -1;
> > -- 
> > 2.17.2

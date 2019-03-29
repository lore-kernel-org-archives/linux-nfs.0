Return-Path: <SRS0=26It=SA=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0367C43381
	for <linux-nfs@archiver.kernel.org>; Fri, 29 Mar 2019 12:16:11 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 95B7A217F5
	for <linux-nfs@archiver.kernel.org>; Fri, 29 Mar 2019 12:16:11 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729394AbfC2MQL (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 29 Mar 2019 08:16:11 -0400
Received: from mx1.redhat.com ([209.132.183.28]:40398 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728832AbfC2MQK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 29 Mar 2019 08:16:10 -0400
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 7613AF74B3;
        Fri, 29 Mar 2019 12:16:10 +0000 (UTC)
Received: from coeurl.usersys.redhat.com (ovpn-121-1.rdu2.redhat.com [10.10.121.1])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 444731001E7E;
        Fri, 29 Mar 2019 12:16:09 +0000 (UTC)
Received: by coeurl.usersys.redhat.com (Postfix, from userid 1000)
        id 93FEF20D28; Fri, 29 Mar 2019 08:16:09 -0400 (EDT)
Date:   Fri, 29 Mar 2019 08:16:09 -0400
From:   Scott Mayhew <smayhew@redhat.com>
To:     "J. Bruce Fields" <bfields@fieldses.org>
Cc:     jlayton@kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC v3 0/5] un-deprecate nfsdcld
Message-ID: <20190329121609.GA3659@coeurl.usersys.redhat.com>
References: <20190326220630.2911-1-smayhew@redhat.com>
 <20190328211726.GA31938@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190328211726.GA31938@fieldses.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Fri, 29 Mar 2019 12:16:10 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, 28 Mar 2019, J. Bruce Fields wrote:

> Thanks!  It looks good to me on a first skim, but I probably won't get a
> proper look at it till next week.
> 
> You say "RFC"--are there still known issue that you're working on?

No, I just added RFC because of the new stuff I added for handling the
legacy records.  Plus I wasn't sure if you would have a problem with the
server not lifting the grace period early if there were legacy records.
I could do it if I moved some code out of nfs4recover.c but I chose not
to since it should really be a one-time thing and the original legacy
tracking didn't lift the grace period early anyway.

-Scott
> 
> --b.
> 
> On Tue, Mar 26, 2019 at 06:06:25PM -0400, Scott Mayhew wrote:
> > When nfsdcld was released, it was quickly deprecated in favor of the
> > nfsdcltrack usermodehelper, so as to not require another running daemon.
> > That prevents NFSv4 clients from reclaiming locks from nfsd's running in
> > containers, since neither nfsdcltrack nor the legacy client tracking
> > code work in containers.  These patches un-deprecate the use of nfsdcld
> > for NFSv4 client tracking.
> > 
> > These patches are intended to go alongside some nfs-utils patches that
> > introduce an enhancement that allows nfsd to "slurp" up the client
> > records during client tracking initialization and store them internally
> > in hash table.  This enables nfsd to check whether an NFSv4 client is
> > allowed to reclaim without having to do an upcall to nfsdcld.  It also
> > allows nfsd to decide to end the v4 grace period early if the number of
> > RECLAIM_COMPLETE operations it has received from "known" clients is
> > equal to the number of entries in the hash table.  It also allows nfsd
> > to skip the v4 grace period altogether if it knows there are no clients
> > allowed to reclaim.
> > 
> > There is a fallback to allow nfsd to continue to work with older nfsdcld
> > daemons in the event that any are out in the wild (unlikely).
> > Everything should work fine except nfsd will not be able to exit the
> > grace period early or skip the grace period altogether.
> > 
> > v3:
> > - nfs4_state_start_net() now calls nfsd4_end_grace() instead of
> >   open-coding it
> > - Removed some unnecessary initializations of nr_reclaim_complete
> > - Removed dec_reclaim_complete() altogether.  If we're calling
> >   expire_client() as a result of receiving a DESTROY_CLIENTID or
> >   SETCLIENTID_CONFIRM then we wouldn't want to decrement the count.  And
> >   laundromat thread never expires clients due to loss of lease until the
> >   grace period is over (the laundromat gets rescheduled by 1 second as
> >   long as clients are reclaiming during that 1 second, for up to 2x the
> >   original grace period in total).  So dec_reclaim_complete() is
> >   unnecessary.
> > - Changed the preference order of client tracking methods.  The new
> >   order is 1) new nfdscld, 2) old nfsdcld, 3) nfsdcltrack, 4) legacy
> >   v4recovery directory.
> > - Added some special handling of legacy records sent by nfsdcld in the
> >   GraceStart downcalls.  nfsdcld will do a one-time "upgrade" from old
> >   tracking methods.  No changes are needed to accomodate nfsdcltrack
> >   records, but legacy records will be prefixed with the string "hash:", 
> >   and in the event that we do have legacy records in the
> >   reclaim_str_hashtbl we may need to do a second lookup using the hash
> >   in the event that a lookup using the client name string fails.
> > 
> > v2:
> > - Addressed some coding style issues in nfsd4_create_clid_dir() &
> >   nfsd4_remove_clid_dir()
> > 
> > Scott Mayhew (5):
> >   nfsd: make nfs4_client_reclaim use an xdr_netobj instead of a fixed
> >     char array
> >   nfsd: un-deprecate nfsdcld
> >   nfsd: keep a tally of RECLAIM_COMPLETE operations when using nfsdcld
> >   nfsd: re-order client tracking method selection
> >   nfsd: handle legacy client tracking records sent by nfsdcld
> > 
> >  fs/nfsd/netns.h               |   3 +
> >  fs/nfsd/nfs4recover.c         | 436 +++++++++++++++++++++++++++++++---
> >  fs/nfsd/nfs4state.c           |  63 +++--
> >  fs/nfsd/nfsctl.c              |   1 +
> >  fs/nfsd/state.h               |   8 +-
> >  include/uapi/linux/nfsd/cld.h |   1 +
> >  6 files changed, 457 insertions(+), 55 deletions(-)
> > 
> > -- 
> > 2.17.2

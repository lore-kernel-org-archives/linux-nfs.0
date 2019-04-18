Return-Path: <SRS0=DJTG=SU=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 49E79C10F0E
	for <linux-nfs@archiver.kernel.org>; Thu, 18 Apr 2019 20:44:00 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2012D214DA
	for <linux-nfs@archiver.kernel.org>; Thu, 18 Apr 2019 20:44:00 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728531AbfDRUn7 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 18 Apr 2019 16:43:59 -0400
Received: from mx1.redhat.com ([209.132.183.28]:12195 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725747AbfDRUn7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 18 Apr 2019 16:43:59 -0400
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 9C66423E6D1;
        Thu, 18 Apr 2019 20:43:58 +0000 (UTC)
Received: from coeurl.usersys.redhat.com (ovpn-121-236.rdu2.redhat.com [10.10.121.236])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 6149060852;
        Thu, 18 Apr 2019 20:43:58 +0000 (UTC)
Received: by coeurl.usersys.redhat.com (Postfix, from userid 1000)
        id C6A1A20F5A; Thu, 18 Apr 2019 16:43:56 -0400 (EDT)
Date:   Thu, 18 Apr 2019 16:43:56 -0400
From:   Scott Mayhew <smayhew@redhat.com>
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Question about open(CLAIM_FH)
Message-ID: <20190418204356.GA15226@coeurl.usersys.redhat.com>
References: <20190418133728.GS3773@coeurl.usersys.redhat.com>
 <213d4ead8a7ae890dadc7785d59117e798f94748.camel@hammerspace.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <213d4ead8a7ae890dadc7785d59117e798f94748.camel@hammerspace.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Thu, 18 Apr 2019 20:43:58 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, 18 Apr 2019, Trond Myklebust wrote:

> Hi Scott,
> 
> On Thu, 2019-04-18 at 09:37 -0400, Scott Mayhew wrote:
> > When the client does an open(CLAIM_FH) and the server already has
> > open
> > state for that open owner and file, what's supposed to happen?
> > Currently the server returns the existing stateid with the seqid
> > bumped,
> > but it looks like the client is expecting a new stateid (I'm seeing
> > the
> > state manager spending a lot of time waiting in
> > nfs_set_open_stateid_locked() due to NFS_STATE_CHANGE_WAIT being set
> > in
> > the state flags by nfs_need_update_open_stateid()).
> > 
> > Looking at rfc5661 section 18.16.3, I see:
> > 
> >    | CLAIM_NULL, CLAIM_FH | For the client, this is a new OPEN
> > request |
> >    |                      | and there is no previous state
> > associated  |
> >    |                      | with the file for the
> > client.  With        |
> >    |                      | CLAIM_NULL, the file is identified by
> > the  |
> >    |                      | current filehandle and the
> > specified       |
> >    |                      | component name.  With CLAIM_FH (new
> > to     |
> >    |                      | NFSv4.1), the file is identified by
> > just   |
> >    |                      | the current filehandle.  
> > 
> > So it seems like maybe the server should be tossing the old state and
> > returning a new stateid?
> > 
> 
> No. As far as the protocol is concerned, the only difference between
> CLAIM_NULL and CLAIM_FH is through how the client identifies the file
> (in the first case, through an implicit lookup, and in the second case
> through a file handle). The client should be free to intermix the two
> types of OPEN, and it should expect the resulting stateids to depend
> only on whether or not the open_owner matches. If the open_owner
> matches an existing stateid, then that stateid is bumped and returned.
> 
> I'm not aware of any expectation in the client that this should not be
> the case, so if you are seeing different behaviour, then something else
> must be at work here. Is the client perhaps mounting the same
> filesystem in two different places in such a way that the super block
> is not being shared?

No, it's just a single 4.1 mount w/ the default mount options.

For a bit of background, I've been trying to track down a problem in
RHEL where the SEQ4_STATUS_RECALLABLE_STATE_REVOKED flags is getting
permanently set because the nfs4_client->cl_revoked list on the server
is non-empty... yet there's no longer open state on the client. 

I can reproduce it pretty easily in RHEL using 2 VMs, each with 2-4 CPUs
and 4-8G of memory.  The server has 64 nfsd threads and a 15 second
lease time.

On the client I'm running the following to add a 10ms delay to CB_RECALL
replies:
# stap -gve 'global count = 0; probe module("nfsv4").function("nfs4_callback_recall") { printf("%s: %d\n", ppfunc(), ++count); mdelay(10); }'

then in another window I open a bunch of files:
# for i in `seq -w 1 5000`; do sleep 2m </mnt/t/dir1/file.$i & done

(Note: I already created the files ahead of time)

As soon as the bash prompt returns on the client, I run the following on
the server:
# for i in `seq -w 1 5000`; do date >/export/dir1/file.$i & done

At that point, any further SEQUENCE ops will have the recallable state
revoked flag set on the client until the fs is unmounted.

If I run the same steps on Fedora clients with recent kernels, I don't
have the problem with the recallable state revoked flag, but I'm getting
some other strangeness.  Everything starts out fine with
nfs_reap_expired_delegations() doing TEST_STATEID and FREE_STATEID, but
once the state manager starts callings nfs41_open_expired(), things sort
of grind to a halt and I see 1 OPEN and 1 or 2 TEST_STATEID ops every 5
seconds in wireshark.  It stays that way until the files are closed on
the client, when I see a slew of DELEGRETURNs and FREE_STATEIDs... but
I'm only seeing 3 or 4 CLOSE ops.  If I poke around in crash on the
server, I see a ton of open stateids:

crash> epython fs/nfsd/print-client-state-info.py
nfsd_net = 0xffff93e473511000
        nfs4_client = 0xffff93e3f7954980
                nfs4_stateowner = 0xffff93e4058cc360 num_stateids = 4997 <---- only 3 CLOSE ops were received
                num_openowners = 1
                num_layouts = 0
                num_delegations = 0
                num_sessions = 1
                num_copies = 0
                num_revoked = 0
                cl_cb_waitq_qlen = 0

Those stateids stick around until the fs is unmounted (and the
DESTROY_STATEID ops return NFS4ERR_CLIENTID_BUSY while doing so).

Both VMs are running 5.0.6-200.fc29.x86_64, but the server also has the
"nfsd: Don't release the callback slot unless it was actually held"
patch you sent a few weeks ago as well as the "nfsd: CB_RECALL can race
with FREE_STATEID" patch I sent today.

-Scott

> 
> Cheers
>   Trond
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer, Hammerspace
> trond.myklebust@hammerspace.com
> 
> 

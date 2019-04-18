Return-Path: <SRS0=DJTG=SU=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E0A5EC10F0E
	for <linux-nfs@archiver.kernel.org>; Thu, 18 Apr 2019 23:42:39 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B1AEC20675
	for <linux-nfs@archiver.kernel.org>; Thu, 18 Apr 2019 23:42:39 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725890AbfDRXmj (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 18 Apr 2019 19:42:39 -0400
Received: from fieldses.org ([173.255.197.46]:42048 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725855AbfDRXmi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 18 Apr 2019 19:42:38 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 811FC3EB; Thu, 18 Apr 2019 19:42:38 -0400 (EDT)
Date:   Thu, 18 Apr 2019 19:42:38 -0400
From:   "bfields@fieldses.org" <bfields@fieldses.org>
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     "smayhew@redhat.com" <smayhew@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "jlayton@kernel.org" <jlayton@kernel.org>
Subject: Re: [PATCH] nfsd: CB_RECALL can race with FREE_STATEID
Message-ID: <20190418234238.GA3761@fieldses.org>
References: <20190418132400.24161-1-smayhew@redhat.com>
 <20190418151312.GB29274@fieldses.org>
 <20190418205024.GB15226@coeurl.usersys.redhat.com>
 <15806b00f7ba569a109549eb551bb116d981226d.camel@hammerspace.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <15806b00f7ba569a109549eb551bb116d981226d.camel@hammerspace.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Apr 18, 2019 at 10:03:09PM +0000, Trond Myklebust wrote:
> On Thu, 2019-04-18 at 16:50 -0400, Scott Mayhew wrote:
> > On Thu, 18 Apr 2019, J. Bruce Fields wrote:
> > 
> > > On Thu, Apr 18, 2019 at 09:24:00AM -0400, Scott Mayhew wrote:
> > > > While trying to track down some issues involving large numbers of
> > > > delegations being recalled/revoked, I caught the server setting
> > > > SEQ4_STATUS_CB_PATH_DOWN while the client was actively responding
> > > > to
> > > > CB_RECALLs.  It turns out that the client had already done a
> > > > TEST_STATEID and FREE_STATEID for a delegation being recalled by
> > > > the
> > > > time it received the CB_RECALL.
> > > 
> > > That's interesting, thanks!
> > > 
> > > This exception seems awfully narrow, though.
> > > 
> > > If we get back any NFS-level error at all, then I think the
> > > callback
> > > channel is working (am I wrong?)
> > 
> > Correct, if the client replies with either NFS4ERR_DELAY or
> > NFS4ERR_BAD_STATEID, the server will retry 1 time (see dl_retries).
> > After that, we fall thru and nfsd4_cb_recall_done() returns -1 which
> > causes the SEQ4_STATUS_CB_PATH_DOWN flag to be set.
> 
> There is no handling of NFS4ERR_DELAY in nfsd4_cb_recall_done().
> 
> As far as I can see, therefore, if the client returns NFS4ERR_DELAY
> (which it usually does if it is already in the process of returning the
> delegation) then the recall will fail immediately.

We should fix that, though it doesn't sound like it matters much in that
particular case.

The success or failure of a recall isn't actually all that interesting,
all that matters is whether we get the eventual DELEGRETURN.

--b.

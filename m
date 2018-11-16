Return-Path: <SRS0=G+EE=N3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 880EFC43441
	for <linux-nfs@archiver.kernel.org>; Fri, 16 Nov 2018 18:01:19 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5205F20869
	for <linux-nfs@archiver.kernel.org>; Fri, 16 Nov 2018 18:01:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5205F20869
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fieldses.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727490AbeKQEOl (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 16 Nov 2018 23:14:41 -0500
Received: from fieldses.org ([173.255.197.46]:52066 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727462AbeKQEOl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 16 Nov 2018 23:14:41 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 127B52019; Fri, 16 Nov 2018 13:01:18 -0500 (EST)
Date:   Fri, 16 Nov 2018 13:01:18 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Olga Kornievskaia <aglo@umich.edu>
Cc:     Olga Kornievskaia <kolga@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Subject: Re: handle_async_copy calling kzalloc under spinlock
Message-ID: <20181116180118.GB21852@fieldses.org>
References: <20181116142627.GA19946@fieldses.org>
 <CAN-5tyGsDAd2hkaw5nONdS2TzRy1qK7xyFDpNeT7Jsd9ZrH7+g@mail.gmail.com>
 <20181116175645.GA21852@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181116175645.GA21852@fieldses.org>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Nov 16, 2018 at 12:56:45PM -0500, J. Bruce Fields wrote:
> On Fri, Nov 16, 2018 at 11:25:50AM -0500, Olga Kornievskaia wrote:
> > On Fri, Nov 16, 2018 at 9:27 AM J. Bruce Fields <bfields@fieldses.org>
> > wrote:
> > 
> > > From bc0c9079b48d "NFS handle COPY reply CB_OFFLOAD call race":
> > >
> > > +       spin_lock(&server->nfs_client->cl_lock);
> > > +       list_for_each_entry(copy, &server->nfs_client->pending_cb_stateids,
> > > +                               copies) {
> > > +               if (memcmp(&res->write_res.stateid, &copy->stateid,
> > > +                               NFS4_STATEID_SIZE))
> > > +                       continue;
> > > +               found_pending = true;
> > > +               list_del(&copy->copies);
> > > +               break;
> > > +       }
> > > +       if (found_pending) {
> > > +               spin_unlock(&server->nfs_client->cl_lock);
> > > +               goto out;
> > > +       }
> > >
> > >         copy = kzalloc(sizeof(struct nfs4_copy_state), GFP_NOFS);
> > >
> > > At this point we're still holding cl_lock.
> > >
> > > Best might be to allocate "copy" before taking the lock, then free it on
> > > any
> > > paths where we don't end up needing it.
> > >
> > >
> > Thanks. I'll do that.
> 
> Thanks.  And, I just noticed--nfs4_callback_offload has the same
> problem.

By the way, I don't understand the create case in that code--if you get
a CB_OFFLOAD without already having a matching copy stateid, shouldn't
you just return an error and forget about it?

I also wonder if SERVERFAULT is really the best error for a memory
allocation failure there.

--b.

Return-Path: <SRS0=G+EE=N3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B5CF5C43441
	for <linux-nfs@archiver.kernel.org>; Fri, 16 Nov 2018 17:56:47 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3A80820869
	for <linux-nfs@archiver.kernel.org>; Fri, 16 Nov 2018 17:56:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3A80820869
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fieldses.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2390191AbeKQEKI (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 16 Nov 2018 23:10:08 -0500
Received: from fieldses.org ([173.255.197.46]:52052 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727490AbeKQEKI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 16 Nov 2018 23:10:08 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id C5AFF1E29; Fri, 16 Nov 2018 12:56:45 -0500 (EST)
Date:   Fri, 16 Nov 2018 12:56:45 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Olga Kornievskaia <aglo@umich.edu>
Cc:     Olga Kornievskaia <kolga@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Subject: Re: handle_async_copy calling kzalloc under spinlock
Message-ID: <20181116175645.GA21852@fieldses.org>
References: <20181116142627.GA19946@fieldses.org>
 <CAN-5tyGsDAd2hkaw5nONdS2TzRy1qK7xyFDpNeT7Jsd9ZrH7+g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAN-5tyGsDAd2hkaw5nONdS2TzRy1qK7xyFDpNeT7Jsd9ZrH7+g@mail.gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Nov 16, 2018 at 11:25:50AM -0500, Olga Kornievskaia wrote:
> On Fri, Nov 16, 2018 at 9:27 AM J. Bruce Fields <bfields@fieldses.org>
> wrote:
> 
> > From bc0c9079b48d "NFS handle COPY reply CB_OFFLOAD call race":
> >
> > +       spin_lock(&server->nfs_client->cl_lock);
> > +       list_for_each_entry(copy, &server->nfs_client->pending_cb_stateids,
> > +                               copies) {
> > +               if (memcmp(&res->write_res.stateid, &copy->stateid,
> > +                               NFS4_STATEID_SIZE))
> > +                       continue;
> > +               found_pending = true;
> > +               list_del(&copy->copies);
> > +               break;
> > +       }
> > +       if (found_pending) {
> > +               spin_unlock(&server->nfs_client->cl_lock);
> > +               goto out;
> > +       }
> >
> >         copy = kzalloc(sizeof(struct nfs4_copy_state), GFP_NOFS);
> >
> > At this point we're still holding cl_lock.
> >
> > Best might be to allocate "copy" before taking the lock, then free it on
> > any
> > paths where we don't end up needing it.
> >
> >
> Thanks. I'll do that.

Thanks.  And, I just noticed--nfs4_callback_offload has the same
problem.

--b.

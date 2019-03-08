Return-Path: <SRS0=3/9x=RL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EA658C43381
	for <linux-nfs@archiver.kernel.org>; Fri,  8 Mar 2019 21:38:20 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C287120652
	for <linux-nfs@archiver.kernel.org>; Fri,  8 Mar 2019 21:38:20 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726319AbfCHViU (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 8 Mar 2019 16:38:20 -0500
Received: from fieldses.org ([173.255.197.46]:45258 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726293AbfCHViU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 8 Mar 2019 16:38:20 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 0E9371C82; Fri,  8 Mar 2019 16:38:19 -0500 (EST)
Date:   Fri, 8 Mar 2019 16:38:19 -0500
From:   "'J. Bruce Fields'" <bfields@fieldses.org>
To:     Frank Filz <ffilzlnx@mindspring.com>
Cc:     'Amir Goldstein' <amir73il@gmail.com>, Volker.Lendecke@sernet.de,
        samba-technical@lists.samba.org,
        'Jeff Layton' <jlayton@kernel.org>,
        'Linux NFS Mailing List' <linux-nfs@vger.kernel.org>,
        'linux-fsdevel' <linux-fsdevel@vger.kernel.org>,
        'Jeremy Allison' <jra@samba.org>, devel@lists.nfs-ganesha.org,
        'Ralph Boehme' <slow@samba.org>
Subject: Re: [NFS-Ganesha-Devel] Re: Better interop for NFS/SMB file share
 mode/reservation
Message-ID: <20190308213819.GC28002@fieldses.org>
References: <CAOQ4uxgewN=j3ju5MSowEvwhK1HqKG3n1hBRUQTi1W5asaO1dQ@mail.gmail.com>
 <20190208155052.GB20573@fieldses.org>
 <CAOQ4uxg9NGPRpMZt0KgH9HUKMRpn0dFta7EnP1WioRb917n4+A@mail.gmail.com>
 <20190208221239.GA199180@jra3>
 <CAOQ4uxjxQoCWqfp+f91--tyR81PREsssT=RV9uRgCQFs+yk7mw@mail.gmail.com>
 <20190214210652.GC9216@fieldses.org>
 <20190305214748.GD27437@fieldses.org>
 <CAOQ4uxigRpjjni8nvYxCqeyTnr0Zf7Stj9h2+24_S9n4i0euYA@mail.gmail.com>
 <20190306151735.GD2426@fieldses.org>
 <066801d4d432$719f5df0$54de19d0$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <066801d4d432$719f5df0$54de19d0$@mindspring.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Mar 06, 2019 at 07:37:00AM -0800, Frank Filz wrote:
> > On Wed, Mar 06, 2019 at 09:09:21AM +0200, Amir Goldstein wrote:
> > > On Tue, Mar 5, 2019 at 11:48 PM J. Bruce Fields
> > > <bfields@fieldses.org> wrote:
> > > >
> > > > On Thu, Feb 14, 2019 at 04:06:52PM -0500, J. Bruce Fields wrote:
> > > > > After this:
> > > > >
> > > > >       https://marc.info/?l=linux-nfs&m=154966239918297&w=2
> > > > >
> > > > > delegations would no longer conflict with opens from the same
> > > > > tgid.  So if your threads all run in the same process and
> > > > > you're willing to manage conflicts among your own clients,
> > > > > that should still allow you to do multiple opens of the same
> > > > > file without giving up your
> > lease/delegation.
> > > > >
> > > > > I'd be curious to know whether that works with Samba's design.
> > > >
> > > > Any idea whether that would work?
> > > >
> > > > (Easy?  Impossible?  Possible, but realistically the changes
> > > > required to Samba would be painful enough that it'd be unlikely
> > > > to get done?)
> > > >
> > >
> > > [CC Ralph Boehme]
> > >
> > > I am not a samba team member, but seems to me that your proposal
> > > fits samba design like a glove. With one smbd process per client
> > > connection, with your proposal, opens (for read) from same smbd
> > > process will not break the shared read lease from same client, so
> > > oplocks level II could be implemented using kernel oplocks (new
> > > flavor).
> > 
> > OK.  So I wonder about Ganesha.  I'm not sure, but I *think* it's
> > like knfsd in that it has a bunch of worker threads that can each
> > take rpc's from any client.  I don't remember if they're actually
> > threads or processes.
> 
> Ganesha does use worker threads

And they're all part of one process?

> however, one thing that may be an
> advantage here, or at least can be leveraged, is that Ganesha attaches
> a single file descriptor to each stateid. As long as the I/O requests
> come using the stateid, that file descriptor will be used.
> 
> We have some work completed and more in progress on delegations, and
> if there becomes a new kernel oplock available, we could definitely
> use it. On the other hand, FSAL_VFS which is the FSAL used with kernel
> file systems does not support delegations...
> 
> The (distributed) file systems we support delegations on have use
> space libraries (which Samba should also be using?) that implement the
> delegation primitives.

Is there anyone working on delegation support for FSAL_VFS?  If it's not
getting much attention then maybe Samba is the only real user for the
forseeable future.

--b.

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f176.google.com ([209.85.220.176]:33135 "EHLO
	mail-qk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751686AbbKNA7E (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Nov 2015 19:59:04 -0500
Received: by qkas77 with SMTP id s77so65390162qka.0
        for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2015 16:59:03 -0800 (PST)
Date: Fri, 13 Nov 2015 19:58:59 -0500
From: Jeff Layton <jlayton@poochiereds.net>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: Christoph Hellwig <hch@infradead.org>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: lock reclaim failed!
Message-ID: <20151113195859.6bd50799@tlielax.poochiereds.net>
In-Reply-To: <CAN-5tyFQxy_Ge+eN1uRbDqwVDuO2XOmZvX+uUgd0waewHq01HA@mail.gmail.com>
References: <20151113092254.GA5047@infradead.org>
	<CAN-5tyFQxy_Ge+eN1uRbDqwVDuO2XOmZvX+uUgd0waewHq01HA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 13 Nov 2015 10:47:32 -0500
Olga Kornievskaia <aglo@umich.edu> wrote:

> On Fri, Nov 13, 2015 at 4:22 AM, Christoph Hellwig <hch@infradead.org> wrote:
> > I see the following running xfstestst on latest Linus' tree against
> > as sever from the same tree:
> >
> > generic/089     [ 2000.358405] NFS: nfs4_reclaim_open_state: Lock reclaim failed!
> > [ 2001.769939] NFS: nfs4_reclaim_open_state: Lock reclaim failed!
> > [ 2001.770732] NFS: nfs4_reclaim_open_state: Lock reclaim failed!
> > [ 2122.608136] NFS: nfs4_reclaim_open_state: Lock reclaim failed!
> 
> Going against the NetApp server, we have seen this error logged when
> the server returned BAD_STATEID to the IO on the delegated stateid. Is
> there such error on the network trace?

Yes, a capture is probably the best way to tell what's really going on.

I just tried generic/test089 a couple of times on the fedora kernel
here (on both server and client) and didn't see that pop:

    http://koji.fedoraproject.org/koji/buildinfo?buildID=699182

What's the top commit of your kernel? I assume that the server didn't
restart or anything, right?

-- 
Jeff Layton <jlayton@poochiereds.net>

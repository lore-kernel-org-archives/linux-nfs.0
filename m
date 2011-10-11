Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:36972 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751757Ab1JKMxL convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Oct 2011 08:53:11 -0400
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Subject: RE: [PATCH 3/4] sunrpc: make rpc_wait_bit_killable handle freeze events
Date: Tue, 11 Oct 2011 05:52:57 -0700
Message-ID: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B91E852@SACMVEXC2-PRD.hq.netapp.com>
In-Reply-To: <20111011061221.2a4a212f@tlielax.poochiereds.net>
References: <1317210761-11518-1-git-send-email-jlayton@redhat.com><1317210761-11518-4-git-send-email-jlayton@redhat.com><20111011061923.GC1377@ucw.cz> <20111011061221.2a4a212f@tlielax.poochiereds.net>
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Jeff Layton" <jlayton@redhat.com>, "Pavel Machek" <pavel@ucw.cz>
Cc: <smfrench@gmail.com>, <rjw@sisk.pl>, <linux-pm@lists.linux-foundation.org>,
        <linux-cifs@vger.kernel.org>, <linux-nfs@vger.kernel.org>,
        <john@Calva.COM>, <linux-kernel@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: Jeff Layton [mailto:jlayton@redhat.com]
> Sent: Tuesday, October 11, 2011 6:12 AM
> To: Pavel Machek
> Cc: Myklebust, Trond; smfrench@gmail.com; rjw@sisk.pl; linux-
> pm@lists.linux-foundation.org; linux-cifs@vger.kernel.org; linux-
> nfs@vger.kernel.org; john@Calva.COM; linux-kernel@vger.kernel.org
> Subject: Re: [PATCH 3/4] sunrpc: make rpc_wait_bit_killable handle
freeze
> events
> 
> On Tue, 11 Oct 2011 08:19:23 +0200
> Pavel Machek <pavel@ucw.cz> wrote:
> 
> > On Wed 2011-09-28 07:52:40, Jeff Layton wrote:
> > > Allow the wait_on_bit_killable sleeps in SUNRPC layer to respect
the
> > > freezer. This should allow suspend and hibernate events to occur,
> > > even when there are RPC's pending on the wire.
> >
> > Will the RPC protocols used handle that correctly? What will happen
> > during resume?
> >
> 
> That depends on the state of the socket during resume. If the
> suspend/resume is quick enough, then the socket may still be
connected, or
> if we're using UDP then we might just get the reply and carry on
successfully.
> Otherwise, the call will eventually time out, or will be cancelled
when the
> kernel finds that the socket has been closed.
> 
> Either way, this should do the right thing.

Well... The problem when this sort of thing happens is with the replay
cache. If the RPC in question was a mkdir, for instance, then replaying
the RPC call when you wake up can be problematic because chances are
that the server will have forgotten who created the directory, and so
will reply with EEXIST instead of OK.
However this is a generic problem when the client is unable to talk to
the server for a while, and is not particular to suspend.

Cheers
  Trond

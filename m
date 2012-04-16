Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:8804 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752861Ab2DPTnO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Apr 2012 15:43:14 -0400
Date: Mon, 16 Apr 2012 15:43:22 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>,
        Malahal Naineni <malahal@us.ibm.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "pstaubach@exagrid.com" <pstaubach@exagrid.com>,
        "miklos@szeredi.hu" <miklos@szeredi.hu>,
        "viro@ZenIV.linux.org.uk" <viro@ZenIV.linux.org.uk>,
        "hch@infradead.org" <hch@infradead.org>,
        "michael.brantley@deshaw.com" <michael.brantley@deshaw.com>,
        "sven.breuner@itwm.fraunhofer.de" <sven.breuner@itwm.fraunhofer.de>
Subject: Re: [PATCH RFC] vfs: make fstatat retry on ESTALE errors from
 getattr call
Message-ID: <20120416154322.0d95e435@corrin.poochiereds.net>
In-Reply-To: <1334604785.2879.23.camel@lade.trondhjem.org>
References: <1334316311-22331-1-git-send-email-jlayton@redhat.com>
	<20120413150518.GA1987@us.ibm.com>
	<20120413114236.0e557e01@tlielax.poochiereds.net>
	<4F8B1B7B.3040304@itwm.fraunhofer.de>
	<20120416073655.7cdb90cf@corrin.poochiereds.net>
	<4F8C3036.2030702@itwm.fraunhofer.de>
	<20120416134642.1754cd3e@corrin.poochiereds.net>
	<1334604785.2879.23.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 16 Apr 2012 19:33:05 +0000
"Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> On Mon, 2012-04-16 at 13:46 -0400, Jeff Layton wrote:
> > The question about looping indefinitely really comes down to:
> > 
> > 1) is a persistent ESTALE in conjunction with a successful lookup a
> > situation that we expect to be temporary. i.e. will the admin at some
> > point be able to do something about it? If not, then there's no point
> > in continuing to retry. Again, this is a situation that *really* should
> > not happen if the filesystem is doing the right thing.
> > 
> > 2) If the admin can't do anything about it, is it reasonable to expect
> > that users can send a fatal signal to hung applications if this
> > situation occurs.
> > 
> > We expect that that's ok in other situations to resolve hung
> > applications, so I'm not sure I understand why it wouldn't be
> > acceptable here...
> 
> There are definitely potentially persistent pathological situations that
> the filesystem can't do anything about. If the point of origin for your
> pathname (for instance your current directory in the case of a relative
> pathname) is stale, then no amount of looping is going to help you to
> recover.
> 

Ok -- Peter pretty much said something similar. Retrying indefnitely
when the lookup returns ESTALE probably won't help. I'm ok with
basically letting the VFS continue to do what it does there already. If
it gets an ESTALE, it tries again with LOOKUP_REVAL set and then gives
up if that doesn't work.

If however, the operation itself keeps returning ESTALE, are we OK to
retry indefinitely assuming that we'll break out of the loop on fatal
signals?

For example, something like the v2 patch I sent a little while ago?

-- 
Jeff Layton <jlayton@redhat.com>

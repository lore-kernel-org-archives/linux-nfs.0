Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:21717 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753996Ab2DQPCA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Apr 2012 11:02:00 -0400
Date: Tue, 17 Apr 2012 11:02:19 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: Steve Dickson <SteveD@redhat.com>,
        "Myklebust\, Trond" <Trond.Myklebust@netapp.com>,
        Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>,
        Malahal Naineni <malahal@us.ibm.com>,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel\@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "pstaubach\@exagrid.com" <pstaubach@exagrid.com>,
        "viro\@ZenIV.linux.org.uk" <viro@ZenIV.linux.org.uk>,
        "hch\@infradead.org" <hch@infradead.org>,
        "michael.brantley\@deshaw.com" <michael.brantley@deshaw.com>,
        "sven.breuner\@itwm.fraunhofer.de" <sven.breuner@itwm.fraunhofer.de>
Subject: Re: [PATCH RFC] vfs: make fstatat retry on ESTALE errors from
 getattr call
Message-ID: <20120417110219.0db9bdee@corrin.poochiereds.net>
In-Reply-To: <87k41eo2m3.fsf@tucsk.pomaz.szeredi.hu>
References: <1334316311-22331-1-git-send-email-jlayton@redhat.com>
	<20120413150518.GA1987@us.ibm.com>
	<20120413114236.0e557e01@tlielax.poochiereds.net>
	<4F8B1B7B.3040304@itwm.fraunhofer.de>
	<20120416073655.7cdb90cf@corrin.poochiereds.net>
	<4F8C3036.2030702@itwm.fraunhofer.de>
	<20120416134642.1754cd3e@corrin.poochiereds.net>
	<1334604785.2879.23.camel@lade.trondhjem.org>
	<20120416154322.0d95e435@corrin.poochiereds.net>
	<1334607906.2879.36.camel@lade.trondhjem.org>
	<20120416190548.2463d1d0@corrin.poochiereds.net>
	<4F8D580B.7060104@RedHat.com>
	<20120417093643.7f172057@corrin.poochiereds.net>
	<4F8D7ADF.9030709@RedHat.com>
	<87k41eo2m3.fsf@tucsk.pomaz.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 17 Apr 2012 16:27:16 +0200
Miklos Szeredi <miklos@szeredi.hu> wrote:

> Steve Dickson <SteveD@redhat.com> writes:
> 
> > True, but even so... Giving file systems an opt-out option with the 
> > default being out, maybe still have some merit... Making file systems
> > enable this new type of functionality would cut down on any of the
> > "surprise" that might occur with this redo ;-) 
> 
> I've been arguing for something slightly different for quite some time:
> I never liked errno values which have side effects in the kernel yet
> might be visible to userspace.
> 
> So why not introduce ERETRYSTALE, a *kernel internal* errno value that
> userspace will never see and filesystems never accidentally set.  The
> VFS can turn this into ESTALE if it doesn't retry for some reason
> (e.g. already retried).
> 

That's possible but it's certainly a lot more invasive. It's also far
more difficult for filesystems to opt-in to this sort of behavior.

All of the places that call vfs_getattr, for instance will need to be
fixed up to deal with that sort of error. That will also make it messy
to do this in any sort of piecemeal fashion. We can't (for instance)
convert NFSERR_STALE to -ESTALERETRY universally. We'll need to take
great care only to return that to codepaths that are equipped to deal
with it.

Personally, I'd prefer not to foist so much code churn on any filesystem
that might want to do this sort of retry, but I'll live with it if
that's the consensus opinion...

-- 
Jeff Layton <jlayton@redhat.com>

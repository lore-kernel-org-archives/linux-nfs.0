Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f44.google.com ([74.125.82.44]:45617 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752254Ab2DWP2A (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Apr 2012 11:28:00 -0400
Received: by wgbdr13 with SMTP id dr13so11974648wgb.1
        for <linux-nfs@vger.kernel.org>; Mon, 23 Apr 2012 08:27:59 -0700 (PDT)
From: Miklos Szeredi <miklos@szeredi.hu>
To: Jeff Layton <jlayton@redhat.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Malahal Naineni <malahal@us.ibm.com>,
        Steve Dickson <SteveD@redhat.com>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        viro@zeniv.linux.org.uk, hch@infradead.org,
        michael.brantley@deshaw.com, sven.breuner@itwm.fraunhofer.de,
        chuck.lever@oracle.com, pstaubach@exagrid.com,
        trond.myklebust@fys.uio.no, rees@umich.edu
Subject: Re: [PATCH RFC v3] vfs: make fstatat retry once on ESTALE errors from getattr call
References: <20120420104055.511e15bc@tlielax.poochiereds.net>
	<4F91C49D.8070908@RedHat.com> <20120420203725.GA3512@us.ibm.com>
	<20120420171314.73801874@corrin.poochiereds.net>
	<CAJfpegt40cgMJQQo3JuNaaS1w957Y2a_NxVoyvx3bmTMj1TGOA@mail.gmail.com>
	<20120423080012.7c23ef24@tlielax.poochiereds.net>
	<20120423130009.GA13681@fieldses.org>
	<20120423091255.00f926c4@tlielax.poochiereds.net>
	<20120423133412.GB13681@fieldses.org>
	<20120423095021.1a91a23b@tlielax.poochiereds.net>
	<20120423135456.GC13681@fieldses.org>
	<87hawasdrb.fsf@tucsk.pomaz.szeredi.hu>
	<20120423111610.0259d610@tlielax.poochiereds.net>
Date: Mon, 23 Apr 2012 17:28:19 +0200
In-Reply-To: <20120423111610.0259d610@tlielax.poochiereds.net> (Jeff Layton's
	message of "Mon, 23 Apr 2012 11:16:10 -0400")
Message-ID: <87zka2qxgs.fsf@tucsk.pomaz.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jeff Layton <jlayton@redhat.com> writes:

>
> Ok, but again, that only applies to the lookup. It has no bearing on
> the subsequent operation. For instance, if we're doing:
>
>      rename("/foo", "/bar");
>
> ...and another client is simultaneously doing:
>
>      creat("/bar/baz", 0600);
>
> ...and we get back ESTALE from the server on the create because the
> "old" /bar got replaced after the lookup of it. Then it seems like
> returning -ENOENT would not be correct since there was never a time
> where /bar didn't exist...

It may not be "correct" according to some standard.  But it's what Linux
does since day one on *all* filesystems.  And probably other OS's that
have remotely scalable lookup routines.

Thanks,
Miklos

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:36297 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753838Ab2DTVMo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Apr 2012 17:12:44 -0400
Date: Fri, 20 Apr 2012 17:13:14 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Malahal Naineni <malahal@us.ibm.com>
Cc: Steve Dickson <SteveD@redhat.com>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        miklos@szeredi.hu, viro@ZenIV.linux.org.uk, hch@infradead.org,
        michael.brantley@deshaw.com, sven.breuner@itwm.fraunhofer.de,
        chuck.lever@oracle.com, pstaubach@exagrid.com, bfields@fieldses.org,
        trond.myklebust@fys.uio.no, rees@umich.edu
Subject: Re: [PATCH RFC v3] vfs: make fstatat retry once on ESTALE errors
 from getattr call
Message-ID: <20120420171314.73801874@corrin.poochiereds.net>
In-Reply-To: <20120420203725.GA3512@us.ibm.com>
References: <1334316311-22331-1-git-send-email-jlayton@redhat.com>
	<1334749927-26138-1-git-send-email-jlayton@redhat.com>
	<20120420104055.511e15bc@tlielax.poochiereds.net>
	<4F91C49D.8070908@RedHat.com>
	<20120420203725.GA3512@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 20 Apr 2012 15:37:26 -0500
Malahal Naineni <malahal@us.ibm.com> wrote:

> Steve Dickson [SteveD@redhat.com] wrote:
> > > 2) if we assume that it is fairly representative of one, how can we
> > > achieve retrying indefinitely with NFS, or at least some large finite
> > > amount?
> > The amount of looping would be peer speculation. If the problem can
> > not be handled by one simple retry I would say we simply pass the
> > error up to the app... Its an application issue... 
> 
> As someone said, ESTALE is an incorrect errno for a path based call.
> How about turning ESTALE into ENOENT after a retry or few retries?
> 

It's not really the same thing. One could envision an application
that's repeatedly renaming a new file on top of another one. The file
is never missing from the namespace of the server, but you could still
end up getting an ESTALE.

That would break other atomicity guarantees in an even worse way, IMO...

-- 
Jeff Layton <jlayton@redhat.com>

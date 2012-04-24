Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:63645 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752773Ab2DXOwY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Apr 2012 10:52:24 -0400
Date: Tue, 24 Apr 2012 10:50:49 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Peter Staubach <pstaubach@exagrid.com>
Cc: Steve Dickson <SteveD@redhat.com>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "miklos@szeredi.hu" <miklos@szeredi.hu>,
        "viro@ZenIV.linux.org.uk" <viro@ZenIV.linux.org.uk>,
        "hch@infradead.org" <hch@infradead.org>,
        "michael.brantley@deshaw.com" <michael.brantley@deshaw.com>,
        "sven.breuner@itwm.fraunhofer.de" <sven.breuner@itwm.fraunhofer.de>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>,
        "malahal@us.ibm.com" <malahal@us.ibm.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "trond.myklebust@fys.uio.no" <trond.myklebust@fys.uio.no>,
        "rees@umich.edu" <rees@umich.edu>
Subject: Re: [PATCH RFC v3] vfs: make fstatat retry once on ESTALE errors
 from getattr call
Message-ID: <20120424105049.5ed96b40@tlielax.poochiereds.net>
In-Reply-To: <FA8A9A935BFD3A4D8F0CDA1C4F611BCC063CF8E64B@IT-1874.Isys.com>
References: <1334316311-22331-1-git-send-email-jlayton@redhat.com>
	<1334749927-26138-1-git-send-email-jlayton@redhat.com>
	<20120420104055.511e15bc@tlielax.poochiereds.net>
	<4F91C49D.8070908@RedHat.com>
	<20120420171300.326d6e36@corrin.poochiereds.net>
	<4F956D5C.5050801@RedHat.com>
	<20120423113216.01992555@tlielax.poochiereds.net>
	<4F959A36.2080402@RedHat.com>
	<FA8A9A935BFD3A4D8F0CDA1C4F611BCC063CF8E64B@IT-1874.Isys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 23 Apr 2012 16:38:00 -0400
Peter Staubach <pstaubach@exagrid.com> wrote:

> I don't really like the idea of introducing another errno as well.  It seems like too much complexity and represents complexity that no one has really justified needing.
> 

I tend to agree here. Miklos, can you elaborate a bit on what fuse
filesystems you're particularly concerned about here? Which ones return
ESTALE and under what conditions. Maybe we can try to tailor this
solution to avoid the complexity without impacting them.

> This is a situation which we know happens in nature.  We should fix it and fix it correctly and not for just "part of the time".  The changes are pretty simple and straightforward, so complexity isn't even an argument.
> 

That was the case in the original patch, yes. One thing I see that will
be tricky in forward porting all of that work is that that set also had
some checks to make sure that lookups were making forward progress
before retrying. Trying to add that to the current lookup code may be
more difficult.

do_path_lookup (for instance) does this currently:

---------------[snip]---------------
                retval = path_lookupat(dfd, name, flags, nd);
        if (unlikely(retval == -ESTALE))
                retval = path_lookupat(dfd, name, flags | LOOKUP_REVAL, nd);
---------------[snip]---------------

The trivial thing to do to make that retry is to turn that ESTALE check
into a while loop (optionally with some sort of limit on the number of
retries). But...we don't have a way to know the pointer to the last
dentry that we successfully looked up.

One possibility there is to try and have the error paths that matter
set the nd->path.dentry to the current one (without taking any
references). Then we could compare that to the last one on each pass of
the while loop and ensure that it's different and just not try to
dereference it.

> A tunable sounds good, until it is needed, and when it is needed, it is too late.  The system should just work correctly on its own, so I don't think that this is such a good idea either.
> 

Yeah, it's not ideal, but if there are concerns about the number of
retries, then that's one way to alleviate them. Eventually we could
eliminate the tunable when/if we found a default that worked for
everyone, or just decide that retrying indefinitely is OK.

-- 
Jeff Layton <jlayton@redhat.com>

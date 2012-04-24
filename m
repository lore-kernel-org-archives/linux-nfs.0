Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f172.google.com ([209.85.212.172]:57406 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755863Ab2DXPyi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Apr 2012 11:54:38 -0400
Received: by wibhj6 with SMTP id hj6so4074341wib.1
        for <linux-nfs@vger.kernel.org>; Tue, 24 Apr 2012 08:54:36 -0700 (PDT)
From: Miklos Szeredi <miklos@szeredi.hu>
To: Jeff Layton <jlayton@redhat.com>
Cc: Peter Staubach <pstaubach@exagrid.com>, Steve Dickson <SteveD@redhat.com>,
        "linux-fsdevel\@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "viro\@ZenIV.linux.org.uk" <viro@ZenIV.linux.org.uk>,
        "hch\@infradead.org" <hch@infradead.org>,
        "michael.brantley\@deshaw.com" <michael.brantley@deshaw.com>,
        "sven.breuner\@itwm.fraunhofer.de" <sven.breuner@itwm.fraunhofer.de>,
        "chuck.lever\@oracle.com" <chuck.lever@oracle.com>,
        "malahal\@us.ibm.com" <malahal@us.ibm.com>,
        "bfields\@fieldses.org" <bfields@fieldses.org>,
        "trond.myklebust\@fys.uio.no" <trond.myklebust@fys.uio.no>,
        "rees\@umich.edu" <rees@umich.edu>
Subject: Re: [PATCH RFC v3] vfs: make fstatat retry once on ESTALE errors from getattr call
References: <1334316311-22331-1-git-send-email-jlayton@redhat.com>
	<1334749927-26138-1-git-send-email-jlayton@redhat.com>
	<20120420104055.511e15bc@tlielax.poochiereds.net>
	<4F91C49D.8070908@RedHat.com>
	<20120420171300.326d6e36@corrin.poochiereds.net>
	<4F956D5C.5050801@RedHat.com>
	<20120423113216.01992555@tlielax.poochiereds.net>
	<4F959A36.2080402@RedHat.com>
	<FA8A9A935BFD3A4D8F0CDA1C4F611BCC063CF8E64B@IT-1874.Isys.com>
	<20120424105049.5ed96b40@tlielax.poochiereds.net>
Date: Tue, 24 Apr 2012 17:54:56 +0200
In-Reply-To: <20120424105049.5ed96b40@tlielax.poochiereds.net> (Jeff Layton's
	message of "Tue, 24 Apr 2012 10:50:49 -0400")
Message-ID: <87lillktv3.fsf@tucsk.pomaz.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jeff Layton <jlayton@redhat.com> writes:

> On Mon, 23 Apr 2012 16:38:00 -0400
> Peter Staubach <pstaubach@exagrid.com> wrote:
>
>> I don't really like the idea of introducing another errno as well.  It seems like too much complexity and represents complexity that no one has really justified needing.
>> 
>
> I tend to agree here. Miklos, can you elaborate a bit on what fuse
> filesystems you're particularly concerned about here? Which ones return
> ESTALE and under what conditions. Maybe we can try to tailor this
> solution to avoid the complexity without impacting them.

It is not just fuse I'm concerned about.  Grep for -ESTALE, there are
about 120 hits about 20 of which come from NFS.  There's no guarantee
that any of those ESTALE errors will go away on retry, which for an
unlimited retry means a hung OS.  If you limit the number of retries
then in the best case it's just lots of wasted CPU cycles.

And an audit would still not ensure safety against future additions of
ESTALE.

And a simple audit won't find things like fuse, where the error comes
from outside the kernel.  Fixing that is not trivial either.  Turning
ESTALE into some other error prevents looping but breaks the return
value.

Thanks,
Miklos

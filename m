Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f172.google.com ([209.85.212.172]:40111 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757178Ab2DYJle (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Apr 2012 05:41:34 -0400
Received: by wibhj6 with SMTP id hj6so4837934wib.1
        for <linux-nfs@vger.kernel.org>; Wed, 25 Apr 2012 02:41:33 -0700 (PDT)
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
In-Reply-To: <20120424123413.17625d5d@tlielax.poochiereds.net> (Jeff Layton's
	message of "Tue, 24 Apr 2012 12:34:13 -0400")
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
	<87lillktv3.fsf@tucsk.pomaz.szeredi.hu>
	<20120424123413.17625d5d@tlielax.poochiereds.net>
Date: Wed, 25 Apr 2012 11:41:52 +0200
Message-ID: <87bomgkv1b.fsf@tucsk.pomaz.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jeff Layton <jlayton@redhat.com> writes:

>> And an audit would still not ensure safety against future additions of
>> ESTALE.
>> 
>
> Well, nothing is safe from the future. It's incumbent upon us to review
> patches and such before such breakage goes in.

Good interfaces are safe against stupidity, and that very much applies
to the kernel too.  Review is not an excuse for bad interfaces.

> But, let's say for the purposes of argument that we do have a fs (FUSE
> or otherwise) that is persistently returning ESTALE on a lookup. Why
> was Peter's check that we were making forward progress not enough to
> guard against this problem?
>
> In particular, I'm talking about the code he added to link_path_walk in
> this patch to check that the value of nd->path.dentry was changing:
>
>     https://lkml.org/lkml/2008/3/10/266
>
> It seems like that ought to be enough to alleviate your fears on this.
> We could also check for fatal signals on each pass and that would allow
> users to break out of the loop even when the underlying fs doesn't
> handle signals properly.

AFAICS that doesn't ensure progress, only change.  It helps those cases
which persistently return ESTALE, but not cases where there is change
but no progress.  E.g. it doesn't prevent DoS by a client doing renames
over a directory in a tight loop.

Thanks,
Miklos

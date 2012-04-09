Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:54002 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932069Ab2DIQLR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Apr 2012 12:11:17 -0400
Date: Mon, 9 Apr 2012 12:11:14 -0400
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: Jeff Layton <jlayton@redhat.com>,
        "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: Grace period
Message-ID: <20120409161114.GB6482@fieldses.org>
References: <4F7F230A.6080506@parallels.com>
 <20120406234039.GA20940@fieldses.org>
 <4F82C6E3.3030009@parallels.com>
 <20120409094743.56932677@tlielax.poochiereds.net>
 <4F82F16C.7030303@parallels.com>
 <20120409112739.6a823d6f@corrin.poochiereds.net>
 <4F830999.5000504@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <4F830999.5000504@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 09, 2012 at 08:08:57PM +0400, Stanislav Kinsbursky wrote:
> 09.04.2012 19:27, Jeff Layton пишет:
> >
> >If you allow one container to hand out conflicting locks while another
> >container is allowing reclaims, then you can end up with some very
> >difficult to debug silent data corruption. That's the worst possible
> >outcome, IMO. We really need to actively keep people from shooting
> >themselves in the foot here.
> >
> >One possibility might be to only allow filesystems to be exported from
> >a single container at a time (and allow that to be overridable somehow
> >once we have a working active/active serving solution). With that, you
> >may be able limp along with a per-container grace period handling
> >scheme like you're proposing.
> >
> 
> Ok then. Keeping people from shooting themselves here sounds reasonable.
> And I like the idea of exporting a filesystem only from once per
> network namespace.

Unfortunately that's not going to get us very far, especially not in the
v4 case where we've got the common read-only pseudoroot that everyone
has to share.

--b.

> Looks like there should be a list of pairs
> "exported superblock - network namespace". And if superblock is
> exported already in other namespace, then export in new namespace
> have to be skipped (replaced?) with appropriate warning (error?)
> message shown in log.
> Or maybe we even should deny starting of NFS server if one of it's
> exports is shared already by other NFS server "instance"?
> But any of these ideas would be easy to implement in RAM, and thus
> it suits only for containers...
> 
> -- 
> Best regards,
> Stanislav Kinsbursky

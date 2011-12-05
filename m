Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:1257 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753601Ab1LESGw convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Dec 2011 13:06:52 -0500
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Subject: RE: [PATCH] nfs: only do COMMIT for range written with direct I/O
Date: Mon, 5 Dec 2011 10:06:49 -0800
Message-ID: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430C544CA3@SACMVEXC2-PRD.hq.netapp.com>
In-Reply-To: <20111205121106.25204c4c@corrin.poochiereds.net>
References: <1322662074-3843-1-git-send-email-jlayton@redhat.com> <20111205121106.25204c4c@corrin.poochiereds.net>
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Jeff Layton" <jlayton@redhat.com>
Cc: <linux-nfs@vger.kernel.org>, <khoa@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: Jeff Layton [mailto:jlayton@redhat.com]
> Sent: Monday, December 05, 2011 12:11 PM
> To: Jeff Layton
> Cc: Myklebust, Trond; linux-nfs@vger.kernel.org; khoa@us.ibm.com
> Subject: Re: [PATCH] nfs: only do COMMIT for range written with direct
I/O
> 
> On Wed, 30 Nov 2011 09:07:54 -0500
> Jeff Layton <jlayton@redhat.com> wrote:
> 
> > When given a range to write with unstable writes, the current code
> > always does a COMMIT of the entire file afterward. This is
potentially
> > expensive on some servers and unnecessary. Instead, just do a COMMIT
> > for the offset and count that was written.
> >
> > Khoa, who reported this bug, stated that this made a big difference
in
> > performance in their environment, which I believe involves GPFS on
the
> > server. He didn't pass along any hard numbers so I can't quantify
the
> > gain, but it stands to reason that clustered filesystems might
suffer
> > more contention issues when issuing a commit over the whole file.
> >
> > Reported-by: Khoa Huynh <khoa@us.ibm.com>
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> 
> Khoa found that he made a mistake when testing this originally, and
any
> benefit that the patch provides seems to be negligible. I still think
it's safe
> and reasonable to only issue a commit for the range that was written,
but
> there doesn't seem to be any compelling need for this patch right now.
> 
> Trond, do you have an opinion here? Should we go ahead and commit this
> patch or something like it, or leave well-enough alone?

I'd prefer to wait until I see a tangible benefit. I know that recent
kernels do have support for a COMMIT range on the Linux kernel server
side, so maybe it is just a question of shooting up an ext4 or XFS based
server and running a few tests with a large O_DIRECT writer on one
client, and a smaller O_DIRECT writer on another...

Cheers
  Trond

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:10741 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751606Ab1LMPDD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Dec 2011 10:03:03 -0500
Date: Tue, 13 Dec 2011 10:02:52 -0500
From: Jeff Layton <jlayton@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: <linux-nfs@vger.kernel.org>, <khoa@us.ibm.com>
Subject: Re: [PATCH] nfs: only do COMMIT for range written with direct I/O
Message-ID: <20111213100252.63d7b401@tlielax.poochiereds.net>
In-Reply-To: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430C544CA3@SACMVEXC2-PRD.hq.netapp.com>
References: <1322662074-3843-1-git-send-email-jlayton@redhat.com>
	<20111205121106.25204c4c@corrin.poochiereds.net>
	<2E1EB2CF9ED1CB4AA966F0EB76EAB4430C544CA3@SACMVEXC2-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 5 Dec 2011 10:06:49 -0800
"Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> > -----Original Message-----
> > From: Jeff Layton [mailto:jlayton@redhat.com]
> > Sent: Monday, December 05, 2011 12:11 PM
> > To: Jeff Layton
> > Cc: Myklebust, Trond; linux-nfs@vger.kernel.org; khoa@us.ibm.com
> > Subject: Re: [PATCH] nfs: only do COMMIT for range written with direct
> I/O
> > 
> > On Wed, 30 Nov 2011 09:07:54 -0500
> > Jeff Layton <jlayton@redhat.com> wrote:
> > 
> > > When given a range to write with unstable writes, the current code
> > > always does a COMMIT of the entire file afterward. This is
> potentially
> > > expensive on some servers and unnecessary. Instead, just do a COMMIT
> > > for the offset and count that was written.
> > >
> > > Khoa, who reported this bug, stated that this made a big difference
> in
> > > performance in their environment, which I believe involves GPFS on
> the
> > > server. He didn't pass along any hard numbers so I can't quantify
> the
> > > gain, but it stands to reason that clustered filesystems might
> suffer
> > > more contention issues when issuing a commit over the whole file.
> > >
> > > Reported-by: Khoa Huynh <khoa@us.ibm.com>
> > > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > 
> > Khoa found that he made a mistake when testing this originally, and
> any
> > benefit that the patch provides seems to be negligible. I still think
> it's safe
> > and reasonable to only issue a commit for the range that was written,
> but
> > there doesn't seem to be any compelling need for this patch right now.
> > 
> > Trond, do you have an opinion here? Should we go ahead and commit this
> > patch or something like it, or leave well-enough alone?
> 
> I'd prefer to wait until I see a tangible benefit. I know that recent
> kernels do have support for a COMMIT range on the Linux kernel server
> side, so maybe it is just a question of shooting up an ext4 or XFS based
> server and running a few tests with a large O_DIRECT writer on one
> client, and a smaller O_DIRECT writer on another...
> 

Khoa went back and did his tests and they confirm that there was no
tangible benefit in his environment. I did some minimal testing on
other rigs too, but also didn't see any clear benefit.

Of course, this is highly server-dependent, so there may be places
where this matters more, but for now I don't know of any. At this
point, I suggest we drop this patch for now. If we can note some
tangible benefit later, we can resurrect it then.

Thanks,
-- 
Jeff Layton <jlayton@redhat.com>

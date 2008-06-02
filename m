From: Jeff Layton <jlayton@redhat.com>
Subject: Re: Nfs filesystem corruption(?) after kmail crash
Date: Mon, 2 Jun 2008 09:43:22 -0400
Message-ID: <20080602094322.79a40c29@tleilax.poochiereds.net>
References: <9e8c52a20805140532w2bcfeff3n896fa5a9b0e82b5@mail.gmail.com>
	<20080519144806.GB7622@fieldses.org>
	<9e8c52a20805230744m2f7488e5q2867674f2987444@mail.gmail.com>
	<RTPCLUEXC1-PRDRXf2L00000168@RTPMVEXC1-PRD.hq.netapp.com>
	<9e8c52a20805260144u34f81996oa27475cc4c2e72d2@mail.gmail.com>
	<20080526074054.141945a7@tleilax.poochiereds.net>
	<9e8c52a20805270515o14a7ded6ne1737a827c91d2a7@mail.gmail.com>
	<RTPCLUEXC1-PRDqYW8B0000016d@RTPMVEXC1-PRD.hq.netapp.com>
	<9e8c52a20805270837i73d51bdbwa66aead92ee5d3e3@mail.gmail.com>
	<9e8c52a20806020605u736e758bsfe24dac02c8acdfe@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org
To: "Alexander Borghgraef" <alexander.borghgraef.rma@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:53029 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752596AbYFBNnZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Jun 2008 09:43:25 -0400
In-Reply-To: <9e8c52a20806020605u736e758bsfe24dac02c8acdfe-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2 Jun 2008 15:05:17 +0200
"Alexander Borghgraef" <alexander.borghgraef.rma@gmail.com> wrote:

> Nobody? Anyone care to tell me how to interpret the strace stat cur output?
> 

> lstat64("cur", 0xbfb81cb4)              = -1 ENOENT (No such file or directory)

File doesn't exist...

If this is from "ls -l" or something like that, that means that the
client did a READDIR or READDIRPLUS and saw a "cur" entry in the
directory with a particular filehandle. It then went back and did a
stat() against that filehandle and it was gone. The two possibilities
are that something removed that directory in the interim (possibly
replacing it with a new "cur" directory), or that the filehandle was
bad for some reason. I'm not aware of any bugs causing the latter, so
the former is the most likely.

You would think that the client would just use the info returned by
READDIRPLUS to fill out the stat() info, but it doesn't because stat()
calls generate an on-the-wire getattr (unless noatime is specified).
Peter S. and I were talking about this the other day. IMO, this
probably ought to be changed.

Most likely, this is the race that Tom described. ext3 has 1s
granularity on timestamps. It's easy to do *many* NFS operations within
1s. You might consider switching to a local filesystem on the server w/
more granular timestamps if you have a lot of concurrent activity like
this.

Cheers,
-- 
Jeff Layton <jlayton@redhat.com>

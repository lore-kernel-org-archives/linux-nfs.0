From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: O_NONBLOCK for regular files
Date: Wed, 13 Apr 2005 16:03:44 +1000
Message-ID: <1113372223.1956.628.camel@hole.melbourne.sgi.com>
References: <405C0DC0.3E61994@melbourne.sgi.com>
	 <1113353153.1956.481.camel@hole.melbourne.sgi.com>
	 <1113371790.9903.3.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Linux Filesystem Development List <linux-fsdevel@vger.kernel.org>,
	Al Viro <viro@parcelfarce.linux.theplanet.co.uk>,
	Neil Brown <neilb@cse.unsw.edu.au>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1113371790.9903.3.camel@lade.trondhjem.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Wed, 2005-04-13 at 15:56, Trond Myklebust wrote:
> on den 13.04.2005 Klokka 10:45 (+1000) skreiv Greg Banks:
> 
> > There's now a patch to actually do it, see
> > 
> > http://marc.theaimsgroup.com/?l=linux-nfs&m=111087383132762&w=2
> > 
> > Does anyone want to give a firm yea or nea to this approach?  I'd
> > really like to get this patch moving in the pipeline.
> 
> Nay...
> 
> if (rqstp->rq_vers == 3)
> 
>   is BAD! 
> 
> We're already busy with rq_vers == 4 (which has the same issues). This
> sort of condition needs to be handled in a more version-independent
> manner.

Yes, Neil already made this point.  I have a new version of the patch
which does

if (rqstp->rq_vers >= 3)

which I'll resend if there are no other issues.  I assume that'll
be good enough.

Any other issues?

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.



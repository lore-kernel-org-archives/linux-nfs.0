From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: O_NONBLOCK for regular files
Date: Tue, 12 Apr 2005 22:56:30 -0700
Message-ID: <1113371790.9903.3.camel@lade.trondhjem.org>
References: <405C0DC0.3E61994@melbourne.sgi.com>
	 <1113353153.1956.481.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Linux Filesystem Development List <linux-fsdevel@vger.kernel.org>,
	Al Viro <viro@parcelfarce.linux.theplanet.co.uk>,
	Neil Brown <neilb@cse.unsw.edu.au>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: <1113353153.1956.481.camel@hole.melbourne.sgi.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

on den 13.04.2005 Klokka 10:45 (+1000) skreiv Greg Banks:

> There's now a patch to actually do it, see
> 
> http://marc.theaimsgroup.com/?l=linux-nfs&m=111087383132762&w=2
> 
> Does anyone want to give a firm yea or nea to this approach?  I'd
> really like to get this patch moving in the pipeline.

Nay...

if (rqstp->rq_vers == 3)

  is BAD! 

We're already busy with rq_vers == 4 (which has the same issues). This
sort of condition needs to be handled in a more version-independent
manner.

Cheers,
  Trond

-- 
Trond Myklebust <trond.myklebust@fys.uio.no>


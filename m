From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: Re: [NFS] Re: [RFC] Multiple server selection and replicated mount
	failover
Date: Wed, 24 May 2006 13:52:48 -0700
Message-ID: <1148503968.4900.130.camel@seki.nac.uci.edu>
References: <Pine.LNX.4.64.0605021257500.3868@raven.themaw.net>
	 <Pine.LNX.4.64.0605241240200.3730@raven.themaw.net>
	 <44745972.2010305@redhat.com>  <6cpsi36tkf.fsf@sumu.lexma.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Peter Staubach <staubach@redhat.com>, Ian Kent <raven@themaw.net>,
	nfs@lists.sourceforge.net,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	autofs mailing list <autofs@linux.kernel.org>,
	strombrg@dcs.nac.uci.edu
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: "John T. Kohl" <jtk@us.ibm.com>
In-Reply-To: <6cpsi36tkf.fsf@sumu.lexma.ibm.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Wed, 2006-05-24 at 16:45 -0400, John T. Kohl wrote:

> 
> If you have multiple processes talking to different server replicas, can
> you then get cases where the processes aren't sharing the same files given
> the same name?

Sounds like it to me.

> Process "A" looks up /mount/a/b/c/file.c (using server 1) opens it and
> starts working on it.  It then sits around doing nothing for a while.
> 
> Process "B" cd's to /mount/a/b, gets a timeout, fails over to server 2,
> and then looks up "c/file.c" which will be referencing the object on
> server 2 ?

Yup.

> A & B then try locking to cooperate...

Yup.

To get good locking semantics, you'll probably need a distributed
filesystem like GFS or Lustre.

> Are replicas only useful for read-only copies?  If they're read-only, do
> locks even make sense?

Yes, they can - imagine a software system that wants to make sure only
one process is accessing some data at a time.  The lock might be in one
filesystem, but the data might be in another.  Or you might be reading
from a device that has really expensive seeks (a DVD comes to mind), so
you want to be sure that only one thing is reading from it at a time.
There are other possible scenarios I imagine, but many folks may be able
to live without any of them.  :)






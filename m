From: Ian Kent <raven@themaw.net>
Subject: Re: [autofs] Re: [NFS] Re: [RFC] Multiple server selection and
 replicated mount failover
Date: Mon, 29 May 2006 15:31:59 +0800 (WST)
Message-ID: <Pine.LNX.4.64.0605291525010.3436@raven.themaw.net>
References: <Pine.LNX.4.64.0605021257500.3868@raven.themaw.net>
 <Pine.LNX.4.64.0605241240200.3730@raven.themaw.net> <44745972.2010305@redhat.com>
 <6cpsi36tkf.fsf@sumu.lexma.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Peter Staubach <staubach@redhat.com>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	autofs mailing list <autofs@linux.kernel.org>,
	nfs@lists.sourceforge.net
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: "John T. Kohl" <jtk@us.ibm.com>
In-Reply-To: <6cpsi36tkf.fsf@sumu.lexma.ibm.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Thu, 24 May 2006, John T. Kohl wrote:

> >>>>> "PS" == Peter Staubach <staubach@redhat.com> writes:
> 
> PS> When the Solaris client gets a timeout from an RPC, it checks to see
> PS> whether this file and mount are failover'able.  This checks to see
> PS> whether there are alternate servers in the list and could contain a
> PS> check to see if there are locks existing on the file.  If there are
> PS> locks, then don't failover.  The alternative to doing this is to
> PS> attempt to move the lock, but this could be problematic because
> PS> there would be no guarantee that the new lock could be acquired.
> 
> PS> Anyway, if the file is failover'able, then a new server is chosen
> PS> from the list and the file handle associated with the file is
> PS> remapped to the equivalent file on the new server.  This is done by
> PS> repeating the lookups done to get the original file handle.  Once
> PS> the new file handle is acquired, then some minimal checks are done
> PS> to try to ensure that the files are the "same".  This is probably
> PS> mostly checking to see whether the sizes of the two files are the
> PS> same.
> 
> PS> Please note that this approach contains the interesting aspect that
> PS> files are only failed over when they need to be and are not failed over
> PS> proactively.  This can lead to the situation where processes using the
> PS> the file system can be talking to many of the different underlying
> PS> servers, all at the sametime.  If a server goes down and then comes back
> PS> up before a process, which was talking to that server, notices, then it
> PS> will just continue to use that server, while another process, which
> PS> noticed the failed server, may have failed over to a new server.
> 
> If you have multiple processes talking to different server replicas, can
> you then get cases where the processes aren't sharing the same files given
> the same name?
> 
> Process "A" looks up /mount/a/b/c/file.c (using server 1) opens it and
> starts working on it.  It then sits around doing nothing for a while.
> 
> Process "B" cd's to /mount/a/b, gets a timeout, fails over to server 2,
> and then looks up "c/file.c" which will be referencing the object on
> server 2 ?
> 
> A & B then try locking to cooperate...
> 
> Are replicas only useful for read-only copies?  If they're read-only, do
> locks even make sense?

Apps will take locks whether it makes sense or not.
So refusing to fail-over if locks are held is likely the best approach.

The case of replica filesystems themselves being updated could give rise 
to some interesting difficulties.

Ian


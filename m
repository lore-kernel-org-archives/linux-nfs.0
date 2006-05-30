From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [autofs] Re: [NFS] Re: [RFC] Multiple server selection and replicated mount failover
Date: Tue, 30 May 2006 08:02:03 -0400
Message-ID: <x49mzczwwjo.fsf@redhat.com>
References: <Pine.LNX.4.64.0605021257500.3868@raven.themaw.net>
	<Pine.LNX.4.64.0605241240200.3730@raven.themaw.net>
	<44745972.2010305@redhat.com> <6cpsi36tkf.fsf@sumu.lexma.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Staubach <staubach@redhat.com>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	autofs mailing list <autofs@linux.kernel.org>,
	nfs@lists.sourceforge.net, Ian Kent <raven@themaw.net>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: jtk@us.ibm.com (John T. Kohl)
In-Reply-To: <6cpsi36tkf.fsf@sumu.lexma.ibm.com> (John T. Kohl's message of "24 May 2006 16:45:04 -0400")
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

==> Regarding [autofs] Re: [NFS] Re: [RFC] Multiple server selection and replicated mount failover; jtk@us.ibm.com (John T. Kohl) adds:

>>>>>> "PS" == Peter Staubach <staubach@redhat.com> writes:
PS> When the Solaris client gets a timeout from an RPC, it checks to see
PS> whether this file and mount are failover'able.  This checks to see
PS> whether there are alternate servers in the list and could contain a
PS> check to see if there are locks existing on the file.  If there are
PS> locks, then don't failover.  The alternative to doing this is to
PS> attempt to move the lock, but this could be problematic because there
PS> would be no guarantee that the new lock could be acquired.

PS> Anyway, if the file is failover'able, then a new server is chosen from
PS> the list and the file handle associated with the file is remapped to
PS> the equivalent file on the new server.  This is done by repeating the
PS> lookups done to get the original file handle.  Once the new file handle
PS> is acquired, then some minimal checks are done to try to ensure that
PS> the files are the "same".  This is probably mostly checking to see
PS> whether the sizes of the two files are the same.

PS> Please note that this approach contains the interesting aspect that
PS> files are only failed over when they need to be and are not failed over
PS> proactively.  This can lead to the situation where processes using the
PS> the file system can be talking to many of the different underlying
PS> servers, all at the sametime.  If a server goes down and then comes
PS> back up before a process, which was talking to that server, notices,
PS> then it will just continue to use that server, while another process,
PS> which noticed the failed server, may have failed over to a new server.

jtk> If you have multiple processes talking to different server replicas,
jtk> can you then get cases where the processes aren't sharing the same
jtk> files given the same name?

jtk> Process "A" looks up /mount/a/b/c/file.c (using server 1) opens it and
jtk> starts working on it.  It then sits around doing nothing for a while.

jtk> Process "B" cd's to /mount/a/b, gets a timeout, fails over to server
jtk> 2, and then looks up "c/file.c" which will be referencing the object
jtk> on server 2 ?

jtk> A & B then try locking to cooperate...

jtk> Are replicas only useful for read-only copies?  If they're read-only,
jtk> do locks even make sense?

In the docs I've read, the replicated failover only works for read-only
file systems.  You can have a replicated server entry for read-write file
systems, but only one of those will be mounted by the automounter.  To
change servers would require a timeout (unmount) and subsequent lookup
(mount).

I don't think we need to try to kill ourselves by making this too complex.

-Jeff

From: Rick Macklem <rick@snowhite.cis.uoguelph.ca>
Subject: Re: nfs4 write delegation status
Date: Thu, 23 Jul 2009 11:10:06 -0400 (EDT)
Message-ID: <200907231510.LAA43979@snowhite.cis.uoguelph.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: erveith@de.ibm.com
Return-path: <nfsv4-bounces@linux-nfs.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

> > I really don't want to enable write delegations until we figure out how
> > to enforce them correctly against local (non-nfs) users of the exported
> > filesystem as well.  In addition to breaking delegations on read opens,
> > that means breaking delegations or doing a cb_getattr on operations like
> > stat.
> 
> do you know whether there are local FS where the maintainers at least plan
> to incorporate delegations?

I'm not a Linux guy, so I'm not familiar with the internal structure, but...
in general, I don't think the problem is with local file systems. Usually
the problem is with local system call access. For example, if a
process running locally on the server opens a file, the delegation should
be recalled, so that changes done locally on the client get flushed back
to the server. Also, a write delegation allows a client to do byte range
locking locally in the client, so the write delegation needs to be
recalled before anything gets a byte range lock locally in the server.

A Samba server running in the nfs server would be doing "local" ops
for the purpose of this discussion. (I'm not sure if Samba goes as far
as doing Open/Share locks for clients?)

rick

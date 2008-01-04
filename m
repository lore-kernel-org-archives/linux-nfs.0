From: Rick Macklem <rick@snowhite.cis.uoguelph.ca>
Subject: Re: A new NFSv4 server...
Date: Fri, 4 Jan 2008 12:28:26 -0500 (EST)
Message-ID: <200801041728.MAA19743@snowhite.cis.uoguelph.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org, gnb@melbourne.sgi.com
To: bfields@fieldses.org
Return-path: <nfsv4-bounces@linux-nfs.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

> As long as they persist while you have an open (or a delegation), it
> shouldn't be so hard to implement, should it?  If a filehandle expires,
> then you throw away any cache associated with it, but as long as no
> applications hold file descriptors for it, that's not a catastrophe.
> 
> But I'm a little confused whether rfc 3530's 4.2.3 gives a way for the
> server to express that guarantee.

Agreed, but I've always assumed the server can return NFS4ERR_FHEXPIRED
at any time. (It's listed as a error for many Ops, such as Read and Write.)
Also, what does a client do after a server reboot. It can't use
Open/Claim_previous for recovery.

Even if there is a "don't expire while Open" guarantee, it's still a pita
for the client to hang onto pathnames for directories and such, so that
they can re-lookup the fh. (And if that re-lookup happens to fail or end
up in a different place?)

rick

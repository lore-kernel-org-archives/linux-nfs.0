From: Rick Macklem <rick@snowhite.cis.uoguelph.ca>
Subject: Re: A new NFSv4 server...
Date: Fri, 4 Jan 2008 10:48:39 -0500 (EST)
Message-ID: <200801041548.KAA18953@snowhite.cis.uoguelph.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: gnb@melbourne.sgi.com
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

> You had me worried there for a moment, I thought you might be the first
> person to admit to liking the NFS4 protocol design.

I actually like quite a bit about it, although I agree that the XDR/Sun
RPC underpinnings are getting pretty tired (mid-1980s). I liked Sessions,
but think that it's gotten overly complex (why 5 required encrypted
checksum algorithms, wouldn't one be enough? for example). It would have been simpler,
if it had been "posix only" and not tried to be Windows compatible, but
I see the argument for Windows compatibility, hense the Open.

> The classic persistent file handles, for example, could be considered a
> major
> design flaw.  Firstly it makes the inode# -> dentry lookup a performance
> path
> for the underlying filesystem, which it isn't in any local load. 

Sounds like a server implementor's perspective. From a client implementor's
point of view, a T-stable file handle is a wonderful thing. I have no idea
how to correctly implement client side support for the volatile file
handles allowed in NFSv4. My client doesn't support them.

> Secondly, it's
> inherently insecure if you export anything less than an entire
> filesystem, unless
> you use a slow, buggy, and non-conformant hack like subtree_check.

Security is definitely an issue. The RPCSEC_GSS stuff works ok, but it
would have been nice to have some sort of "machine credential" that
could be used to authenticate a client (the host credential used by
SetClientID etc, kinda does that, but it isn't really specified). It
seems easier to do encryption/encrypted checksumming down by the transport
layer and not visible to the RPC. With that, many sites would be
comfortable with simpler user credentials than what Kerberos provides.
(Actually, I think most of the problem is that nice tools to set up and
 manage Kerberos aren't in most Unix-like systems, so sysadmins don't
 want to bother with Kerberos.)

rick

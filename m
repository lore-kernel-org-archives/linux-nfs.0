From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: setclientid: string in use on NFS v4 share on Debian Etch &
	hosts file "solution"
Date: Fri, 9 Nov 2007 14:55:30 -0500
Message-ID: <20071109195530.GH26826@fieldses.org>
References: <20071107003834.13713.73536.stgit@heimdal.trondhjem.org>
	<20071107003940.13713.65472.stgit@heimdal.trondhjem.org>
	<47323A62.9000803@oracle.com>
	<1194474763.7504.57.camel@heimdal.trondhjem.org>
	<47324E7C.4080808@u.washington.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, nfsv4@linux-nfs.org
To: Matt Weatherford <mbw@u.washington.edu>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <47324E7C.4080808@u.washington.edu>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <nfs.lists.sourceforge.net>

On Wed, Nov 07, 2007 at 03:47:08PM -0800, Matt Weatherford wrote:
> 
> Hi,
> 
> Im not sure this is the right place to ask, but Im wondering if someone can 
> illuminate what the following console messages means on my NFS v4 server....
> 
> 
> NFSD: setclientid: string in use by client(clientid 471c1b08/000003e9)
> NFSD: setclientid: string in use by client(clientid 471c1b08/00000410)
> nfs4_cb: server 10.11.12.221 not responding, timed out
> nfs4_cb: server 10.11.12.222 not responding, timed out
> NFSD: setclientid: string in use by client(clientid 471c1b08/0000043a)
> NFSD: setclientid: string in use by client(clientid 471c1b08/0000043c)
> NFSD: setclientid: string in use by client(clientid 471c1b08/00000447)
> NFSD: setclientid: string in use by client(clientid 471c1b08/0000044d)
> NFSD: setclientid: string in use by client(clientid 471c1b08/00000453)
> nfs4_cb: server 10.11.12.221 not responding, timed out

The "nfs4_cb: server not responding" mean the server is failing to open
a connection back to the client to use for callbacks, which means it
won't give out delegations.  That's not a fatal error at all, it's just
a possible lost opportunity for a performance improvement.

The "string in use" errors could be a sign that clients might fail to
recover locks when the server reboots.  But if the clients aren't
complaining, I wouldn't worry about it.  There have been changes to
nfs-utils and the kernel to make those clientid collisions less likely,
but I don't recall whether they went in before or after 2.6.18.

The "string in use" message is no longer logged by the server by default
in recent kernels, and the "not responding" comment needs to be removed
sometime too; I wouldn't worry about them.

> 
> (and yes, those IPs (10.11.12.221, 222) are good)
> 
> 
> I am on Debian Etch, on x86 hardware, using multiple NFS v4 clients with
> all the latest package updates.
> 
> I have multiple other NFS clients which the server is not complaining about.
> I am sharing NFSv4 shares on both (2) NIC's.
> 
> 
> NFS v4 client:
> 
> client42:~# uname -a
> Linux client42 2.6.18-5-686 #1 SMP Wed Oct 3 00:12:50 UTC 2007 i686 GNU/Linux
> client42:~# apt-show-versions | grep nfs
> libnfsidmap2/etch uptodate 0.18-0
> nfs-common/etch uptodate 1:1.0.10-6+etch.1
> client42:~#
> 
> 
> mount
> client42:~# mount
> ...omittted non v4 shares...
> yadda:/etch-llocal on /net/LLocal4 type nfs4 
> (rw,hard,intr,rsize=32768,wsize=32768,addr=192.168.105.123)
> client42:~>
> 
> 
> 
> 
> NFS v4 server:
> 
> yadda:~# apt-show-versions | grep -i nfs
> nfs-common/etch uptodate 1:1.0.10-6+etch.1
> nfs-kernel-server/etch uptodate 1:1.0.10-6+etch.1
> libnfsidmap2/etch uptodate 0.18-0
> yadda:~#
> 
> 
> Im not sure that this is the answer, but somewhere I saw a thread that I may 
> need to name the host like this in my hosts table on my nfsv4 client:
> 
> 127.0.0.1       localhost
> 127.0.1.1       client42
> 
> If this is the solution (is it?)

I suspect that'd be a step backwards.

--b.

From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: A Question about the 2.4.21 Pathconf patch
Date: 29 Apr 2003 21:55:25 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsptn5cc42.fsf@charged.uio.no>
References: <3EAE956E.9080205@RedHat.com> <shs4r4h5l52.fsf@charged.uio.no>
	<3EAEC774.20402@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19AbCN-0000L2-00
	for <nfs@lists.sourceforge.net>; Tue, 29 Apr 2003 12:55:31 -0700
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <3EAEC774.20402@RedHat.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

>>>>> " " == Steve Dickson <SteveD@redhat.com> writes:

     > So I'm just curious, why (from a protocol purest standpoint)
     > its not being used... and if it ever was used, what were the
     > results...

Oh... Are you perhaps thinking of the RedHat kernels, which contain a
patch to disable the FSINFO usage? That's Ben LaHaise's decision.

Earlier 2.4.x kernels had a bug in the IPv4 socket layer (in
ip_build_xmit_slow() to be more precise). When using non-blocking
writes, the socket layer would build incomplete sets of fragments,
then quit with an -EAGAIN. This had a disastrous DOS effect on certain
servers which weren't able to cope with the flood of orphaned
fragments.
Instead of waiting for the fix, Ben therefore decided to turn off the
automatic probing of r/wsize, and just make the default 4k.

This patch is not in the standard kernel, since we have a proper fix
for the real problem.

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

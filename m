From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: patch for using >16 groups on 2.6.x client
Date: Wed, 9 Feb 2005 00:44:26 +0100
Message-ID: <20050208234426.GA27766@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS mailing list <nfs@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cyf24-0006xE-PZ
	for nfs@lists.sourceforge.net; Tue, 08 Feb 2005 15:44:36 -0800
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1Cyf22-0007Fu-J7
	for nfs@lists.sourceforge.net; Tue, 08 Feb 2005 15:44:36 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Trond,

We all know that this annoying limit of 16 groups exists for AUTH_UNIX
authentication. In 2.6 the 32 groups kernel limit has even be removed
(essentially). It is unfortunate that this cannot be used over NFS in
many situations with linux, contrary to some other UNIXes such as tru64:
Tru64 has no 16 groups limit (its 32 on NFS there, using ONC RPC). Linux
supporting less with AUTH_UNIX hurts ;)

The many-groups patch tries to resolve this issue for the linux NFS
client (NFSv2 and NFSv3 for now), essentially removing this (IMHO silly)
limit. It has been written not to change behavior unless the current
process is a member of more than 16 groups. And in that case AUTH_UNIX
is broken anyway. The patch has been rewritten completely in order to
get rid of the uglyness discussed a long time ago.

The total patch consists of about 22 fragments of which a few (broken_suid
cleanup) have already been posted. But I didn't see the broken_suid
cleanup appear on www.linux-nfs.org though you said that you would take
such a patch. Any news on that one?

The parts below should be applied in order but after every single patch
the result will compile and should behave properly (2.6.11-rc3). All
patches < #30 may be useful anyway as cleanup because they only prepare
things. Patch 30:

	http://www.frankvm.com/nfs-ngroups/2.6.11/30.patch

is the most interesting one w.r.t. to understanding how it affects the
structure of the NFS client. See also the README in that directory. This
is a short description:

Posted:
#	comment
01	sunrpc cleanup, introduction of RPC_MAXGROUPS (16)
10	remove broken_suid mount option (1/2)
20	remove broken_suid mount option (2/2)

Trivial (unrelated) cleanup:
25	simplification: remove redundant and asymmetric get/put_rpccred()

Preparational things (cleanup, simplify):
26	simplify rpcauth credential code
27	comment fixes.
28	proc.c preparation
29	nfs3proc.c preparation

Core change:
30	Introduction of rpc_ngroups, unx_add_groups()

Slowly merge the new feature, don't enable yet:
40	add rpcauth_lookupcred() calls to nfs2_rpc() and nfs3_rpc().
	feature for all nfsx_rpc() callers for now.
41	nfs_open (open, opendir)
42	nfs_create
43	nfs_lookup (touches nfs_mknod, nfs_mkdir and nfs_symlink via nfs_instantiate)
44	nfs_link
45	nfs_unlink/nfs_rmdir (remove, rmdir)
46	nfs_symlink
47	nfs_mkdir
48	nfs_mknod (v2:create)
49	nfs_rename
50	nfs_permission (access) + dfprintk() reporting nfsx_proc_access result.
51	nfs_setattr

And finally enable it:
70	Enable the new code for NFSv2 and NFSv3.


I could make all these patches apply on top of
http://www.linux-nfs.org/Linux-2.6.x/2.6.11-rc3 and feed them slowly to
the list if you would like that.

NFSv4 requires some more work. I guess that a patch on NFSv4 will be
the least likely one to get merged so I've postponed it for now.

-- 
Frank


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

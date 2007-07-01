From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 00/21] 2nd prototype,
	in-kernel NFS mount option parsing
Date: Sun, 01 Jul 2007 12:12:08 -0400
Message-ID: <20070701155313.2786.27110.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I523S-0004R2-6B
	for nfs@lists.sourceforge.net; Sun, 01 Jul 2007 09:13:42 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I523V-0004vo-Gw
	for nfs@lists.sourceforge.net; Sun, 01 Jul 2007 09:13:45 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Here's a second take at implementing mount option parsing in the NFS
client rather than in the user-space mount command.

The series starts with a group of bug fixes and clean-ups, separated
out for easier review.  Then, several patches modify the RPC client
in some simple ways to make MNT requests generated in the kernel a
little easier.  Three more patches update the in-kernel MNT client
for everyday use.

The series finishes with patches that add a generic set of routines
to help process mount options, then do the real work of in-kernel
mount option processing.

The series has had build testing on x86 and x86_64.  It has had some
unit testing to show that the basic features work.  The series is
based on Trond's git repo as of last Thursday (6/28/07) -- 2.6.22-rc6.

At this point, I'd like some architecture review (ie "is this the
right way to do this") and to make the patches available for stricter
testing:

+  Penetration testing: Does this implementation introduce security
   exposures?

+  Full coverage testing: Support for infrequently used options and
   corner cases

+  Destructive testing: Exactly how does the new infrastructure
   respond when servers or networks are not available?

Once this is well-tested, acceptable, and the API is more or less
unchanging, the next steps include:

1.  Constructing the new mount commands to support this type of
    mount option parsing for NFS and NFSv4 mounts,

2.  Refactoring the NFSROOT mount support to use the new
    infrastructure, and

3.  Implementing support for IPv6 addressing during NFS mounts

4.  Attempting to implement mount server connection caching so that
    mounting several exports on the same server via TCP can reuse
    the socket to the mount server

Constructive comments are welcome.

-- 
corporate:    <chuck dot lever at oracle dot com>

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

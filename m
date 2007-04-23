From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/7] RFC: NFS in-kernel mount option parsing
Date: Mon, 23 Apr 2007 18:03:57 -0400
Message-ID: <20070423215419.24305.77890.stgit@schiele.dsl.sfldmi.ameritech.net>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hg6dl-0003P6-GX
	for nfs@lists.sourceforge.net; Mon, 23 Apr 2007 15:04:12 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hg6dn-0008Lz-UP
	for nfs@lists.sourceforge.net; Mon, 23 Apr 2007 15:04:12 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Here's a prototype implementation for processing NFS mount options in the
kernel instead of by the mount command.  In-kernel mount processing will allow
us to expand the functionality of the NFS mount process more easily, without
the need to co-ordinate changes between user-space and kernel.  This prototype
reproduces the functionality that exists today; near future plans include
support for IPv6 addressing and new transport protocols such as RDMA.

These patches are excerpted from my 2.6.21-rc patch series, available here:

  http://linux-nfs.org/cgi-bin/gitweb.cgi?p=cel-2.6.git;a=summary

The first 3 patches in this e-mail implement "-t nfs4" mount option parsing.
The second 4 patches implement mount option parsing for "-t nfs" file systems.
See the block comments introduced by these patches for details on how mount
functionality might be split between user-space and the kernel NFS client.

An unknown right now is how the new NFSv2/v3 mount process handles
unresponsive servers.  I plan to investigate that behavior this week, and to
start work on new user-space mount commands that use this new facility.

Please review and comment on these patches.

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

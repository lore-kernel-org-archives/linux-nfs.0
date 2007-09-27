From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 00/33] SVC Transport Switch
Date: Wed, 26 Sep 2007 23:57:51 -0500
Message-ID: <20070927045751.12677.98896.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, gnb@sgi.com
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IalVJ-0005aw-QH
	for nfs@lists.sourceforge.net; Wed, 26 Sep 2007 22:01:37 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IalVN-0001bS-Jq
	for nfs@lists.sourceforge.net; Wed, 26 Sep 2007 22:01:42 -0700
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

The following series implements a pluggable transport switch for
RPC servers. The biggest changes in this latest incarnation
are as follows:

- The overall design of the switch has been modified to be more similar
  to the client side, e.g.
	- There is a transport class structure svc_xprt_class, and
	- A transport independent structure is manipulated by xprt 
	  independent code (svc_xprt)
	- Further consolidation of transport independent logic out of 
	  transport providers and into transport independent code.
- Transport independent code has been broken out into a separate file
- Transport independent functions prevously adorned with _sock_ have
  had their names changed, e.g. svc_sock_enqueue
- atomic refcounts have been changed to krefs

The patchset is large (33 patches). There are some things that I would like to 
do that I didn't do because the patchset is already big.  For example, normalize 
the creation of nfsd listening endpoints using writes to the portlist file. 

I've attempted to organize the patchset such that logical changes are 
clearly reviewable without too much clutter from functionally empty name
changes.  This was somewhat awkward since intermediate patches may look 
ugly/broken/incomplete to some reviewers. This was to avoid losing the
context of a change while keeping each patch a reasonable size.  For example, 
making svc_recv transport independent and moving it to the svc_xprt file 
cannot be done in the same patch without losing the diffs to the svc_recv 
function.

This patchset has had limited testing with TCP/UDP. In this case, the tests 
included connectathon and building the kernel on an NFS mount running on the 
transport switch. 

This patchset is against the 2.6.23-rc8 kernel tree.

-- 
Signed-off-by: Tom Tucker <tom@opengridcomputing.com>

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

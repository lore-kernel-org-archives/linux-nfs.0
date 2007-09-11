From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 00/15] Patches for 2.6.24
Date: Tue, 11 Sep 2007 17:59:53 -0400
Message-ID: <20070911215143.26136.48085.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IVDmQ-0006pS-Oe
	for nfs@lists.sourceforge.net; Tue, 11 Sep 2007 15:00:22 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IVDmU-0001jc-FQ
	for nfs@lists.sourceforge.net; Tue, 11 Sep 2007 15:00:27 -0700
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

Hi Trond-

Here's a resend of the patches I sent a couple of weeks ago for inclusion in
2.6.24.  I hope I've sufficiently addressed your comments.

I built these against git://linux-nfs.org/nfs-2.6.git pulled a couple of days
ago.

01 through 06 are various clean-up patches.  07 through 12 are fixes for the
text-based mount API (these may collide with Talpey's recent patches).  13
through 15 replace the hard printks in NFS, NFSD, and lockd with dprintks.

-- 
corporate:    <chuck dot lever at oracle dot com>

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

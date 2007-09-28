From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/8] Refresh: Add string option parsing facility to
	mount.nfs
Date: Fri, 28 Sep 2007 16:36:24 -0400
Message-ID: <20070928202752.12851.56345.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IbMZT-0006U0-T8
	for nfs@lists.sourceforge.net; Fri, 28 Sep 2007 13:36:24 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IbMZY-00072v-T2
	for nfs@lists.sourceforge.net; Fri, 28 Sep 2007 13:36:29 -0700
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

Refresh of series that adds string option parsing to text-based mount.nfs.

I found that it is necessary to do some rather advanced lexical parsing of
the mount option string in order to handle version/protocol fallback.  So I've
implemented a data structure that can handle the parsing requirements, and
some wrapper logic to convert the mount option string to the new data
structure and then convert it back to a string before calling mount(2).

This series introduces the new facility and makes use of it for existing text-
based mount option processing (like adding "addr=" and so on).  In subsequent
patches I will make more use of the new facility.

This refresh also introduces a string tokenization facility that can handle
quoted commas, so we can deal properly with 'context="foo,bar"'.  Note that a
kernel patch will also be required for the NFS client to handle quoted commas
in the value part of NFS mount options.

-- 
corporate:    <chuck dot lever at oracle dot com>

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

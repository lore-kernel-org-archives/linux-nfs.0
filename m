From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/7] Add mount option parsing facility to text-based
	mount.nfs
Date: Tue, 25 Sep 2007 13:31:23 -0400
Message-ID: <20070925172637.4845.51938.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IaEG3-0001qd-2e
	for nfs@lists.sourceforge.net; Tue, 25 Sep 2007 10:31:39 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IaEG8-0001MK-0n
	for nfs@lists.sourceforge.net; Tue, 25 Sep 2007 10:31:44 -0700
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

Hi Neil-

Seven more patches for text-based mount.nfs.

I found that it is necessary to do some rather advanced lexical parsing of
the mount option string in order to handle version/protocol fallback.  So I've
implemented a data structure that can handle the parsing requirements, and
some wrapper logic to convert the mount option string to the new data
structure and then convert it back to a string before calling mount(2).

This series introduces the new facility and makes use of it for existing text-
based mount option processing (like adding "addr=" and so on).  In subsequent
patches I will make more use of the new facility.

-- 
corporate:    <chuck dot lever at oracle dot com>

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

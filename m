From: Donavan Pantke <avatar@dcr.net>
Subject: GETATTR returns spurious NOENT
Date: Fri, 26 Sep 2003 21:03:40 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200309262103.40680.avatar@dcr.net>
Reply-To: avatar@dcr.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A44VP-0006FH-00
	for <nfs@lists.sourceforge.net>; Mon, 29 Sep 2003 13:20:27 -0700
Received: from 216-7-67-178.ip.win.net ([216.7.67.178] helo=richard.dpapt.spellboundnet.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A44VO-0003mA-CG
	for nfs@lists.sourceforge.net; Mon, 29 Sep 2003 13:20:26 -0700
Received: from avatar.dpapt.spellboundnet.com (unknown [10.0.4.25])
	by richard.dpapt.spellboundnet.com (Postfix) with ESMTP id 4E5AC1CF9F
	for <nfs@lists.sourceforge.net>; Fri, 26 Sep 2003 20:01:11 -0400 (EDT)
To: nfs@lists.sourceforge.net
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

        Hi Guys,

        We have discovered an interesting behavior in the Linux knfsd server 
and the client, and I need your help in figuring out how to troubleshoot 
further.

        We have a SuSE SLES7 server (using Mantel's 2.4.18 errata kernel) 
talking to another SLES7 (also 2.4.18-based) NFS Server. The client takes 
incoming files (via our own hacked as crap protocol lol), and writes them to 
the NFS server. Then another thread is spawned which opens this newly written 
file and begins to read it for importing into a database. This happens a 
_lot_.

        Since the files are being written are read right back, the data is 
still being held in the read cache of the client. This is an assumption, 
since there's not a whole lot of read calls going on, but GETATTR's are being 
done (which I'm assuming are cache validations). When the NFS server is under 
load (normally from local processes like rsync being done concurrently),
 there are times when the GETATTR cache validation is getting a NOENT return 
from the server. We checked to make sure that the file wan't being deleted or 
something, but the client process will retry the import on the next run, and 
a LOOKUP and GETATTR for the same file both succeeded and returned the same 
inode numbers, so the file inode didn't change.

        Now, the 2 questions that come from this are: What is causing this 
spurious NOENT? And shouldn't the client either simply invalidate the cache 
instead of reporting an error to the calling process, or should it return a 
Bad file descriptior message. Currently, the NOENT is passed directly to the 
client process, which isn't a valid return code for a read() call.

        I have a packet capture of the whoel session, but it's 100M big, so I 
can post a smaller subset of it, just let me know how much you all want.

        Thanks!
	Donavan Pantke
	Network Engineer
	Appriss, Inc.


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

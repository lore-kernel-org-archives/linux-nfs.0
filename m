From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: New package of beta-level NFS client updates out for 2.4.19-rc1
Date: Mon, 8 Jul 2002 19:29:43 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <agcjiv$hpi$2@main.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17RcKe-0001m4-00
	for <nfs@lists.sourceforge.net>; Mon, 08 Jul 2002 10:29:52 -0700
To: nfs@lists.sourceforge.net,
 linux-kernel@vger.kernel.org
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>


Hi,

  There's a new NFS_ALL package full of NFS client updates out for 2.4.19-rc1.
New features include:

  - UDP message round trip timing in order to improve the timeout + resend 
cycle.
  - UDP congestion control as per Van Jacobson.
  - Further improvements to the close-to-open code
  - Full support for the NFSv3 ACCESS function (as required by people who want 
to use ACLs).

A full description of all the components and features can be found in the file

   http://www.fys.uio.no/~trondmy/src/2.4.19-rc1/HEADER.html

the patch itself can be found as

  http://www.fys.uio.no/~trondmy/src/2.4.19-rc1/linux-2.4.19-NFS_ALL.dif

For those who have been following the contents of these files, please note 
that a lot of changes have been made w.r.t. the 2.4.18 version:
Amongst other things, the 'ping' patch (see 
http://www.fys.uio.no/~trondmy/src/2.4.18/HEADER.html) is assumed to be 
replaced by the new and improved RPC round trip timing+congestion avoidance 
code.
The DIRECTIO patch has been removed pending a decision by Chuck on whether or 
not he wants to continue supporting it?

Happy testing,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Oh, it's good to be a geek.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

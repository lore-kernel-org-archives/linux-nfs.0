From: Bruce Allan <bwa@us.ibm.com>
Subject: > 16 groups patch from Frank van Maarseveen
Date: Fri, 30 Jul 2004 10:14:40 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1091207680.4797.47.camel@dyn319648.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sf.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BqayE-0002HY-OO
	for nfs@lists.sourceforge.net; Fri, 30 Jul 2004 10:15:02 -0700
Received: from e1.ny.us.ibm.com ([32.97.182.101])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1BqayE-0006Qt-BH
	for nfs@lists.sourceforge.net; Fri, 30 Jul 2004 10:15:02 -0700
To: trond.myklebust@fys.uio.no
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

Hi Trond,

I was wondering why Frank's patch to bypass the 16 group limitation in
RPC (http://frankvm.xs4all.nl/nfs-ngroups/) has not been incorporated
into mainline yet.  Is it because he has not addressed your
concern/recommendation as mentioned in
http://marc.theaimsgroup.com/?l=linux-nfs&m=87941837304355&w=2

If the patch were modified to follow your recommendation in the same
post, would that be acceptable?

Thanks much,
---
Bruce Allan  <bwa@us.ibm.com>
Software Engineer, Linux Technology Center
IBM Corporation, Beaverton OR
503-578-4187   IBM Tie-line 775-4187



-------------------------------------------------------
This SF.Net email is sponsored by OSTG. Have you noticed the changes on
Linux.com, ITManagersJournal and NewsForge in the past few weeks? Now,
one more big change to announce. We are now OSTG- Open Source Technology
Group. Come see the changes on the new OSTG site. www.ostg.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

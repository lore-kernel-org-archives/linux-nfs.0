From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 0/5] Enable extra optimisations on fcntl(F_UNLCK)
	requests on NFS
Date: Mon, 26 Jun 2006 19:29:36 -0400
Message-ID: <20060626232936.6059.50399.stgit@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fv0Wp-0001nU-9b
	for nfs@lists.sourceforge.net; Mon, 26 Jun 2006 16:30:03 -0700
Received: from dh134.citi.umich.edu ([141.211.133.134] helo=lade.trondhjem.org)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Fv0Wp-0003Hg-9d
	for nfs@lists.sourceforge.net; Mon, 26 Jun 2006 16:30:03 -0700
To: linux-kernel@vger.kernel.org
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

Hi,

The following set of patches enables the NFS client to determine more
accurately whether or not it needs to send an NLM/NFSv4 unlock request
if the process has outstanding posix or flock locks:
The current heuristic just assumes that if inode->i_flock is non-null, then
we should always spam the server with an unlock request upon close().

The patchset introduces a new flag to the posix_lock_file()/flock_lock_file()
interfaces that tells them to return -ENOENT if an F_UNLCK request results in
no action.

Cheers,
  Trond

Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

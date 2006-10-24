From: NeilBrown <neilb@suse.de>
Subject: [PATCH 000 of 4] Introduction Possibly patches for RPC client
	changes.
Date: Tue, 24 Oct 2006 12:48:45 +1000
Message-ID: <20061024122646.4426.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Olaf Kirch <okir@suse.de>, Chuck Lever <chuck.lever@oracle.com>,
	nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GcCLY-0001ku-Ln
	for nfs@lists.sourceforge.net; Mon, 23 Oct 2006 19:48:56 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GcCLX-0001GI-Eg
	for nfs@lists.sourceforge.net; Mon, 23 Oct 2006 19:48:57 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
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

These are very much suggestions only.  They have at best been lightly
tested.

The commonality is to try to be uniform in setting the 'hard' and
'intr' flags on requests.

The primary goal is to get rid of the 30second uninterruptible pause
when making a lock request while statd isn't running.

Comments very welcome.

NeilBrown


 [PATCH 001 of 4] Copy intr and soft flags to portmap-bind client
 [PATCH 002 of 4] Make the initial RPC PING interruptible.
 [PATCH 003 of 4] Make RPC 'ping' requests fail more quickly.
 [PATCH 004 of 4] Inherit soft/intr flags from NFS mount to lockd requests.

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

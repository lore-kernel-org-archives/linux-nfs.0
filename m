From: Jeremy Sanders <jss@ast.cam.ac.uk>
Subject: Permission denied
Date: Wed, 7 May 2003 16:47:14 +0100 (BST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.55.0305071639490.2587@xpc5.ast.cam.ac.uk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from gold.csi.cam.ac.uk ([131.111.8.12])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19DR91-0006lm-00
	for <nfs@lists.sourceforge.net>; Wed, 07 May 2003 08:47:47 -0700
Received: from cass41.ast.cam.ac.uk ([131.111.69.186])
	by gold.csi.cam.ac.uk with esmtp (Exim 4.12)
	id 19DR8V-0004Ln-00
	for nfs@lists.sourceforge.net; Wed, 07 May 2003 16:47:15 +0100
Received: from xserv1.ast.cam.ac.uk (IDENT:hA/GUl4d/v342GTMmXqlD4lnuicQ+IZT@xserv1.ast.cam.ac.uk [131.111.69.235])
	by cass41.ast.cam.ac.uk (8.12.9+Sun/8.12.9) with ESMTP id h47FlEgD018315
	for <nfs@lists.sourceforge.net>; Wed, 7 May 2003 16:47:15 +0100 (BST)
Received: from xpc5.ast.cam.ac.uk (IDENT:A80FkjC2RaeT36MULj2jvnVgfLJ4UgEo@xpc5.ast.cam.ac.uk [131.111.68.220])
	by xserv1.ast.cam.ac.uk (8.11.6/8.11.6) with ESMTP id h47FlEl23332
	for <nfs@lists.sourceforge.net>; Wed, 7 May 2003 16:47:14 +0100
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

I've seen this problem a couple of times (I think I reported it to the
list before but I can find the posting). Using the automounter to mount
home directories (rw,v3,rsize=8192,wsize=8192,hard,intr,udp,lock), it
seems that rebooting a Linux server can give a "Permission denied" on
the client. Further attempts at accessing the mountpoint give this error.
It can be fixed my umounting it (if nothing is using it), and reaccessing
the mountpoint.

The server is running RedHat's 2.4.18-27.7.x kernel, and the client is
using 2.4.18-17.7.x (unfortunately).

dmesg on the client shows:

nfs: server server.ast.cam.ac.uk not responding, still trying
nfs: task 57889 can't get a request slot
nfs: server server.ast.cam.ac.uk OK
nfs: server server.ast.cam.ac.uk OK

sendmail gave errors such as:

May  7 16:07:39 xserv1 sendmail[22255]: h47EwYl22254: forward
/home/gmorris: transient error: Timeout on file open
May  7 16:07:39 xserv1 sendmail[22195]: h47Eljl22194: forward
/home/gmorris: transient error: Timeout on file open
May  7 16:07:39 xserv1 sendmail[22255]: h47EwYl22254: forward
/home/gmorris/.forward: Permission denied
May  7 16:07:39 xserv1 sendmail[22195]: h47Eljl22194: forward
/home/gmorris/.forward: Permission denied

Any ideas? I suppose it's hard to diagnose this without a network traffic
analysis, and we're not using the standard kernel either. I suppose it
could be an automounter bug.


Jeremy

-- 
Jeremy Sanders <jss@ast.cam.ac.uk>   http://www-xray.ast.cam.ac.uk/~jss/
X-Ray Group, Institute of Astronomy, University of Cambridge, UK.
Public Key Server PGP Key ID: E1AAE053


-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

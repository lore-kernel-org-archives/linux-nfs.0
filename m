From: José Vicente Núñez Zuleta <josevnz@newbreak.com>
Subject: NFS Error message: what does it means
Date: Thu, 28 Mar 2002 20:27:39 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020328202739.68377785.josevnz@newbreak.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Received: from unknown.level3.net ([63.211.90.124] helo=lenbkx0001.newbreak.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16qlBE-00005Q-00
	for <nfs@lists.sourceforge.net>; Thu, 28 Mar 2002 17:27:48 -0800
Received: from linux0037 (hicks150-45.optonline.net [167.206.150.45] (may be forged))
	by lenbkx0001.newbreak.com (8.11.6/8.11.6) with SMTP id g2T1Rdr22290
	for <nfs@lists.sourceforge.net>; Thu, 28 Mar 2002 20:27:39 -0500 (EST)
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

We got this NFS error message in our servers (after using a very intensive NFS client):

Mar 21 15:49:26 10.1.40.44 automount[13439]: >> pmap_getmaps rpc problem: RPC:
Timed out
Mar 21 15:49:26 10.1.40.44 automount[13439]: >> mount: RPC: Unable to receive;
errno = Connection refused
Mar 21 15:49:26 10.1.40.44 automount[13439]: mount(nfs): nfs: mount failure
lnxsrv0001:/export/home/xxx on /home/xxx

The workaround is to restart the batch job and the problem disapears.

So far i havent seen anyone else reporting this problem (not on the list) and i not sure if the "optimizing tips" will help me at all.

Thanks in advance.

JV.

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Ulrich Hochholdinger <hochhold@fzi.de>
Subject: Stale NFS file handle with 2.4.17 / 2.4.18
Date: Tue, 14 May 2002 14:11:18 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020514121117.GA1460@horch.fzi.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from gate.fzi.de ([141.21.4.3])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 177b9N-0003zV-00
	for <nfs@lists.sourceforge.net>; Tue, 14 May 2002 05:11:29 -0700
Received: from hochhold by horch.fzi.de with local (Exim 3.34 #1 (Debian))
          id 177b9C-0000Tg-00 for <nfs@lists.sourceforge.net>;
          Tue, 14 May 2002 14:11:18 +0200
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

Hi,
I've problems with stale NFS file handles.

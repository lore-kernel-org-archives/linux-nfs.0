From: David Rees <dbr@greenhydrant.com>
Subject: Known NFS Read corruption in recent kernels with NFS_ALL?
Date: Fri, 18 Oct 2002 16:25:44 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021018162544.A18218@greenhydrant.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [208.48.139.185] (helo=forty.greenhydrant.com)
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 182gV5-0008EO-00
	for <nfs@lists.sourceforge.net>; Fri, 18 Oct 2002 16:25:51 -0700
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

I had been running 2.4.18 with NFS_ALL for quite some time with out any
problems on a number of machines running as both client and server using
nfsv3 and default mount options.

However, after upgrading a server to 2.4.19 with NFS_ALL (the old NFS_ALL
patch, not the one dated 5 Oct) I started noticing what seemed like random
read corruption from 2.4.18-NFS_ALL and 2.4.19-NFS_ALL clients.  From what I
can tell, the client is caching data from the server in some weird way and
never goes back to the server to actually verify the data, but this is just
a guess.

Is this a known issue?  If so, does the latest NFS_ALL patch solve this
issue or should I stay back at 2.4.18-NFS_ALL?

Thanks,
Dave


-------------------------------------------------------
This sf.net email is sponsored by:
Access Your PC Securely with GoToMyPC. Try Free Now
https://www.gotomypc.com/s/OSND/DD
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

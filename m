From: David Dougall <davidd@et.byu.edu>
Subject: assigning filesystem ID's
Date: Thu, 4 Apr 2002 11:59:10 -0700 (MST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.33.0204041155430.6266-100000@lewis.et.byu.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: <NFS@lists.sourceforge.net>
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

I heard recently that a feature had been added to the 2.5 kernel that
allowed the fsid to be assigned in the exports file.  Has this been
back-ported to the 2.4.x series?  Or is it just a part of the nfs-utils?
I have had problems in the past with failover nfs servers that mount the
partition, but it may be a different device number in /dev and therefore,
the clients return stale mount errors.  Will the fsid setting in the
exports file solve this problem?
Please advise.
Thanks
--David Dougall



_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

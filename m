From: "Steve Wolfe" <nw@codon.com>
Subject: rpc.statd port #, and other similar questions
Date: Wed, 4 Sep 2002 11:18:15 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <001d01c25437$0f66b940$d281f6cc@WEASEL>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from local.iboats.com ([204.246.129.200])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17mdiy-0001Ki-00
	for <nfs@lists.sourceforge.net>; Wed, 04 Sep 2002 10:13:52 -0700
To: <nfs@lists.sourceforge.net>
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


  On some of my NFS client machines, rpc.statd is being started with "-p
777", and on others, it is not.  The startup scripts used are the same,
and some clients do have different versions of nfs-utils.  Kernels are the
same (2.4.18).  Even when trying various combinations of nfs-utils
versions, I cannot duplicate the behaviour on all of the machines.

  I can't find reference to "-p 777" anywhere in the startup scripts, or
in the various rpc.* binaries.  Can anyone clue me in with where this is
coming from?

  On a related note, is it possible to make the lock manager to also use a
low-numbered port for firewalling purposes?

steve



-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

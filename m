From: "Nicholas Lafferty" <nlafferty@pennswoods.net>
Subject: Can't mount nfs rw
Date: Wed, 4 Sep 2002 13:39:40 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <003e01c2543a$0cb85ac0$9300a8c0@gridlock>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.pennswoods.net ([205.247.236.146])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17meJg-0008Dz-00
	for <nfs@lists.sourceforge.net>; Wed, 04 Sep 2002 10:51:48 -0700
Received: from gridlock (du217-63119103.dialupcu.pennswoods.net [63.119.103.217])
	by mail.pennswoods.net (Postfix) with SMTP id 99DF6289902
	for <nfs@lists.sourceforge.net>; Wed,  4 Sep 2002 13:51:42 -0400 (EDT)
To: "nfs" <nfs@lists.sourceforge.net>
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

I'm having problems getting my diskless clients to mount NFS directories in
Read-Write mode. I'm using bpbatch and tftp to transfer the kernel and a
ramdisk for the root file system. I pass an initscript to the kernel that
mounts the root file system of the server as read-only (mounts on /ro),
/home/guest/share mounts as ro2 (read-only), and /home/guest/01 mounts as
/rw (read-write). Then init is invoked. The problem is that all of the
mounts are read-only.

#Here is what my initscript does for the mounts.
mount-t nfs -o nolock,ro,vers=2 $SERVER:/      /ro
mount-t nfs -o nolock,ro,vers=2 $SERVER:/home/guest/share      /ro2
mount-t nfs -o nolock,rw,vers=2 $SERVER:/home/guest/$ID      /rw

/sbin/init '#'

# Here is my /etc/exports
/
192.168.0.0/255.255.255.0(ro,no_root_squash)
/home/guest/share       192.168.0.0(ro,no_root,squash)
/home/guest/01            192.168.0.0(rw,no_root_squash)
/home/guest/02            192.168.0.0(rw,no_root_squash)
/home/guest/03            192.168.0.0(rw,no_root_squash)

Any suggestions on some other things to try?

Nicholas Lafferty
Manager
Pennswoods.net
Country Club Mall



-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

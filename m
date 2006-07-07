From: "Steinar H. Gunderson" <sesse@debian.org>
Subject: More mount.nfs problems (1.0.9-pre1)
Date: Fri, 7 Jul 2006 21:10:03 +0200
Message-ID: <20060707191003.GA3626@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FyvjK-0005Bw-B5
	for nfs@lists.sourceforge.net; Fri, 07 Jul 2006 12:11:10 -0700
Received: from cassarossa.samfundet.no ([129.241.93.19] ident=Debian-exim)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1FyvjH-0001dx-Dg
	for nfs@lists.sourceforge.net; Fri, 07 Jul 2006 12:11:10 -0700
To: neilb@suse.de, nfs@lists.sourceforge.net
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

It looks like mount.nfs expects rpc.idmapd to put a lock in /var/lock/subsys
somewhere, but I can't find out how this is supposed to happen. IOW,
mount.nfs with a Kerberos mount currently gives a warning that rpc.idmapd is
probably not running, which is false. Any ideas?

/* Steinar */
-- 
Homepage: http://www.sesse.net/

Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: mschmitt@inf.ethz.ch
Subject: NFSd lockup
Date: Sat, 15 Nov 2003 07:16:42 +0100 (MET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1429.129.132.10.99.1068877002.squirrel@www.mail.inf.ethz.ch>
Mime-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AKtjj-00023D-00
	for <nfs@lists.sourceforge.net>; Fri, 14 Nov 2003 22:16:47 -0800
Received: from medoc.inf.ethz.ch ([129.132.178.200])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1AKtji-0005AM-P1
	for nfs@lists.sourceforge.net; Fri, 14 Nov 2003 22:16:46 -0800
Received: from localhost (localhost [127.0.0.1])
	by medoc.inf.ethz.ch (Postfix) with ESMTP id 448C5B5EE
	for <nfs@lists.sourceforge.net>; Sat, 15 Nov 2003 07:16:43 +0100 (MET)
Received: from medoc.inf.ethz.ch ([127.0.0.1])
 by localhost (medoc [127.0.0.1]) (amavisd-new, port 10024) with LMTP
 id 05658-01-9 for <nfs@lists.sourceforge.net>;
 Sat, 15 Nov 2003 07:16:42 +0100 (MET)
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

Dear list,

On a RedHat 7.3 NFS server with kernel 2.4.20-20.7smp, I'm currently
seeing the following effect after starting the nfs service:

The NFS service appears to start normally, exportfs is running correctly,
clients resume, reads and writes take place to the with usrquota enabled
ext3 filesystem. 3-10 seconds after that, this kernel message appears on
the console:

VFS: dqputduplicate(): Duplicated dquot put without duplicate reference

>From that moment on, the nfsd blocks. The load of the machine goes to 96
(the number of nfsds I set in /etc/sysconfig/nfs). Stopping the nfs
service now fails, it will leave one or two nfsd running in "D" state.

This is most probably no nfs problem, rather a problem of corrupted quota
information on the filesystem. I thought that I'd post this here anyway,
maybe there is a better way of handling this situation instead of having
to reset the machine?

Regards,
     Marc


-------------------------------------------------------
This SF. Net email is sponsored by: GoToMyPC
GoToMyPC is the fast, easy and secure way to access your computer from
any Web browser or wireless device. Click here to Try it Free!
https://www.gotomypc.com/tr/OSDN/AW/Q4_2003/t/g22lp?Target=mm/g22lp.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

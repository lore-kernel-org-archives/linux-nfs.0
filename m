From: "Timothy G. Wesemann" <timwese@voicenet.com>
Subject: nfs: server X not responding, still trying
Date: Mon, 3 Nov 2003 17:35:01 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <02ab01c3a25a$bdd030c0$de0167cf@voicenet.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AGnIK-0004Gs-00
	for <nfs@lists.sourceforge.net>; Mon, 03 Nov 2003 14:35:32 -0800
Received: from mail08.voicenet.com ([207.103.0.34])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.24)
	id 1AGnIJ-0003a5-IW
	for nfs@lists.sourceforge.net; Mon, 03 Nov 2003 14:35:31 -0800
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hola,

I have a number of client boxes that are mounting a single nfs file-server
(presently all machines are slackware 9.0; nfs-utils-1.0.6; 2.4.20 kernel)
over a 100bt switched private network which is not congested at all. The
machines are all using the original Becker EtherExpressPro/100 kernel
modules statically compiled.

When all of the above machines were running 2.4.22, each machine had a
*constant* barrage of these in the syslog:

Nov  3 15:44:24 hostXX kernel: nfs: server fileserver-priv not responding,
still trying
Nov  3 15:44:25 hostXX kernel: nfs: server fileserver-priv OK
Nov  3 15:46:17 hostXX kernel: nfs: server fileserver-priv not responding,
still trying
Nov  3 15:46:17 hostXX kernel: nfs: server fileserver-priv OK

The client mount/fstab options are:
"rw,async,intr,vers=3,rsize=32768,wsize=32768" and the server's exports
options are: "rw,no_root_squash,async,no_subtree_check".

After digging through the archives, I found some references to Trond's
patches for 2.4.22 (which didn't seem to help in this situation) as well as
suggestions to revert back to 2.4.20 which seem to have helped the
situation. I also tried using TCP which worked great, but the performance
hit was too great.

These error accumulations now are much more rare with 2.4.20, however they
still exist and performance is still not what it should be. Also, we really
would prefer to run current release-quality kernel revs.

Does anyone have any suggestions as to what to try next?

--
Tim Wesemann


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?   SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

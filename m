From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: processes stuck in D state
Date: Tue, 6 May 2003 08:47:28 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C611312747A@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <nfs@lists.sourceforge.net>,
   "linux kernel mailing list" <linux-kernel@vger.kernel.org>,
   "Zeev Fisher" <Zeev.Fisher@il.marvell.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19D4fO-0000V8-00
	for <nfs@lists.sourceforge.net>; Tue, 06 May 2003 08:47:42 -0700
To: "Michael Buesch" <fsdeveloper@yahoo.de>
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

> To reproduce the problem:
> - - mount some nfs from a server in your lan.
> - - Open an app, that uses the mounted fs. I've simply opened a
>   konqueror-window for the directory where the nfs is mounted.
> - - shut down or crash the server or just pull the network-cable.
> - - Now the konqueror-process is nonkillable in D state. There's no
>   chance to kill it.

does the problem persist after you reconnect the network cable?
what happens when the server becomes available again?
are you mounting with UDP or TCP?


-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

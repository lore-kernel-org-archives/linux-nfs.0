From: Vincent Roqueta <vincent.roqueta@ext.bull.net>
Subject: Re: When does NFSv3 client uses FILE_SYNC?
Date: Wed, 10 Nov 2004 17:22:41 +0100
Message-ID: <200411101722.41797.vincent.roqueta@ext.bull.net>
References: <150dc27e04111008051d64dbd1@mail.gmail.com> <200411101721.40039.vincent.roqueta@ext.bull.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CRv9h-0006RB-0O
	for nfs@lists.sourceforge.net; Wed, 10 Nov 2004 08:17:09 -0800
Received: from ecbull20.frec.bull.fr ([129.183.4.3])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CRv9e-0008P7-Ph
	for nfs@lists.sourceforge.net; Wed, 10 Nov 2004 08:17:08 -0800
Received: from dhcp0527.frec.bull.fr (dhcp0527.frec.bull.fr [129.183.101.236])
	by ecbull20.frec.bull.fr (8.9.2/8.9.1) with ESMTP id RAA17412
	for <nfs@lists.sourceforge.net>; Wed, 10 Nov 2004 17:16:32 +0100
To: nfs@lists.sourceforge.net
In-Reply-To: <200411101721.40039.vincent.roqueta@ext.bull.net>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Le mercredi 10 Novembre 2004 17:21, vous avez =E9crit=A0:
 Le mercredi 10 Novembre 2004 17:05, Oren D a =E9crit=A0:
 > Hi all,
 >
 > Can someone please list for me the conditions under which an NFSv3
 > client would send FILE_SYNC write requests?
 >
 > I have the filesystem exported on the server with the sync option
 > (which is not supposed to prevent the client from writing with
 > UNSTABLE),
 > and mounted from the client with the default mount options.
 >
 > And still i have a user-space application that generates WRITEs with
 > FILE_SYNC!
 >
 > This is what I know that can make the client write using FILE_SYNC:
 > - mount -o sync
 > - open(...,O_SYNC)

 What kernel is it?
 For a 2.6.x one, if the export's sync option is set all request will be
 synchronised, (even if the file is opened async... )

 (I remember some problems with that... )


 Vincent


-------------------------------------------------------
This SF.Net email is sponsored by:
Sybase ASE Linux Express Edition - download now for FREE
LinuxWorld Reader's Choice Award Winner for best database on Linux.
http://ads.osdn.com/?ad_id=5588&alloc_id=12065&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

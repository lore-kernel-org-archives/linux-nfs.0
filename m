From: Oren D <oren01@gmail.com>
Subject: When does NFSv3 client uses FILE_SYNC?
Date: Wed, 10 Nov 2004 18:05:30 +0200
Message-ID: <150dc27e04111008051d64dbd1@mail.gmail.com>
Reply-To: Oren D <oren01@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CRuyU-00051X-HI
	for nfs@lists.sourceforge.net; Wed, 10 Nov 2004 08:05:34 -0800
Received: from rproxy.gmail.com ([64.233.170.194])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CRuyT-0003TY-5K
	for nfs@lists.sourceforge.net; Wed, 10 Nov 2004 08:05:34 -0800
Received: by rproxy.gmail.com with SMTP id y7so5225rne
        for <nfs@lists.sourceforge.net>; Wed, 10 Nov 2004 08:05:32 -0800 (PST)
To: nfs@lists.sourceforge.net
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

Hi all,

Can someone please list for me the conditions under which an NFSv3
client would send FILE_SYNC write requests?

I have the filesystem exported on the server with the sync option
(which is not supposed to prevent the client from writing with
UNSTABLE),
and mounted from the client with the default mount options.

And still i have a user-space application that generates WRITEs with FILE_SYNC!

This is what I know that can make the client write using FILE_SYNC:
- mount -o sync
- open(...,O_SYNC)

Thanks,
Oren.


-------------------------------------------------------
This SF.Net email is sponsored by:
Sybase ASE Linux Express Edition - download now for FREE
LinuxWorld Reader's Choice Award Winner for best database on Linux.
http://ads.osdn.com/?ad_id=5588&alloc_id=12065&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: performance question
Date: Mon, 31 Mar 2003 13:45:24 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <6440EA1A6AA1D5118C6900902745938E07D55480@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19075v-0001gn-00
	for <nfs@lists.sourceforge.net>; Mon, 31 Mar 2003 13:45:31 -0800
To: <jp@pour.midcoast.com>
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

hi jp-

> What is possible for me to improve without moving to Gig-Ethernet?
>=20
> I've tried both TCP and UDP NFS. rsize & wsize or=20
> 1024,1400,4096,8192. The larger
> two have horrid performance due to packet fragmentation. Like=20
> magnitudes worse.
> 1024, 1400, UDP and TCP all have similar performance for me.

this sounds like a network issue.  you should use a network
performance tool (like iPerf) to measure performance between
your client and server, and try to rectify any problems you
find there, before you work on NFS performance.

> Also, is it possible to clear the counters in nfsstat?

only via a client reboot.


-------------------------------------------------------
This SF.net email is sponsored by: ValueWeb: 
Dedicated Hosting for just $79/mo with 500 GB of bandwidth! 
No other company gives more support or power for your dedicated server
http://click.atdmt.com/AFF/go/sdnxxaff00300020aff/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: "Howie Xu" <howie@vmware.com>
Subject: RE: How to unlock a file if an NFSv3 client dies forever?
Date: Wed, 26 May 2004 13:06:08 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <4F28105F70F4324A8723F0C949088941BCB773@pa-exch5.vmware.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BT4fV-0001QJ-Ok
	for nfs@lists.sourceforge.net; Wed, 26 May 2004 13:06:29 -0700
Received: from mailout1.vmware.com ([65.113.40.130])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BT4fV-0002Jk-C4
	for nfs@lists.sourceforge.net; Wed, 26 May 2004 13:06:29 -0700
Received: from mailout1.vmware.com (mailout1.vmware.com [127.0.0.1])
	by mailout1.vmware.com (Postfix) with ESMTP id 6E1EF45D6
	for <nfs@lists.sourceforge.net>; Wed, 26 May 2004 13:06:26 -0700 (PDT)
Received: from mailhost1.vmware.com (mailhost1.vmware.com [10.16.12.135])
	by mailout1.vmware.com (Postfix) with ESMTP id 2349E45D5
	for <nfs@lists.sourceforge.net>; Wed, 26 May 2004 13:06:26 -0700 (PDT)
Received: from localhost (localhost [127.0.0.1])
	by mailhost1.vmware.com (Postfix) with ESMTP id 4FD916FC342
	for <nfs@lists.sourceforge.net>; Wed, 26 May 2004 13:06:33 -0700 (PDT)
Received: from pa-exch3.vmware.com (pa-exch3.vmware.com [10.16.15.61])
	by mailhost1.vmware.com (Postfix) with ESMTP id 0E6166FC342
	for <nfs@lists.sourceforge.net>; Wed, 26 May 2004 13:06:28 -0700 (PDT)
To: <nfs@lists.sourceforge.net>
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

Thanks for letting me the workaround, it is nice to know. I am =
implementing
my own NFS client, and of course I cannot expect my customers to do the =
same
trick.:)=20

This sounds a generic problem, and I wonder how other people deal with =
it?
NLM is useless to me if I cannot find a nicer solution around it.

Btw, anyone knows that NFSv4 is immune to this "dead lock" scenario?

thanks a lot,

-howie

> > For example, if my linux NFS client holds a write lock on=20
> /home/howie/README,
> > then crashes and I reinstall the OS upon rebooting. Does=20
> that mean my NFS
> > server will hold this lock on this file *forever*? The NFS locks are
> > advisory, but my other NFS clients who speak NLM with the=20
> same NFS server
> > will not be granted lock for a file no one else ever cares.:(
>=20
> Here's a hack for how to do it.
>=20
>=20
> On the client:
>=20
>         Stop the rpc.statd service
>         touch /var/lib/nfs/sm/<ip-address-of-my-server>
>         then restart rpc.statd
>=20
> Note that on some distributions, the path is /var/lib/nfs/statd/sm. It
> may also be that your distribution runs rpc.statd as an unprivileged
> user, in which case make sure that you chown the file
> <ip-address-of-my-server> to that unprivileged user account.
>=20
> Cheers,
>   Trond
>=20


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

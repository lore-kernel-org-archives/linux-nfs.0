From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: Debian Bug#203077: Locks not released on NFS client reboot
Date: Fri, 14 Jan 2005 13:46:40 -0800
Message-ID: <482A3FA0050D21419C269D13989C61130853961D@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CpZHM-0003iX-ME
	for nfs@lists.sourceforge.net; Fri, 14 Jan 2005 13:46:48 -0800
Received: from mx1.netapp.com ([216.240.18.38])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CpZHK-00062u-Lu
	for nfs@lists.sourceforge.net; Fri, 14 Jan 2005 13:46:48 -0800
Received: from svlexc01.hq.netapp.com (svlexc01.corp.netapp.com [10.57.156.135])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id j0ELkeZo026127
	for <nfs@lists.sourceforge.net>; Fri, 14 Jan 2005 13:46:40 -0800 (PST)
To: <nfs@lists.sourceforge.net>
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

> >> i poked around the nfs-fag and how-to and didn't see this... if i=20
> >> didn't miss it (quite possible) may suggest it be added?
> >
> > so far this has not been a common issue, but i will consider it.
>=20
> great.  it may not be common but it is, for a developer,=20
> __extrememely__ difficult to debug.  i guaruntee every=20
> government lab will have this issue without knowing it=20
> because of increased security policies.

general question, then:  what can we add to the client or server
implementation to make it easier to diagnose?


-------------------------------------------------------
The SF.Net email is sponsored by: Beat the post-holiday blues
Get a FREE limited edition SourceForge.net t-shirt from ThinkGeek.
It's fun and FREE -- well, almost....http://www.thinkgeek.com/sfshirt
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

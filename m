From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Newbie NFS permissions question.
Date: Wed, 19 Apr 2006 09:40:49 -0400
Message-ID: <44463DE1.3070308@RedHat.com>
References: <200604191020.k3JAKclw007010@main.games-master.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FWCvc-0008CL-Lf
	for nfs@lists.sourceforge.net; Wed, 19 Apr 2006 06:41:08 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FWCvZ-0000QB-Cy
	for nfs@lists.sourceforge.net; Wed, 19 Apr 2006 06:41:05 -0700
To: Tony <tony@games-master.co.uk>
In-Reply-To: <200604191020.k3JAKclw007010@main.games-master.co.uk>
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



Tony wrote:
> I=92ve used NFS in the past but only for file sharing, but now I need t=
o=20
> use it in a live environment for uses email/web etc across load balance=
d=20
> servers.
>=20
> The problem I have is that the maildirs have to be owned by the user=20
> they belong to as does the web content.
>=20
> However when I mount an NFS share on both servers it=92s mounted as roo=
t=20
> with full permissions.
What NFS version are you using 2, 3 or 4?

>=20
> The problem is every file/directory created in the mounted NFS share is=
=20
> also created owned by root, even when I try to change the permission to=
=20
> a different owner or try to chmod a file or directory it doesn=92t do=20
> anything.
Setting the 'no_root_squash' export option on the server might help...

steved.


-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

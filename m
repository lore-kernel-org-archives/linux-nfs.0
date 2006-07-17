From: Tony Reix <tony.reix@bull.net>
Subject: Re: [nfsv4] Native NFSv4 ACLs on Linux
Date: Mon, 17 Jul 2006 11:15:58 +0200
Message-ID: <1153127758.2871.19.camel@frecb000687.frec.bull.fr>
References: <200607141637.32246.agruen@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G2PCr-0001CU-F9
	for nfs@lists.sourceforge.net; Mon, 17 Jul 2006 02:16:01 -0700
Received: from ecfrec.frec.bull.fr ([129.183.4.8])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G2PCr-0002gE-6n
	for nfs@lists.sourceforge.net; Mon, 17 Jul 2006 02:16:01 -0700
To: nfsv4@ietf.org
In-Reply-To: <200607141637.32246.agruen@suse.de>
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

Le vendredi 14 juillet 2006 =E0 16:37 +0200, Andreas Gruenbacher a =E9crit :
> Hello,
> =

> This is to announce a prototype that implements NFSv4 ACLs natively on Li=
nux. =

> So far, the implementation supports NFSv4 ACLs on Ext3 filesystems. The c=
ode =

> is functional, but hasn't seen a whole lot of testing so far.

Do you mean you do not know where to find ACL test-suite ?
If yes, you should use LTP :
	http://ltp.sourceforge.net/
	ltp-full-20060615.tgz
	ltp-full-20060615/testcases/network/nfsv4/acl/,
which contains our ACL tests (see:
http://nfsv4.bullopensource.org/tools/tests_index.php , at the bottom).

Regards,
Tony



-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easi=
er
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=3Dlnk&kid=3D120709&bid=3D263057&dat=3D1=
21642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

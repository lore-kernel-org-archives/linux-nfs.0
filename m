From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: [SOLVED] RE: debugging failed lock recovery
Date: Tue, 1 Feb 2005 14:56:58 -0800
Message-ID: <482A3FA0050D21419C269D13989C6113085396C0@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cw6xG-00076T-F2
	for nfs@lists.sourceforge.net; Tue, 01 Feb 2005 14:57:06 -0800
Received: from mx1.netapp.com ([216.240.18.38])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1Cw6xE-0006cY-Fq
	for nfs@lists.sourceforge.net; Tue, 01 Feb 2005 14:57:05 -0800
Received: from svlexc02.hq.netapp.com (svlexc02.corp.netapp.com [10.57.157.136])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id j11MuxYx021086
	for <nfs@lists.sourceforge.net>; Tue, 1 Feb 2005 14:56:59 -0800 (PST)
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

for future reference:  this is generically described in the NFS FAQ.

  http://nfs.sourceforge.net/index.php#faq_d7



> summary of solution
>=20
>    - rpc.statd reports to server during lock recovery.  it=20
> uses the output of
>      gethostname (uname -n) by default.  in this case the=20
> client would attempt
>      lock recovery using this hostname and the server would=20
> refuse since it
>      expected to the see the name of the backdoor interface=20
> (client.b.domain)
>=20
>      rpc.statd needs to be started using the '-n' (name)=20
> option to override the
>      output of gethostname.  in our case (redhat) this is=20
> done by putting
>      something like the following
>=20
>        STATD_HOSTNAME=3Dclient.b.ngdc.noaa.gov
>=20
>      into the file /etc/sysconfig/nfs, which is, itself, sourced by
>      /etc/init.d/nfclock
>=20
> lockd recovery now operates correctly.  thanks to all who helped!


-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

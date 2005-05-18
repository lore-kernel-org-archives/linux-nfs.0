From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: Extremely high load on NFS clients wen the NFS server is down...
Date: Wed, 18 May 2005 12:32:03 -0700
Message-ID: <482A3FA0050D21419C269D13989C611308539B3A@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: "Steve Dickson" <SteveD@redhat.com>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DYUHC-0004p7-Uc
	for nfs@lists.sourceforge.net; Wed, 18 May 2005 12:32:18 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DYUHB-00059N-EM
	for nfs@lists.sourceforge.net; Wed, 18 May 2005 12:32:18 -0700
To: "J. Bruce Fields" <bfields@fieldses.org>,
	"Henrik Schmiediche" <henrik@stat.tamu.edu>
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

> On Wed, May 18, 2005 at 02:11:58PM -0500, Henrik Schmiediche wrote:
> >      Steve,
> > Thanks for your response. The command 'echo t >=20
> /proc/sysrq-trigger' does
> > nothing that I can tell.
>=20
> Check your logs--it should have dumped a bunch of task=20
> information into /var/log/messages.

only if you have enabled sysrq first:

  sudo sysctl -w kernel.sysrq=3D1


-------------------------------------------------------
This SF.Net email is sponsored by Oracle Space Sweepstakes
Want to be the first software developer in space?
Enter now for the Oracle Space Sweepstakes!
http://ads.osdn.com/?ad_id=7412&alloc_id=16344&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: network storage solutions - mounts [and other ranting]
Date: Thu, 15 May 2003 13:41:27 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C61131274D1@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19GPXo-00074o-00
	for <nfs@lists.sourceforge.net>; Thu, 15 May 2003 13:41:40 -0700
To: "Jacob" <jacob@jhu.edu>
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

jacob-

> 2. It is my experience that soft automount is more reliable in the
>    long run.  less corrupt data and fewer reboots.  -soft mounting
>    doesn't CAUSE corrupt data, badly synchronized distributed
>    processing does.  (read: pour[sic] programmer/programming)

just because you have never experienced a problem doesn't mean
it will never happen, and doesn't imply that this is a good
solution for others as well.

soft mounting *does* cause corruption.  you will realize that
once you examine exactly what happens during soft timeouts.

> ---------------------------------------------------------------
> Jacob, System Admin at Center for Language & Speech Processing
> mail: jacob@jhu.edu
> - wife, boy, girl, sheep, goats, donkey, fowl, beehives-
>=20
> > Message: 7
> > From: "Josefa Blevins" <6uvdc1ii2@yahoo.com.hk>
> > To: net-snmp-coders@lists.sourceforge.net
> > Cc: <net-snmp-users-request@lists.sourceforge.net>,=20
> <netsaintplug-devel@lists.sourceforge.net>,=20
> <nfs@lists.sourceforge.net>, <nms-cgi-support@lists.sourceforge.net>
> > Date: Mon, 28 Jan 02 21:54:04 GMT
> > Subject: [NFS] Debt Relief is ON THE WAY! thet jzczhwdxe
> >
> > This is a multi-part message in MIME format.
> <edited>
> >
> > --__--__--
> >
> > Message: 8
> > Date: Thu, 15 May 2003 13:37:00 -0400
> > From: Jeff Layton <jeffrey.b.layton@lmco.com>
> > To: beowulf@beowulf.org
> > Cc: Alvin Oga <alvin@Maggie.Linux-Consulting.com>,=20
> nfs@lists.sourceforge.net
> > Reply-to: jeffrey.b.layton@lmco.com
> > Organization: Lockheed-Martin Aeronautics Company
> > Subject: [NFS] Re: network storage solutions - mounts
> >
> > Alvin Oga wrote:
> >
> > > On Wed, 14 May 2003, Glen Kaukola wrote:
> > >
> > > > Alvin Oga wrote:
> > >
> > > some kernel folks will tell you that using soft mount WILL cause
> > > corrupt data  ... and that hard mount is better...
>=20
>=20
>=20
> -------------------------------------------------------
> Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
> The only event dedicated to issues related to Linux=20
> enterprise solutions
> www.enterpriselinuxforum.com
>=20
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>=20


-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS and Samba Winbindd
Date: Wed, 20 Jun 2007 10:18:21 -0400
Message-ID: <1182349101.6225.11.camel@heimdal.trondhjem.org>
References: <1181808534.2474.7.camel@merlin.linuxcoe.com>
	<1181835958.6957.2.camel@heimdal.trondhjem.org>
	<FC3FA7C4E1CA2348B5579A68B24556E941186E28B3@ABGEX72E.FSC.NET>
	<20070615114409.1b3909b6@slopi>
	<FC3FA7C4E1CA2348B5579A68B24556E941186E2B2D@ABGEX72E.FSC.NET>
	<FC3FA7C4E1CA2348B5579A68B24556E94D044BB3E5@ABGEX72E.FSC.NET>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Chris Osicki <osk@admin.swisscom-mobile.ch>,
	"nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
To: "Laurenz, Dirk" <Dirk.Laurenz@fujitsu-siemens.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I1112-0002sJ-DW
	for nfs@lists.sourceforge.net; Wed, 20 Jun 2007 07:18:36 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX18QqZcfeAss9aBCNuH+PcB2TU26YnaQfK8=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I110x-0007YZ-Ri
	for nfs@lists.sourceforge.net; Wed, 20 Jun 2007 07:18:34 -0700
In-Reply-To: <FC3FA7C4E1CA2348B5579A68B24556E94D044BB3E5@ABGEX72E.FSC.NET>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Wed, 2007-06-20 at 07:31 +0200, Laurenz, Dirk wrote:
> Hello List,
> 
> the problem still persists. Does anyone have an idea?
> Can i increase the debug level a little bit to see, what
> the nfsd is doing to resolv memberships?

Do you have /lib/libnss_winbind.so installed, have you set up smb.conf
correctly, logged into the domain and started winbind? (see the full
description in "man winbind").

If it is all set up correctly, then you should be able to type

	getent group TESTGROUP

on the command line, and see the group TESTGROUP being resolved to the
correct Windoze group entry.

Trond

> > -----Original Message-----
> > From: nfs-bounces@lists.sourceforge.net
> > [mailto:nfs-bounces@lists.sourceforge.net] On Behalf Of Laurenz, Dirk
> > Sent: Friday, June 15, 2007 11:58 AM
> > To: Chris Osicki; nfs@lists.sourceforge.net
> > Subject: Re: [NFS] NFS and Samba Winbindd
> >
> > Hi,
> >
> > sorry, i mistyped this in the email on the server it is
> > correctly typed
> >
> > > -----Original Message-----
> > > From: nfs-bounces@lists.sourceforge.net
> > > [mailto:nfs-bounces@lists.sourceforge.net] On Behalf Of Chris Osicki
> > > Sent: Friday, June 15, 2007 11:44 AM
> > > To: nfs@lists.sourceforge.net
> > > Subject: Re: [NFS] NFS and Samba Winbindd
> > >
> > >
> > >
> > > Hi
> > >
> > > Shouldn't it read winbind instead of winbindd in nsswitch.conf?
> > >
> > > Regards,
> > > Chris
> > >
> > > On Fri, 15 Jun 2007 08:50:36 +0200
> > > "Laurenz, Dirk" <Dirk.Laurenz@fujitsu-siemens.com> wrote:
> > >
> > > > Hi,
> > > >
> > > > i have the following problem, which i'm not able to solve.
> > > >
> > > > The setup is as follows:
> > > >
> > > > Linux 2.6 Kernel (SLES9-32bit, Post SP3)
> > > > nssswitch.conf
> > > > [...]
> > > > groups: files ldap windbindd
> > > > [...]
> > > >
> > > > A user in a an global samba/ldap group. This group is in a
> > > local winbindgroup TESTGROUP.
> > > > (This is right concept used and works for samba shares and
> > > interactive logons directly to the server)
> > > >
> > > > There is a directory /test with the only acl TESTGROUP:rwx
> > > >
> > > > This works:
> > > >   su - $user
> > > >   cd /work
> > > >   mkdir test
> > > >
> > > > So all right's a resolved correctly
> > > >
> > > > This works not
> > > > exportfs *:/work -o all_squash,anonuid=12345,anongid=12345
> > > >
> > > > uid of $user is 12345
> > > >
> > > > mount /work on some host on /mnt
> > > > cd /mnt on the nfs client results in Permission denied
> > > >
> > > > setting an acl:
> > > >   setfacl -m u:$User:rwx
> > > >
> > > > results in cd /mnt and ls is working.
> > > >
> > > > my question is now:
> > > > is the nfsd unable to resolv winbindd local groups?
> > > >
> > > > Mit freundlichem Gruss,
> > > >
> > > > Dirk Laurenz
> > > > Systems Engineer
> > > > S DE SE PS N/O
> > > > Fujitsu Siemens Computers
> > > > Hildesheimer Strasse 25
> > > > 30880 Laatzen
> > > > Germany
> > > >
> > > > Telephone:              +49 511 84 89 18 08
> > > > Telefax:                +49 511 84 89 25 18 08
> > > > Mobile:         +49 170 22 10 781
> > > > Email:          mailto: dirk.laurenz@fujitsu-siemens.com
> > > > Internet:               http://www.fujitsu-siemens.com
> > > > Firmenangaben:          http://www.fujitsu-siemens.de/imprint.html
> > > >
> > > >
> > > >
> > > >
> > > >
> > >
> > > --------------------------------------------------------------
> > > -----------
> > > This SF.net email is sponsored by DB2 Express
> > > Download DB2 Express C - the FREE version of DB2 express and take
> > > control of your XML. No limits. Just data. Click to get it now.
> > > http://sourceforge.net/powerbar/db2/
> > > _______________________________________________
> > > NFS maillist  -  NFS@lists.sourceforge.net
> > > https://lists.sourceforge.net/lists/listinfo/nfs
> > >
> >
> > --------------------------------------------------------------
> > -----------
> > This SF.net email is sponsored by DB2 Express
> > Download DB2 Express C - the FREE version of DB2 express and take
> > control of your XML. No limits. Just data. Click to get it now.
> > http://sourceforge.net/powerbar/db2/
> > _______________________________________________
> > NFS maillist  -  NFS@lists.sourceforge.net
> > https://lists.sourceforge.net/lists/listinfo/nfs
> >
> 
> -------------------------------------------------------------------------
> This SF.net email is sponsored by DB2 Express
> Download DB2 Express C - the FREE version of DB2 express and take
> control of your XML. No limits. Just data. Click to get it now.
> http://sourceforge.net/powerbar/db2/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

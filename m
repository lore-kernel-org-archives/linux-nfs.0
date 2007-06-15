From: Chris Osicki <osk@admin.swisscom-mobile.ch>
Subject: Re: NFS and Samba Winbindd
Date: Fri, 15 Jun 2007 11:44:09 +0200
Message-ID: <20070615114409.1b3909b6@slopi>
References: <1181808534.2474.7.camel@merlin.linuxcoe.com>
	<1181835958.6957.2.camel@heimdal.trondhjem.org>
	<FC3FA7C4E1CA2348B5579A68B24556E941186E28B3@ABGEX72E.FSC.NET>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hz8Lt-0006f8-76
	for nfs@lists.sourceforge.net; Fri, 15 Jun 2007 02:44:21 -0700
Received: from outmail20.swisscom.com ([138.190.3.140] helo=mrp.swissptt.ch)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Hz8Lt-0003Hz-T6
	for nfs@lists.sourceforge.net; Fri, 15 Jun 2007 02:44:24 -0700
Received: from slopi.osk.ch (mwdsp001.swissptt.ch [10.225.18.78])
	by mrp.swissptt.ch with ESMTP id l5F9iA8B003935
	(using TLSv1/SSLv3 with cipher DHE-RSA-AES256-SHA (256 bits) verified
	NO)
	for <nfs@lists.sourceforge.net>; Fri, 15 Jun 2007 11:44:10 +0200 (MEST)
Received: from slopi (localhost [127.0.0.1])
	by slopi.osk.ch (8.14.0/8.13.7) with ESMTP id l5F9i91F016210
	for <nfs@lists.sourceforge.net>; Fri, 15 Jun 2007 11:44:09 +0200
In-Reply-To: <FC3FA7C4E1CA2348B5579A68B24556E941186E28B3@ABGEX72E.FSC.NET>
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



Hi

Shouldn't it read winbind instead of winbindd in nsswitch.conf?

Regards,
Chris

On Fri, 15 Jun 2007 08:50:36 +0200
"Laurenz, Dirk" <Dirk.Laurenz@fujitsu-siemens.com> wrote:

> Hi,
> 
> i have the following problem, which i'm not able to solve.
> 
> The setup is as follows:
> 
> Linux 2.6 Kernel (SLES9-32bit, Post SP3)
> nssswitch.conf
> [...]
> groups: files ldap windbindd
> [...]
> 
> A user in a an global samba/ldap group. This group is in a local winbindgroup TESTGROUP.
> (This is right concept used and works for samba shares and interactive logons directly to the server)
> 
> There is a directory /test with the only acl TESTGROUP:rwx
> 
> This works:
>   su - $user
>   cd /work
>   mkdir test
> 
> So all right's a resolved correctly
> 
> This works not
> exportfs *:/work -o all_squash,anonuid=12345,anongid=12345
> 
> uid of $user is 12345
> 
> mount /work on some host on /mnt
> cd /mnt on the nfs client results in Permission denied
> 
> setting an acl:
>   setfacl -m u:$User:rwx
> 
> results in cd /mnt and ls is working.
> 
> my question is now:
> is the nfsd unable to resolv winbindd local groups?
> 
> Mit freundlichem Gruss,
> 
> Dirk Laurenz
> Systems Engineer
> S DE SE PS N/O
> Fujitsu Siemens Computers
> Hildesheimer Strasse 25
> 30880 Laatzen
> Germany
> 
> Telephone:              +49 511 84 89 18 08
> Telefax:                +49 511 84 89 25 18 08
> Mobile:         +49 170 22 10 781
> Email:          mailto: dirk.laurenz@fujitsu-siemens.com
> Internet:               http://www.fujitsu-siemens.com
> Firmenangaben:          http://www.fujitsu-siemens.de/imprint.html
> 
> 
> 
> 
> 

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

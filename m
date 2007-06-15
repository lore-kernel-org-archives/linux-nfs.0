From: "Laurenz, Dirk" <Dirk.Laurenz@fujitsu-siemens.com>
Subject: NFS and Samba Winbindd
Date: Fri, 15 Jun 2007 08:50:36 +0200
Message-ID: <FC3FA7C4E1CA2348B5579A68B24556E941186E28B3@ABGEX72E.FSC.NET>
References: <1181808534.2474.7.camel@merlin.linuxcoe.com>
	<1181835958.6957.2.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="_002_FC3FA7C4E1CA2348B5579A68B24556E941186E28B3ABGEX72EFSCNE_"
To: "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hz5dq-0006VW-S0
	for nfs@lists.sourceforge.net; Thu, 14 Jun 2007 23:50:42 -0700
Received: from dgate2.fujitsu-siemens.com ([217.115.66.36])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hz5dq-0002qs-Oq
	for nfs@lists.sourceforge.net; Thu, 14 Jun 2007 23:50:46 -0700
Received: from abgze77e.FSC.NET (abgze77e.fsc.net [172.25.138.143])
	by plam.pdb.fsc.net (8.12.6/8.12.6/SuSE Linux 0.6) with ESMTP id
	l5F6ocmo013854
	for <nfs@lists.sourceforge.net>; Fri, 15 Jun 2007 08:50:38 +0200
In-Reply-To: <1181835958.6957.2.camel@heimdal.trondhjem.org>
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

--_002_FC3FA7C4E1CA2348B5579A68B24556E941186E28B3ABGEX72EFSCNE_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Hi,

i have the following problem, which i'm not able to solve.

The setup is as follows:

Linux 2.6 Kernel (SLES9-32bit, Post SP3)
nssswitch.conf
[...]
groups: files ldap windbindd
[...]

A user in a an global samba/ldap group. This group is in a local winbindgro=
up TESTGROUP.
(This is right concept used and works for samba shares and interactive logo=
ns directly to the server)

There is a directory /test with the only acl TESTGROUP:rwx

This works:
  su - $user
  cd /work
  mkdir test

So all right's a resolved correctly

This works not
exportfs *:/work -o all_squash,anonuid=3D12345,anongid=3D12345

uid of $user is 12345

mount /work on some host on /mnt
cd /mnt on the nfs client results in Permission denied

setting an acl:
  setfacl -m u:$User:rwx

results in cd /mnt and ls is working.

my question is now:
is the nfsd unable to resolv winbindd local groups?

Mit freundlichem Gruss,

Dirk Laurenz
Systems Engineer
S DE SE PS N/O
Fujitsu Siemens Computers
Hildesheimer Strasse 25
30880 Laatzen
Germany

Telephone:              +49 511 84 89 18 08
Telefax:                +49 511 84 89 25 18 08
Mobile:         +49 170 22 10 781
Email:          mailto: dirk.laurenz@fujitsu-siemens.com
Internet:               http://www.fujitsu-siemens.com
Firmenangaben:          http://www.fujitsu-siemens.de/imprint.html






--_002_FC3FA7C4E1CA2348B5579A68B24556E941186E28B3ABGEX72EFSCNE_
Content-Type: text/x-vcard; name="Laurenz, Dirk.vcf"
Content-Description: Laurenz, Dirk.vcf
Content-Disposition: attachment; filename="Laurenz, Dirk.vcf"; size=0;
	creation-date="Fri, 25 Aug 2006 16:54:28 GMT";
	modification-date="Fri, 25 Aug 2006 16:54:28 GMT"
Content-Transfer-Encoding: base64

QkVHSU46VkNBUkQNClZFUlNJT046Mi4xDQpOOkxhdXJlbno7RGlyaw0KRk46TGF1cmVueiwgRGly
aw0KT1JHOkZTQztGU0MgUyBERSBTRSBQUyBOb3JkL09zdA0KVEVMO1dPUks7Vk9JQ0U6KzQ5ICg1
MTEpIDg0ODktMTgwOA0KVEVMO0NFTEw7Vk9JQ0U6KzQ5ICgxNzApIDIyMTAtNzgxDQpBRFI7V09S
Szo7LztIaWxkZXNoZWltZXIgU3RyYd9lIDI1O0hhbm5vdmVyIC8gTGFhdHplbjs7MzA4ODA7R2Vy
bWFueQ0KTEFCRUw7V09SSztFTkNPRElORz1RVU9URUQtUFJJTlRBQkxFOi89MEQ9MEFIaWxkZXNo
ZWltZXIgU3RyYT1ERmUgMjU9MEQ9MEFIYW5ub3ZlciAvIExhYXR6ZW4gMzA4ODA9MEQ9MEFHZXJt
YW55DQpFTUFJTDtQUkVGO0lOVEVSTkVUOkRpcmsuTGF1cmVuekBmdWppdHN1LXNpZW1lbnMuY29t
DQpSRVY6MjAwNjA4MjVUMTY1NDI4Wg0KRU5EOlZDQVJEDQo=

--_002_FC3FA7C4E1CA2348B5579A68B24556E941186E28B3ABGEX72EFSCNE_
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--_002_FC3FA7C4E1CA2348B5579A68B24556E941186E28B3ABGEX72EFSCNE_
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--_002_FC3FA7C4E1CA2348B5579A68B24556E941186E28B3ABGEX72EFSCNE_--

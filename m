From: Al Active <LLLActive@GMX.Net>
Subject: Re: Searching NFS Archives
Date: Wed, 11 Jan 2006 10:15:18 +0100
Message-ID: <1136970918.6819.62.camel@L10-WS-AWS1.AWS>
References: <1136907278.6837.12.camel@L10-WS-AWS1.AWS>
	 <200601101645.14166.vincent.roqueta@ext.bull.net>
	 <1136910191.6837.49.camel@L10-WS-AWS1.AWS>
	 <200601101745.42403.vincent.roqueta@ext.bull.net>
	 <1136967854.6819.27.camel@L10-WS-AWS1.AWS>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Vincent Roqueta <vincent.roqueta@ext.bull.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ewc4n-0007Dm-CO
	for nfs@lists.sourceforge.net; Wed, 11 Jan 2006 01:15:29 -0800
Received: from mail.gmx.net ([213.165.64.21])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1Ewc4j-0006v2-TF
	for nfs@lists.sourceforge.net; Wed, 11 Jan 2006 01:15:27 -0800
To: nfs@lists.sourceforge.net
In-Reply-To: <1136967854.6819.27.camel@L10-WS-AWS1.AWS>
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

Hello Vincent,

On Wed, 2006-01-11 at 09:24 +0100, Al Active wrote:=20
> On Tue, 2006-01-10 at 17:45 +0100, Vincent Roqueta wrote:
> > Le Mardi 10 Janvier 2006 17:23, Al Active a =C3=A9crit :
>=20
> >=20
> > What are the export options, both on data cluster and  NFS-Server Clu=
ster ?
> > Can you test Data Cluster to NFS-Shares Import  read write access fir=
st ?
> >=20
> > Vincent
> >=20


OK, I checked following:

On the Data-Cluster as NFS-Server exporting the Data:

- Directly on the /Data directory (mounted from the /dev/drbd0 primary)
  All read and writes possible with OpenOffice2 (OO2)
  and Linux's Text Editor (clu1 & root)
  /Data/Transfer/: chown clu1:users document.doc
  /Data/Transfer/: chmod 777 document.doc
  /Data/Transfer/: ls -l document.doc=20
  -rwxrwxrwx 1 clu1 users 117762006-01-11 08:48 document.doc=20
  =20
- Exports from the Data-Cluster as NFS-Server:
  /Data/NFS-Server/  *(rw,root_squash,sync)=20

On the NFS-Client:

- /Export/NFS-Server/Transfer/> ls -l document.doc
  -rwxrwxrwx 1 clu1 users 117762006-01-11 08:48 document.doc

- mount
  192.168.0.174:/Data/NFS-Server on /Export/NFS-Server type nfs
(rw,addr=3D192.168.0.174)

  Editing any plain text document works (local clu1 & root)
  Editing document.doc with OO2 error message:
   General input/output error while=20
   accessing /Export/NFS-Server/Transfer/document.doc

This error is true for all Microsoft documents (Word, Excel & Access)
that produces the error, even when I open it with OO2 on the NFS-Client
directly as well.

Only if this problem gets solved, I can look further at the Samba share
error in the windows network (which will probably also be caused by this
error)

Can it be something of an incompatibility between the users of the
NFS-Server and NFS-Client, even if clu1 has the same UID: 1001 and
member of the same groups on both of the two systems? Why only with the
Microsoft Office Data Files?

:-)
Al



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log fi=
les
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=3D7637&alloc_id=3D16865&op=3Dclick
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

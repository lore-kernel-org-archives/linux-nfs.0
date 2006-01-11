From: Al Active <LLLActive@GMX.Net>
Subject: Re: Searching NFS Archives
Date: Wed, 11 Jan 2006 11:51:11 +0100
Message-ID: <1136976671.6819.85.camel@L10-WS-AWS1.AWS>
References: <200601111140.30115.vincent.roqueta@ext.bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EwdZZ-0002hZ-4k
	for nfs@lists.sourceforge.net; Wed, 11 Jan 2006 02:51:21 -0800
Received: from mail.gmx.net ([213.165.64.21])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1EwdZW-0004RW-L1
	for nfs@lists.sourceforge.net; Wed, 11 Jan 2006 02:51:21 -0800
To: nfs@lists.sourceforge.net
In-Reply-To: <200601111140.30115.vincent.roqueta@ext.bull.net>
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

On Wed, 2006-01-11 at 11:40 +0100, Vincent Roqueta wrote:
> Le Mercredi 11 Janvier 2006 10:15, Al Active a =C3=A9crit :
> > Hello Vincent,
> >
> > On Wed, 2006-01-11 at 09:24 +0100, Al Active wrote:
> > > On Tue, 2006-01-10 at 17:45 +0100, Vincent Roqueta wrote:
> > > > Le Mardi 10 Janvier 2006 17:23, Al Active a =C3=A9crit :
> > > >
> > > >
> > > > What are the export options, both on data cluster and  NFS-Server
> > > > Cluster ? Can you test Data Cluster to NFS-Shares Import  read wr=
ite
> > > > access first ?
> > > >
> > > > Vincent
> >
> > OK, I checked following:
> >
> > On the Data-Cluster as NFS-Server exporting the Data:
> >
> > - Directly on the /Data directory (mounted from the /dev/drbd0 primar=
y)
> >   All read and writes possible with OpenOffice2 (OO2)
> >   and Linux's Text Editor (clu1 & root)
> >   /Data/Transfer/: chown clu1:users document.doc
> >   /Data/Transfer/: chmod 777 document.doc
> >   /Data/Transfer/: ls -l document.doc
> >   -rwxrwxrwx 1 clu1 users 117762006-01-11 08:48 document.doc
> >
> > - Exports from the Data-Cluster as NFS-Server:
> >   /Data/NFS-Server/  *(rw,root_squash,sync)
> >
> > On the NFS-Client:
> >
> > - /Export/NFS-Server/Transfer/> ls -l document.doc
> >   -rwxrwxrwx 1 clu1 users 117762006-01-11 08:48 document.doc
> >
> > - mount
> >   192.168.0.174:/Data/NFS-Server on /Export/NFS-Server type nfs
> > (rw,addr=3D192.168.0.174)
> >
> >   Editing any plain text document works (local clu1 & root)
> >   Editing document.doc with OO2 error message:
> >    General input/output error while
> >    accessing /Export/NFS-Server/Transfer/document.doc
> >
> > This error is true for all Microsoft documents (Word, Excel & Access)
> > that produces the error, even when I open it with OO2 on the NFS-Clie=
nt
> > directly as well.
>=20
> That is quite strange...
> Which kernel version are you using?
> Is there something "special" on machine (cpu, 64bits ...)

I am using Novell's SUSE 10.0 purchased Boxed Version. Kernel:

uname -a
Linux L10... 2.6.13-15-default #1 Tue Sep 13 14:56:15 UTC 2005 x86_64
x86_64 x86_64 GNU/Linux

As you can see it is a standard kernel on a x86_64 system

>=20
> > Only if this problem gets solved, I can look further at the Samba sha=
re
> > error in the windows network (which will probably also be caused by t=
his
> > error)
>=20
> True
>=20
> > Can it be something of an incompatibility between the users of the
> > NFS-Server and NFS-Client, even if clu1 has the same UID: 1001 and
> > member of the same groups on both of the two systems? Why only with t=
he
> > Microsoft Office Data Files?
>=20
> That should not be the case... and even if there was a problem at this =
point,
> the error must be "permission denied", not "I/O error", which reflect a=
n
> internal NFS problem.

I hope it is that simple...

>=20
> I suppose you are running nfsv3, can you try with the v4 one? (last ver=
sions
> are much more reliables than v3 ones... )
>=20

I am using the one with the above kernel. How do I find out which
version it is? From the /var/log/messages I see:
"Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory"; I
take it to be v4 then.

> Also, you should have interresting messages in the /var/log/message on =
NFS
> client and/or server
>=20

No messages on the NFS-Server regarding the problem.

On the Client:
Jan 11 11:40:21 L10 kcheckpass[3207]: Authentication failure for clu1
(invoked by uid 1001)=20
Jan 11 11:41:45 L10 su: (to root) clu1 on /dev/pts/6
Jan 11 11:43:10 L10 syslog-ng[3681]: STATS: dropped 88

The passwords are the same on both machines.

> Cordialement,
> Vincent


Regards,
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

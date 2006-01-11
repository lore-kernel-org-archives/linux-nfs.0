From: Vincent Roqueta <vincent.roqueta@ext.bull.net>
Subject: Re: Searching NFS Archives
Date: Wed, 11 Jan 2006 12:30:45 +0100
Message-ID: <200601111230.45581.vincent.roqueta@ext.bull.net>
References: <200601111140.30115.vincent.roqueta@ext.bull.net> <1136976671.6819.85.camel@L10-WS-AWS1.AWS>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Cc: Al Active <LLLActive@gmx.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ewe9A-000460-TI
	for nfs@lists.sourceforge.net; Wed, 11 Jan 2006 03:28:08 -0800
Received: from ecfrec.frec.bull.fr ([129.183.4.8])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1Ewe98-0000wz-35
	for nfs@lists.sourceforge.net; Wed, 11 Jan 2006 03:28:08 -0800
To: nfs@lists.sourceforge.net
In-Reply-To: <1136976671.6819.85.camel@L10-WS-AWS1.AWS>
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

Le Mercredi 11 Janvier 2006 11:51, Al Active a =C3=A9crit=C2=A0:
> On Wed, 2006-01-11 at 11:40 +0100, Vincent Roqueta wrote:
> > Le Mercredi 11 Janvier 2006 10:15, Al Active a =C3=A9crit :
> > > Hello Vincent,
> > >
> > > On Wed, 2006-01-11 at 09:24 +0100, Al Active wrote:
> > > > On Tue, 2006-01-10 at 17:45 +0100, Vincent Roqueta wrote:
> > > > > Le Mardi 10 Janvier 2006 17:23, Al Active a =C3=A9crit :
> > > > >
> > > > >
> > > > > What are the export options, both on data cluster and  NFS-Server
> > > > > Cluster ? Can you test Data Cluster to NFS-Shares Import  read
> > > > > write access first ?
> > > > >
> > > > > Vincent
> > >
> > > OK, I checked following:
> > >
> > > On the Data-Cluster as NFS-Server exporting the Data:
> > >
> > > - Directly on the /Data directory (mounted from the /dev/drbd0 primar=
y)
> > >   All read and writes possible with OpenOffice2 (OO2)
> > >   and Linux's Text Editor (clu1 & root)
> > >   /Data/Transfer/: chown clu1:users document.doc
> > >   /Data/Transfer/: chmod 777 document.doc
> > >   /Data/Transfer/: ls -l document.doc
> > >   -rwxrwxrwx 1 clu1 users 117762006-01-11 08:48 document.doc
> > >
> > > - Exports from the Data-Cluster as NFS-Server:
> > >   /Data/NFS-Server/  *(rw,root_squash,sync)
> > >
> > > On the NFS-Client:
> > >
> > > - /Export/NFS-Server/Transfer/> ls -l document.doc
> > >   -rwxrwxrwx 1 clu1 users 117762006-01-11 08:48 document.doc
> > >
> > > - mount
> > >   192.168.0.174:/Data/NFS-Server on /Export/NFS-Server type nfs
> > > (rw,addr=3D192.168.0.174)
> > >
> > >   Editing any plain text document works (local clu1 & root)
> > >   Editing document.doc with OO2 error message:
> > >    General input/output error while
> > >    accessing /Export/NFS-Server/Transfer/document.doc
> > >
> > > This error is true for all Microsoft documents (Word, Excel & Access)
> > > that produces the error, even when I open it with OO2 on the NFS-Clie=
nt
> > > directly as well.
> >
> > That is quite strange...
> > Which kernel version are you using?
> > Is there something "special" on machine (cpu, 64bits ...)
>
> I am using Novell's SUSE 10.0 purchased Boxed Version. Kernel:
>
> uname -a
> Linux L10... 2.6.13-15-default #1 Tue Sep 13 14:56:15 UTC 2005 x86_64
> x86_64 x86_64 GNU/Linux
>
> As you can see it is a standard kernel on a x86_64 system

The kernel is a 64bits one running on x86_64 using the 32 bits emulation fo=
r=20
userland libs, right?
That looks like a fs/compat.c problem we had on the client...



> I am using the one with the above kernel. How do I find out which
> version it is? From the /var/log/messages I see:
> "Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory"; I
> take it to be v4 then.
>
> Jan 11 10:14:09 L10 kernel: NFSD: Using /var/lib/nfs/v4recovery as the
> NFSv4 state recovery directory
> Jan 11 10:14:09 L10 kernel:=20
> NFSD: recovery directory /var/lib/nfs/v4recovery doesn't exist
                                                 ^^^^^^^^^^^^^
> Jan 11 10:14:09 L10 kernel: NFSD: starting 90-second grace period

Well, if you didn't specifie nfs4 at mount time, then you are using the v3,=
=20
even if the v4 server have been started at boot time.
Don't worry for this messages.


Can you try to test using the v4 version (exports your /export directory wi=
th=20
the fsid=3D0 option and mount -t nfs4 nfs-server:/ /mount/point/ )

Vincent


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

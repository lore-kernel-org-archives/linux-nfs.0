From: Vincent Roqueta <vincent.roqueta@ext.bull.net>
Subject: Re: Searching NFS Archives
Date: Wed, 11 Jan 2006 11:40:30 +0100
Message-ID: <200601111140.30115.vincent.roqueta@ext.bull.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EwdLw-00026V-TX
	for nfs@lists.sourceforge.net; Wed, 11 Jan 2006 02:37:16 -0800
Received: from ecfrec.frec.bull.fr ([129.183.4.8])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EwdLw-0004Jj-52
	for nfs@lists.sourceforge.net; Wed, 11 Jan 2006 02:37:16 -0800
Received: from localhost (localhost [127.0.0.1])
	by ecfrec.frec.bull.fr (Postfix) with ESMTP id 5E91319D924
	for <nfs@lists.sourceforge.net>; Wed, 11 Jan 2006 11:37:11 +0100 (CET)
Received: from ecfrec.frec.bull.fr ([127.0.0.1])
 by localhost (ecfrec.frec.bull.fr [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 25734-05 for <nfs@lists.sourceforge.net>;
 Wed, 11 Jan 2006 11:37:10 +0100 (CET)
Received: from ecn002.frec.bull.fr (ecn002.frec.bull.fr [129.183.4.6])
	by ecfrec.frec.bull.fr (Postfix) with ESMTP id 2F94B19D921
	for <nfs@lists.sourceforge.net>; Wed, 11 Jan 2006 11:37:10 +0100 (CET)
To: nfs@lists.sourceforge.net
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

Le Mercredi 11 Janvier 2006 10:15, Al Active a =C3=A9crit=C2=A0:
> Hello Vincent,
>
> On Wed, 2006-01-11 at 09:24 +0100, Al Active wrote:
> > On Tue, 2006-01-10 at 17:45 +0100, Vincent Roqueta wrote:
> > > Le Mardi 10 Janvier 2006 17:23, Al Active a =C3=A9crit :
> > >
> > >
> > > What are the export options, both on data cluster and  NFS-Server
> > > Cluster ? Can you test Data Cluster to NFS-Shares Import  read write
> > > access first ?
> > >
> > > Vincent
>
> OK, I checked following:
>
> On the Data-Cluster as NFS-Server exporting the Data:
>
> - Directly on the /Data directory (mounted from the /dev/drbd0 primary)
>   All read and writes possible with OpenOffice2 (OO2)
>   and Linux's Text Editor (clu1 & root)
>   /Data/Transfer/: chown clu1:users document.doc
>   /Data/Transfer/: chmod 777 document.doc
>   /Data/Transfer/: ls -l document.doc
>   -rwxrwxrwx 1 clu1 users 117762006-01-11 08:48 document.doc
>
> - Exports from the Data-Cluster as NFS-Server:
>   /Data/NFS-Server/  *(rw,root_squash,sync)
>
> On the NFS-Client:
>
> - /Export/NFS-Server/Transfer/> ls -l document.doc
>   -rwxrwxrwx 1 clu1 users 117762006-01-11 08:48 document.doc
>
> - mount
>   192.168.0.174:/Data/NFS-Server on /Export/NFS-Server type nfs
> (rw,addr=3D192.168.0.174)
>
>   Editing any plain text document works (local clu1 & root)
>   Editing document.doc with OO2 error message:
>    General input/output error while
>    accessing /Export/NFS-Server/Transfer/document.doc
>
> This error is true for all Microsoft documents (Word, Excel & Access)
> that produces the error, even when I open it with OO2 on the NFS-Client
> directly as well.

That is quite strange...
Which kernel version are you using?
Is there something "special" on machine (cpu, 64bits ...)

> Only if this problem gets solved, I can look further at the Samba share
> error in the windows network (which will probably also be caused by this
> error)

True

> Can it be something of an incompatibility between the users of the
> NFS-Server and NFS-Client, even if clu1 has the same UID: 1001 and
> member of the same groups on both of the two systems? Why only with the
> Microsoft Office Data Files?

That should not be the case... and even if there was a problem at this poin=
t,
the error must be "permission denied", not "I/O error", which reflect an
internal NFS problem.

I suppose you are running nfsv3, can you try with the v4 one? (last versions
are much more reliables than v3 ones... )

Also, you should have interresting messages in the /var/log/message on NFS
client and/or server

Cordialement,
Vincent

=2D------------------------------------------------------


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: =?iso-8859-1?Q?Brasseur_Val=E9ry?= <Valery.Brasseur@atosorigin.com>
Subject: RE: Linux client network performance
Date: Wed, 25 Jun 2003 16:58:08 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <8147E1B07201DD41B6B9F0D31E07B38444915D@srv-grp-s07.dev.atos.fr>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from hermes3.atos-group.com ([160.92.18.10])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19VBj6-0002iW-00
	for <nfs@lists.sourceforge.net>; Wed, 25 Jun 2003 07:58:24 -0700
To: "'Lever, Charles'" <Charles.Lever@netapp.com>
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

hi,

what's the "IP fragmentation bug" ?
what are the symptoms of this bug ?

thanks
valery
> -----Original Message-----
> From: Lever, Charles [mailto:Charles.Lever@netapp.com]
> Sent: Wednesday, June 25, 2003 4:30 PM
> To: Matthias Kittner
> Cc: nfs@lists.sourceforge.net
> Subject: RE: [NFS] Linux client network performance
> 
> 
> hi matthias-
> 
> it sounds like you've hit the IP fragmentation bug.
> you should use NFS/TCP (the "tcp" mount option).
> 
> probably it's your 2.4.19-based client that is
> causing this problem.
> 
> > -----Original Message-----
> > From: Matthias Kittner [mailto:kittner@vrcom.de]
> > Sent: Wednesday, June 25, 2003 4:57 AM
> > To: nfs@lists.sourceforge.net
> > Subject: [NFS] Linux client network performance
> > 
> > 
> > [I am not a subscriber, please CC to my eMail!]
> > 
> > Hello,
> > 
> > we have the following problem:
> > 
> > - 2 linux clients:
> > 	2.4.19-16mdk
> > 	2.4.20
> > - Solaris NFS-Server (nfs.server 1.21)
> > 	SunOS 5.7
> > 
> > If we compile on one of the linux machines sometimes in 
> this compile 
> > process the whole network hangs resp. is so slow that one can wait 
> > between 10s or 2min to finish a "ls".
> > 
> > "snoop" at the nfs-server machine show very/very much "UDP 
> > continuation" 
> > traffic between the linux client and the solaris server. 
> Killing the 
> > compile process stops this messages.
> > 
> > Can anyone help us? Is this a configuration problem or a bug?
> > 
> > Regards,
> > Matthias
> > 
> > 
> > 
> > -------------------------------------------------------
> > This SF.Net email is sponsored by: INetU
> > Attention Web Developers & Consultants: Become An INetU 
> > Hosting Partner.
> > Refer Dedicated Servers. We Manage Them. You Get 10% Monthly 
> > Commission!
> > INetU Dedicated Managed Hosting 
http://www.inetu.net/partner/index.php
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> 


-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

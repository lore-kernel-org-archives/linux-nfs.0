From: "Roger Heflin" <rheflin@atipa.com>
Subject: RE: async vs. sync
Date: Mon, 22 Nov 2004 13:05:07 -0600
Message-ID: <EXCHG2003DSpCW4uFWj00007243@EXCHG2003.microtech-ks.com>
References: <41A236A6.4050104@int-evry.fr>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: "'Olaf Kirch'" <okir@suse.de>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CWJUw-00047v-Qn
	for nfs@lists.sourceforge.net; Mon, 22 Nov 2004 11:05:14 -0800
Received: from host27-44.discord.birch.net ([65.16.27.44] helo=EXCHG2003.microtech-ks.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CWJUw-0001Wc-48
	for nfs@lists.sourceforge.net; Mon, 22 Nov 2004 11:05:14 -0800
To: "'jehan.procaccia'" <jehan.procaccia@int-evry.fr>,
	"'Trond Myklebust'" <trond.myklebust@fys.uio.no>
In-Reply-To: <41A236A6.4050104@int-evry.fr>
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


Solaris has always been sync on the export, async on the mount, that
is unless you had a prestoserve type module (which made some kernel
adjustments) which used to be available on the servers, and would backup
the memory that nfs was using as cache with a battery.  Without
said hardware there was no way to make Solaris async.

                               Roger=20

> -----Original Message-----
> From: nfs-admin@lists.sourceforge.net=20
> [mailto:nfs-admin@lists.sourceforge.net] On Behalf Of jehan.procaccia
> Sent: Monday, November 22, 2004 12:58 PM
> To: Trond Myklebust
> Cc: Olaf Kirch; nfs@lists.sourceforge.net; mci-unix@int-evry.fr
> Subject: Re: [NFS] async vs. sync
>=20
> Trond Myklebust wrote:
>=20
> >m=E5 den 22.11.2004 Klokka 18:55 (+0100) skreiv jehan.procaccia:
> >
> > =20
> >
> >>My users won't accept the sync performances !
> >>   =20
> >>
> >
> >Will they accept data loss in case of a server crash? If they don't=20
> >care, then hey - you're safe...
> > =20
> >
> in my old solaris 7 nfs it was async I suppose ! although we=20
> didn't lose data, maybe we where risking it ... ? anyway now=20
> I move from and old solaris NFS server to a brand new linux=20
> one with a SAN (AX100) Storage Processor in Raid 5 an Fiber=20
> Channel attachement, how can I support performances more than=20
> 50 times longer :-( with that config,  user and manager wil=20
> tell me that I  spoild money on that new server !, there must=20
> be a misconfiguration somewhere ?.
>=20
> >BTW: I've never seen a slowdown as bad as that. Just out of=20
> curiosity,=20
> >what happens if you turn off ACL support and/or use a client from=20
> >ftp.kernel.org, with no ACL support.
> > =20
> >
> I did it on the server export option (no_acl) , no better=20
> performance.=20
> However I don't know why I have ACLs,  I nerver ask for it !?
> /etc/fstab on the server
> /dev/emcpowerp1         /p2v5f1         ext3   =20
> defaults,usrquota,grpquota     1 2
>=20
> >(NOTE: the reason I've rejected ACLs so far in the mainline=20
> client is=20
> >the lack of support for caching in the patches I've seen so far)
> >
> >Cheers,
> >  Trond
> > =20
> >
>=20
>=20
>=20
> -------------------------------------------------------
> SF email is sponsored by - The IT Product Guide Read honest &=20
> candid reviews on hundreds of IT Products from real users.
> Discover which products truly live up to the hype. Start reading now.=20
> http://productguide.itmanagersjournal.com/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net=20
> https://lists.sourceforge.net/lists/listinfo/nfs
>=20



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

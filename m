From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Detectiong Network and umount / mount NFS
Date: Thu, 21 Apr 2005 09:05:07 -0400
Message-ID: <1114088708.10727.9.camel@lade.trondhjem.org>
References: <1114027379.4266b57354785@webmail.tusofona.com>
	 <4266C21D.9030305@RedHat.com>
	 <1114038052.4266df245e54e@webmail.tusofona.com>
	 <1114042784.17214.11.camel@lade.trondhjem.org>
	 <Pine.LNX.4.61.0504211009380.3889@maggie.lkpg.cendio.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: esqueleto@tusofona.com, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DObN9-0004zl-8S
	for nfs@lists.sourceforge.net; Thu, 21 Apr 2005 06:05:35 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DObN7-0004ve-HN
	for nfs@lists.sourceforge.net; Thu, 21 Apr 2005 06:05:35 -0700
To: Peter =?ISO-8859-1?Q?=C5strand?= <astrand@cendio.se>
In-Reply-To: <Pine.LNX.4.61.0504211009380.3889@maggie.lkpg.cendio.se>
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

to den 21.04.2005 Klokka 10:14 (+0200) skreiv Peter =C3=85strand:
> > If you want that sort of behaviour, then read all about the "soft" moun=
t
> > option ("man 5 nfs", and http://nfs.sourceforge.net/#faq_d6).
>=20
> I think Esqueleto wants a Solaris-type "umount -f". I'd like to have that=
=20
> too.

You didn't actually read that FAQ entry, that I pointed to, did you?
Please do.

This is not something that will happen soon, unless you or someone else
who feels strongly about it pulls up their sleeves, and starts
developing. Adding bugzilla entries for this type of feature will just
serve to annoy.

--=20
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
This SF.Net email is sponsored by: New Crystal Reports XI.
Version 11 adds new functionality designed to reduce time involved in
creating, integrating, and deploying reporting solutions. Free runtime info,
new features, or free trial, at: http://www.businessobjects.com/devxi/728
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

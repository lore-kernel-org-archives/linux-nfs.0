From: esqueleto@tusofona.com
Subject: Re: Detectiong Network and umount / mount NFS
Date: Thu, 21 Apr 2005 14:28:32 +0100
Message-ID: <1114090112.4267aa8096c00@webmail.tusofona.com>
References: <1114027379.4266b57354785@webmail.tusofona.com>  <4266C21D.9030305@RedHat.com>  <1114038052.4266df245e54e@webmail.tusofona.com>  <1114042784.17214.11.camel@lade.trondhjem.org>  <Pine.LNX.4.61.0504211009380.3889@maggie.lkpg.cendio.se> <1114088708.10727.9.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Peter =?iso-8859-1?b?xXN0cmFuZA==?= <astrand@cendio.se>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DObjS-00069q-Q8
	for nfs@lists.sourceforge.net; Thu, 21 Apr 2005 06:28:38 -0700
Received: from [81.92.210.10] (helo=agata.100limite.pt)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DObjP-0004Gk-UT
	for nfs@lists.sourceforge.net; Thu, 21 Apr 2005 06:28:38 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1114088708.10727.9.camel@lade.trondhjem.org>
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

I don't think that you undestand the problem. I have NFS mount points in =
my
FileSystem and I want to change from Wired and Wireless and don't loose t=
he
mount points.

now, when I change for 1 or 2 seconds there will be no network and the NF=
S does
not resume the connection after the netwoek is up (or is not immediately)=
.
What I want if for the NFS it self umount when the network connection doe=
s not
exists.
If this happen i can mount again when the network is up again.

This problem does not exists in Desktop computers only laptops with wirel=
ess and
wired connection.


(())
Esqueleto
Odivelas - Portugal


Quoting Trond Myklebust <trond.myklebust@fys.uio.no>:

> to den 21.04.2005 Klokka 10:14 (+0200) skreiv Peter =C3=85strand:
> > > If you want that sort of behaviour, then read all about the "soft" =
mount
> > > option ("man 5 nfs", and http://nfs.sourceforge.net/#faq_d6).
> >
> > I think Esqueleto wants a Solaris-type "umount -f". I'd like to have =
that
> > too.
>
> You didn't actually read that FAQ entry, that I pointed to, did you?
> Please do.
>
> This is not something that will happen soon, unless you or someone else
> who feels strongly about it pulls up their sleeves, and starts
> developing. Adding bugzilla entries for this type of feature will just
> serve to annoy.
>
> --
> Trond Myklebust <trond.myklebust@fys.uio.no>
>
>




----------------------------------------------------------------
This message was sent using IMP, the Internet Messaging Program.



-------------------------------------------------------
This SF.Net email is sponsored by: New Crystal Reports XI.
Version 11 adds new functionality designed to reduce time involved in
creating, integrating, and deploying reporting solutions. Free runtime in=
fo,
new features, or free trial, at: http://www.businessobjects.com/devxi/728
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

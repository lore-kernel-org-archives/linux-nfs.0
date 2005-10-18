From: Vincent Roqueta <vincent.roqueta@ext.bull.net>
Subject: Re: Authenticated NFS mounts
Date: Tue, 18 Oct 2005 13:13:09 +0200
Message-ID: <200510181313.09401.vincent.roqueta@ext.bull.net>
References: <dj2kkn$4hr$1@benzin.geggus.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ERpP1-000496-KY
	for nfs@lists.sourceforge.net; Tue, 18 Oct 2005 04:13:07 -0700
Received: from ecfrec.frec.bull.fr ([129.183.4.8])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1ERpP0-0003Qu-LU
	for nfs@lists.sourceforge.net; Tue, 18 Oct 2005 04:13:07 -0700
Received: from localhost (localhost [127.0.0.1])
	by ecfrec.frec.bull.fr (Postfix) with ESMTP id 3586519D917
	for <nfs@lists.sourceforge.net>; Tue, 18 Oct 2005 13:12:16 +0200 (CEST)
Received: from ecfrec.frec.bull.fr ([127.0.0.1])
 by localhost (ecfrec.frec.bull.fr [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 00654-01 for <nfs@lists.sourceforge.net>;
 Tue, 18 Oct 2005 13:12:14 +0200 (CEST)
Received: from ecn002.frec.bull.fr (ecn002.frec.bull.fr [129.183.4.6])
	by ecfrec.frec.bull.fr (Postfix) with ESMTP id 4823219D90A
	for <nfs@lists.sourceforge.net>; Tue, 18 Oct 2005 13:12:14 +0200 (CEST)
To: nfs@lists.sourceforge.net
In-Reply-To: <dj2kkn$4hr$1@benzin.geggus.net>
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

Le mardi 18 Octobre 2005 13:00, Sven Geggus a =E9crit=A0:
> Hello NFS-list,
>
> Section A5 of the Linux NFS FAQ (Can I use Kerberos authentication with N=
=46S
> on Linux?) is somewhat confusing as it the Answer is not clearly yes or n=
o.
>
> So whats the current Answer to this simple Question:
>
> Is ist possible to use RPCSEC GSSAPI in conjunction with NFSv3 on Linux
> Clients and Servers?
Yes, that is possible.

However,
__________________________________________________________________
> > >Beaware NFSv3 is not really secure, even with kerberos.
> >
> >Have you some documentation on this issue?
>
> I don't know what the right citation is.
>
> Problems I know of; maybe there are others:
>
>        1. nfsv2/v3 mount doesn't traditionally seem to know how to use
>           rpcsec_gss, so in theory someone could spoof the reply to your
>           mount call, returning a filehandle other than the one you asked
>           for.
>        2. The locking protocol used with v2/v3 doesn't use rpcsec_gss.
>
> But depending on your environment these problems may not worry you.
>
> --b.
___________________________________________________________________


> I managed to use it in conjunction with NFSv4, but NFSv4 does not seem to
> be stable enough for production use.=20
Hmmm... Which kernel are you using ?
The nfsv4 mailing list is here :  nfsv4@linux-nfs.org

> I had machine lockups even on a  test-installation I have been using :(
What kind of lockups ?


Vincent


-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

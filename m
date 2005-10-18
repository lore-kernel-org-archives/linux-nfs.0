From: Vincent Roqueta <vincent.roqueta@ext.bull.net>
Subject: Re: Authenticated NFS mounts
Date: Tue, 18 Oct 2005 13:44:37 +0200
Message-ID: <200510181344.37509.vincent.roqueta@ext.bull.net>
References: <dj2kkn$4hr$1@benzin.geggus.net> <200510181313.09401.vincent.roqueta@ext.bull.net> <dj2ma2$52v$1@benzin.geggus.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ERpqv-0005Xm-Vu
	for nfs@lists.sourceforge.net; Tue, 18 Oct 2005 04:41:57 -0700
Received: from ecfrec.frec.bull.fr ([129.183.4.8])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1ERpqs-0007DO-LD
	for nfs@lists.sourceforge.net; Tue, 18 Oct 2005 04:41:58 -0700
Received: from localhost (localhost [127.0.0.1])
	by ecfrec.frec.bull.fr (Postfix) with ESMTP id B9B1219D90D
	for <nfs@lists.sourceforge.net>; Tue, 18 Oct 2005 13:41:11 +0200 (CEST)
Received: from ecfrec.frec.bull.fr ([127.0.0.1])
 by localhost (ecfrec.frec.bull.fr [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 02583-01 for <nfs@lists.sourceforge.net>;
 Tue, 18 Oct 2005 13:41:10 +0200 (CEST)
Received: from ecn002.frec.bull.fr (ecn002.frec.bull.fr [129.183.4.6])
	by ecfrec.frec.bull.fr (Postfix) with ESMTP id 00A3F19D90A
	for <nfs@lists.sourceforge.net>; Tue, 18 Oct 2005 13:41:10 +0200 (CEST)
To: nfs@lists.sourceforge.net
In-Reply-To: <dj2ma2$52v$1@benzin.geggus.net>
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

Le mardi 18 Octobre 2005 13:29, Sven Geggus a =E9crit=A0:
> Vincent Roqueta <vincent.roqueta@ext.bull.net> wrote:
> >> Is ist possible to use RPCSEC GSSAPI in conjunction with NFSv3 on Linux
> >> Clients and Servers?
> >
> > Yes, that is possible.
>
> Any kind of mini HOWTO on this? Which Versions of mount, nfs-utils etc
> would I need?
That is the same howto as for NFSv4. You need a recent kernel.
http://wiki.linux-nfs.org/index.php/Main_Page

> Protection against mounts from untrusted machines which are not
> authenticated is all I need to provide at the Moment.
Ok.

> NFSv4 seems to be a better design, but stability is more important for my
> application.
NFSv4 works quite fine for most NFSv3 uses. It pass some stress tests NFSv3=
=20
does not. We are looking for early adpoters of NFSv4.=20

You should have a look here for tests :=20
http://nfsv4.bullopensource.org/


Vincent


-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

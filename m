From: Vincent Roqueta <vincent.roqueta@ext.bull.net>
Subject: Re: File lock with multiple clients
Date: Fri, 21 Oct 2005 13:04:48 +0200
Message-ID: <200510211304.48219.vincent.roqueta@ext.bull.net>
References: <E1ESu5K-0007a8-1Z@mail.sourceforge.net> <200510211240.16468.vincent.roqueta@ext.bull.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: petter.knutsen@cgi.no
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ESueV-0008WP-G7
	for nfs@lists.sourceforge.net; Fri, 21 Oct 2005 04:01:35 -0700
Received: from ecfrec.frec.bull.fr ([129.183.4.8])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1ESueU-0002tH-6A
	for nfs@lists.sourceforge.net; Fri, 21 Oct 2005 04:01:35 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <200510211240.16468.vincent.roqueta@ext.bull.net>
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

Le vendredi 21 Octobre 2005 12:40, Vincent Roqueta a =E9crit=A0:
> Le vendredi 21 Octobre 2005 12:25, petter.knutsen@cgi.no a =E9crit=A0:
> > > Check the man page:  "man flock":
> > >
> > > Use fcntl or lockf (which is wrapper for fcntl) if you want to lock
> > > over NFS.
> >
> > As Trond said, flock() seems to work by emulating fcntl(), but regardle=
ss
> > of whether I'm using fcntl() directly or flock() with emulation, should
> > my scenario  with two clients work, where one client locks and the other
> > client honouring the lock?
> >
> > As I said, it works between processes on the same client, but not betwe=
en
> > processes on different clients.
>
> I am going to test that on different clients.
I have tested it. That works.
kernel : linux 2.6.14-rc4-CITI_NFS4_ALL-1. It may works on older kernel too.

Vincent


-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

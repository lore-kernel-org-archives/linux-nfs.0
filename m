From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: > 16 groups patch from Frank van Maarseveen
Date: Fri, 30 Jul 2004 13:40:00 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1091212800.3804.17.camel@lade.trondhjem.org>
References: <1091207680.4797.47.camel@dyn319648.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sf.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BqvN7-0003zr-9h
	for nfs@lists.sourceforge.net; Sat, 31 Jul 2004 08:02:05 -0700
Received: from [65.220.109.67] (helo=lade.trondhjem.org)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.34)
	id 1BqvN5-0006Sa-LF
	for nfs@lists.sourceforge.net; Sat, 31 Jul 2004 08:02:05 -0700
To: Bruce Allan <bwa@us.ibm.com>
In-Reply-To: <1091207680.4797.47.camel@dyn319648.beaverton.ibm.com>
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

P=E5 fr , 30/07/2004 klokka 12:14, skreiv Bruce Allan:
> Hi Trond,
>=20
> I was wondering why Frank's patch to bypass the 16 group limitation in
> RPC (http://frankvm.xs4all.nl/nfs-ngroups/) has not been incorporated
> into mainline yet.  Is it because he has not addressed your
> concern/recommendation as mentioned in
> http://marc.theaimsgroup.com/?l=3Dlinux-nfs&m=3D87941837304355&w=3D2
>=20
> If the patch were modified to follow your recommendation in the same
> post, would that be acceptable?

I'm certainly not prepared to merge any new features into the 2.4
kernel, so the patches as they stand are not going in no matter what.

However, I'm in general seriously sceptical about implementing this sort
of thing: when we only had SYS_UNIX as an option, then it might have
been an unsurmountable problem (though even there it was possible to
work around by judicious choices). However now that we have RPCSEC_GSS
with support for strong authentication (such as w/ krb5), it is possible
for the server to know exactly which groups the user is a member of.

Why go for a heuristic algorithm, when there are deterministic ones that
can do better?

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email is sponsored by OSTG. Have you noticed the changes on
Linux.com, ITManagersJournal and NewsForge in the past few weeks? Now,
one more big change to announce. We are now OSTG- Open Source Technology
Group. Come see the changes on the new OSTG site. www.ostg.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

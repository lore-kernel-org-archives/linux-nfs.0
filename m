From: "Heflin, Roger A." <Roger.A.Heflin@conoco.com>
Subject: RE: 2.4.19 NFSALL performance oddity
Date: Tue, 8 Oct 2002 15:53:44 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <5CA6F03EF05E0046AC5594562398B91653BD1F@poexmb3.conoco.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from panoramix.vasoftware.com ([198.186.202.147])
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 17z1Md-0001VM-00
	for <nfs@lists.sourceforge.net>; Tue, 08 Oct 2002 13:53:59 -0700
Received: from usamail2.conoco.com ([12.31.208.227]:2914)
	by panoramix.vasoftware.com with esmtp (Exim 4.05-VA-mm1 #1 (Debian))
	id 17z1Mb-0006ut-00
	for <nfs@lists.sourceforge.net>; Tue, 08 Oct 2002 13:53:57 -0700
To: <trond.myklebust@fys.uio.no>
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

Ok,

I applied the new patch, it does not appear to have made any difference=20
in my setup and tests, it also does not appear to break anything.
I am still analyzing the results, but not finding=20
anything obvious about what is going on.  2.2.19 appears to make alot
better client to a 2.4.19 server than 2.4.1[89][no patch/nfsall]
does.   And 2.4.19 with no patches appears to make a better
server than 2.4.19 (for the writes) with the NFS patches
(using 2.2.19 as a client).

Using 2.4.xx as a client, a 2.4.1[89][nfsall/nopatch] server is=20
about the same on writes, but 2.4.19 nfsall is much better
on the reads than the previous 2.4.1[89] without
the nfsall patch.

I guess the read numbers with NFSall look pretty good,=20
the write numbers probably need to be better, though the write=20
numbers do look ok  (2.5x larger) with 2.2.19 as
a client, they don't look good with 2.4.19 nfsall as a client.  =20
And from 2.4.19 to 2.4.19 nfsall the write numbers got a bit worse=20
for a 2.2.19 client, but did not appear to change a large amount
when using a 2.4.19  client.

I have a excel spreadsheet of the various results, that try to
summarize up all of the recent emails.  If anyone wants this=20
spreadsheet I will sent it out.


2.4.19 NFSALLnew Server:
	2.4.19 NFSALLnew Client
		write: 2.312MB
		read: 8.875MB
	2.4.18 Client:
		write: 2.125
		read: 8.125

2.4.19 NFSALLold Server:
	2.4.19 NFSALLnew Client:
		write: 2.312 MB
		read:  8.688 MB

2.4.18 no patches Server:
	2.4.19 NFSALL Client:
		write: 2.00 MB
		read:  2.50 MB
	2.4.19 nopatches client:
		write: 2.0MB
		read: 3.0MB
	2.2.19 stock client:
		write: 6.00 MB
		read: 10.0 MB



=20
			Roger
> -----Original Message-----
> From:	Trond Myklebust [SMTP:trond.myklebust@fys.uio.no]
> Sent:	Monday, October 07, 2002 5:21 PM
> To:	Heflin, Roger A.
> Cc:	nfs@lists.sourceforge.net
> Subject:	RE: 2.4.19 NFSALL performance oddity
>=20
>=20
> FYI: I updated 2.4.19-NFS_ALL on Saturday with a couple of
> bugfixes. Among them was one which fixes a queueing bottleneck when a
> timeout+resend occurs.
>=20
> Cheers,
>   Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: =?UTF-8?Q?Peter_=C3=85strand?= <astrand@cendio.se>
Subject: Re: [PATCH] 64 bit ino support for NFS client
Date: Mon, 13 Aug 2007 18:04:45 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0708131721140.17553@maggie.lkpg.cendio.se>
References: <46B37CDE.1070904@redhat.com>
	<Pine.LNX.4.64.0708131511470.15451@maggie.lkpg.cendio.se>
	<46C05C40.30707@redhat.com>
	<Pine.LNX.4.64.0708131555330.15782@maggie.lkpg.cendio.se>
	<46C06ED8.8030107@redhat.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="789237761-676712321-1187020156=:17553"
Cc: Andrew Morton <akpm@linux-foundation.org>,
	NFS List <nfs@lists.sourceforge.net>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: Peter Staubach <staubach@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IKcPS-0005UT-3O
	for nfs@lists.sourceforge.net; Mon, 13 Aug 2007 09:04:50 -0700
Received: from mail.cendio.se ([193.12.253.69])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IKcPU-00084W-LC
	for nfs@lists.sourceforge.net; Mon, 13 Aug 2007 09:04:54 -0700
In-Reply-To: <46C06ED8.8030107@redhat.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--789237761-676712321-1187020156=:17553
Content-Type: TEXT/PLAIN; CHARSET=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Content-ID: <Pine.LNX.4.64.0708131749241.17553@maggie.lkpg.cendio.se>

On Mon, 13 Aug 2007, Peter Staubach wrote:

> > Sure, but to prevent customer unhappiness, it's much better to update t=
he
> > applications in a certain distribution *before* changing the world arou=
nd
> > them. I'm arguing that a typical customer would rather being able to ru=
n
> > OpenOffice than live in tomorrows world.
> >
> >  =20
>=20
> Without issues to drive and even to identify the broken applications,
> they will never get fixed.

I agree, it was good that the kernel patch was tried and the problems=20
identified. However, now that we know that the patch causes problems and=20
no fix for either KDE or OpenOffice are in sight, the patch should be=20
pulled out, IMHO.=20

Compatibility with legacy third party application is another reason, that=
=20
we haven't even touched yet.=20


> > Another reason why I'm not convinced of this patch is that I haven't he=
ard
> > any arguments why this is the time to break compatibility with 32 bit
> > non-LFS apps. Why not tomorrow, yesterday or 10 years ago? Why now?=20
> >

> We have to start someplace, sometime.  In fact, we've already started. =
=20
> It is unfortunate that this particular aspect is only now starting to=20
> become visible to application developers.  It has been interesting to=20
> file systems developers for quite some time.

Application developers (or perhaps, binary builders) will probably migrate=
=20
to LFS or 64 bit anyway, to gain support for large files etc.=20

The patch that breaks compat with 32 bit non-LFS can be tried internally,=
=20
or during testing, to identify apps with problems. Then we can file bug=20
reports to the individual projects. But breaking apps now and then just=20
hope that someone will fix them someday in the future is the wrong=20
approach, IMHO.


> Supporting 64 bit inos in NFS does not mean that NFS will
> automatically start generating 64 bit inos.  NFS is still dependent
> upon the file system on the server.  The NFS will just pass through
> whatever that the file system on the server presents to it.

Not necessarily true, or do you only care about Linux clients and Linux=20
servers? In that case, we can just as well rename our NFS support to=20
something like "Linux Ext3 Network File System"...=20

There's nothing in the NFSv3 specification that requires you to directly=20
map inode numbers to fileid. NFS is supposed to be cross platform. If the=
=20
NFS client requires that fileids are constructed in a certain way, we can=
=20
just as well rely on certain Linux-specific bit fields in the file=20
handles.=20

But we don't want to do that, we want a client that works with as many NFS=
=20
servers as possible, as long as they are adhering to RFC1813. We can do=20
this and at the same time support 32 bit non-LFS applications, this has=20
worked fine for many years now. Sure, in very rare cases you will have a=20
problem, but your cure is worse than the disease.=20

Or, as Dave Noveck puts it at=20
http://www1.ietf.org/mail-archive/web/nfsv4/current/msg01590.html:

"As a user my feeling is that it is better to compromise on fileid=20
uniqueness when dealing with 32-bit applications, and give the user=20
something that has some possibility of conflict as opposed to an error=20
which stops him cold.  Most applications that do stat don't care about=20
fileid uniqueness."

Regards,=20
---
Peter =C3=85strand=09=09ThinLinc Chief Developer
Cendio AB=09=09http://www.cendio.se
Wallenbergs gata 4
583 30 Link=C3=B6ping=09Phone: +46-13-21 46 00
--789237761-676712321-1187020156=:17553
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--789237761-676712321-1187020156=:17553
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--789237761-676712321-1187020156=:17553--

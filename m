From: =?UTF-8?Q?Peter_=C3=85strand?= <astrand@cendio.se>
Subject: Re: Portmap - was Re: Does mountd/statd really need to listen
 on a privileged port??
Date: Thu, 26 Apr 2007 16:30:26 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0704261625120.1454@maggie.lkpg.cendio.se>
References: <17958.48121.280256.493824@notabene.brown>
	<20070425095826.GA25349@infradead.org>
	<462F55FE.5020502@RedHat.com>
	<200704251610.39864.olaf.kirch@oracle.com>
	<20070425144214.GB6217@infradead.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="789237761-845455898-1177597826=:1454"
Cc: nfs@lists.sourceforge.net
To: Christoph Hellwig <hch@infradead.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hh4zS-0002lu-AH
	for nfs@lists.sourceforge.net; Thu, 26 Apr 2007 07:30:34 -0700
Received: from mail.cendio.se ([193.12.253.69])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hh4zT-0006az-Ld
	for nfs@lists.sourceforge.net; Thu, 26 Apr 2007 07:30:37 -0700
In-Reply-To: <20070425144214.GB6217@infradead.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--789237761-845455898-1177597826=:1454
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Wed, 25 Apr 2007, Christoph Hellwig wrote:

> On Wed, Apr 25, 2007 at 04:10:37PM +0200, Olaf Kirch wrote:
> > Whatever we do, there needs to be some coordination with
> > the glibc folks. If they don't accept any patches to the sunrpc
> > code in their code base, then we need to talk about a way
> > of transitioning that code out of there.
>=20
> Yes.

I'm positive, creating a separate library based on the current glibc RPC=20
code seems like a nice solution to me.=20


> Another alternative would be to not mess with the symbols in glibc
> at all but use linker magic to emit a warning that people should use
> librpc instead, similar to how linking any application using getc
> against glibc will get you a warning that it's dangerous and should
> not be used.

You mean gets()? I like this approach.=20

Regards,=20
---
Peter =C3=85strand=09=09ThinLinc Chief Developer
Cendio AB=09=09http://www.cendio.se
Wallenbergs gata 4
583 30 Link=C3=B6ping=09Phone: +46-13-21 46 00
--789237761-845455898-1177597826=:1454
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--789237761-845455898-1177597826=:1454
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--789237761-845455898-1177597826=:1454--

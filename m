From: Timo Sirainen <tss@iki.fi>
Subject: Re: [NFS] Cache flushing
Date: Wed, 21 Nov 2007 22:56:24 +0200
Message-ID: <1195678584.6039.436.camel@hurina>
References: <1195258291.6039.189.camel@hurina>
	<1195328785.6999.5.camel@localhost.localdomain>
	<600549E3-82CF-44EB-8394-E57A3BB41118@iki.fi>
	<1195332062.6999.20.camel@localhost.localdomain>
	<1195337516.6039.239.camel@hurina> <1195524890.6039.315.camel@hurina>
	<1195602454.7234.100.camel@heimdal.trondhjem.org>
	<1195650851.6039.425.camel@hurina>
	<1195653389.8374.4.camel@heimdal.trondhjem.org>
	<D30D2934-0124-4AD4-B184-DCC3EF62440E@iki.fi>
	<1195677569.8374.18.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0330655882=="
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Iuwcc-0001Wh-A2
	for nfs@lists.sourceforge.net; Wed, 21 Nov 2007 12:56:34 -0800
Received: from dovecot.org ([82.118.211.50])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Iuwcf-0005Tp-LB
	for nfs@lists.sourceforge.net; Wed, 21 Nov 2007 12:56:40 -0800
In-Reply-To: <1195677569.8374.18.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>


--===============0330655882==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature";
	boundary="=-Vo7VInh71aL1v7G816pI"


--=-Vo7VInh71aL1v7G816pI
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2007-11-21 at 15:39 -0500, Trond Myklebust wrote:
> On Wed, 2007-11-21 at 22:36 +0200, Timo Sirainen wrote:
> > On 21.11.2007, at 15.56, Trond Myklebust wrote:
> >=20
> > > On Wed, 2007-11-21 at 15:14 +0200, Timo Sirainen wrote:
> > >
> > >> Now that I think of it, I guess the reason is that my 2.6.22 setup =20
> > >> has
> > >> Linux+ext3 as NFS server and 2.6.17-rc2 setup has NetApp as =20
> > >> server. So
> > >> even though open()+close() flushes the directory's attribute =20
> > >> cache, it
> > >> doesn't flush the file name -> NFS handle cache unless mtime changes=
?
> > >
> > > Right. You're hitting the principal limitation of ext3 as an NFS =20
> > > backend
> > > filesystem.
> > > As I said in an earlier mail, the resolution on the time is 1 =20
> > > second, so
> > > client 2 can basically not see any changes that happen within < 1 =20
> > > second
> > > on client 1. The reason is that the mtime stays the same.
> >=20
> > With files it's possible to work around this limitation with fcntl =20
> > locking, but directories can't be locked. So back to my original =20
> > question: Would it be possible to have chmod(dir, (uid_t)-1, =20
> > (gid_t)-1) flush its cache? I don't see what harm there could be in =20
> > this, since normally no-one would do it anyway and the change is simple=
-
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html


--=-Vo7VInh71aL1v7G816pI--

--===============0330655882==--

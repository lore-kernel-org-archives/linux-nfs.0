From: =?UTF-8?Q?Peter_=C3=85strand?= <astrand@cendio.se>
Subject: Re: [PATCH] 64 bit ino support for NFS client
Date: Mon, 13 Aug 2007 16:12:08 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0708131555330.15782@maggie.lkpg.cendio.se>
References: <46B37CDE.1070904@redhat.com>
	<Pine.LNX.4.64.0708131511470.15451@maggie.lkpg.cendio.se>
	<46C05C40.30707@redhat.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="789237761-931209115-1187014328=:15782"
Cc: Andrew Morton <akpm@linux-foundation.org>,
	NFS List <nfs@lists.sourceforge.net>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: Peter Staubach <staubach@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IKaeV-0007Zx-4w
	for nfs@lists.sourceforge.net; Mon, 13 Aug 2007 07:12:15 -0700
Received: from mail.cendio.se ([193.12.253.69])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IKaeX-0003Hd-S8
	for nfs@lists.sourceforge.net; Mon, 13 Aug 2007 07:12:19 -0700
In-Reply-To: <46C05C40.30707@redhat.com>
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

--789237761-931209115-1187014328=:15782
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Mon, 13 Aug 2007, Peter Staubach wrote:

> > This patch seems to overlap with linux-2.6-nfs-64-bit-inode-support.pat=
ch,
> > which is included in RHEL5 kernels. Are these patches related, somehow?=
 The
> > RHEL5 patch causes problems, as described at
> > https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=3D241348.=20
>=20
> They are related in that they modify similar areas in the NFS code.
> However, this patch only modifies the NFS code and not the rest of
> the file systems and areas in the kernel.
>=20
> My opinion on the referenced bugzilla is that things change and
> it may be time to update applications and such to work in the
> new world.  Applications which do not get modified, tend to work
> less and less as time goes by because while the world changes
> around them, they don't.

Sure, but to prevent customer unhappiness, it's much better to update the=
=20
applications in a certain distribution *before* changing the world around=
=20
them. I'm arguing that a typical customer would rather being able to run=20
OpenOffice than live in tomorrows world.

Another reason why I'm not convinced of this patch is that I haven't heard=
=20
any arguments why this is the time to break compatibility with=20
32 bit non-LFS apps. Why not tomorrow, yesterday or 10 years ago? Why now?=
=20


> I don't believe that this is the only cause which will keep those
> applications from working completely.  With the addition of the
> LFS thing, they will start to encounter more and more things that
> they are not prepared to deal with.

Can you give an example?=20

If we maintain "good-enough compatibility" with 32 bit non-LFS=20
applications now (proposed solution 1 or 2 in comment #6), we would still=
=20
have full 64 bit support for LFS and 64 bit applications, and as LFS and=20
64 bit applications are becoming more and more common, the problem would=20
fade away.


Regards,=20
---
Peter =C3=85strand=09=09ThinLinc Chief Developer
Cendio AB=09=09http://www.cendio.se
Wallenbergs gata 4
583 30 Link=C3=B6ping=09Phone: +46-13-21 46 00
--789237761-931209115-1187014328=:15782
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--789237761-931209115-1187014328=:15782
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--789237761-931209115-1187014328=:15782--

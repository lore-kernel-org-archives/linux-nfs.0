From: =?UTF-8?Q?Peter_=C3=85strand?= <astrand@cendio.se>
Subject: Re: [PATCH] 64 bit ino support for NFS client
Date: Mon, 13 Aug 2007 18:46:15 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0708131838580.19529@maggie.lkpg.cendio.se>
References: <46B37CDE.1070904@redhat.com>
	<Pine.LNX.4.64.0708131511470.15451@maggie.lkpg.cendio.se>
	<46C05C40.30707@redhat.com>
	<Pine.LNX.4.64.0708131555330.15782@maggie.lkpg.cendio.se>
	<1187021560.6628.7.camel@heimdal.trondhjem.org>
	<1187022103.6628.12.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED;
	BOUNDARY="789237761-1503657597-1187023575=:19529"
Cc: Peter Staubach <staubach@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	NFS List <nfs@lists.sourceforge.net>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IKd3d-0001qq-QA
	for nfs@lists.sourceforge.net; Mon, 13 Aug 2007 09:46:22 -0700
Received: from mail.cendio.se ([193.12.253.69])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IKd3g-0003kG-Jf
	for nfs@lists.sourceforge.net; Mon, 13 Aug 2007 09:46:26 -0700
In-Reply-To: <1187022103.6628.12.camel@heimdal.trondhjem.org>
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

--789237761-1503657597-1187023575=:19529
Content-Type: TEXT/PLAIN; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Mon, 13 Aug 2007, Trond Myklebust wrote:

>> Well, no customers were complaining, so it wasn't much of a priority...
>>=20
>> Can you say 'circular argument'?
>Could we add a CONFIG option to enable regressive distributions to turn
>this feature off?=20

It would be much more useful with a glibc runtime configuration.=20


>I'm sick and tired of having to constantly postpone necessary=20
>functionality just because application writers aren't capable of coding=20
>up standards compliant programs.

I don't understand this logic. What kind of standard is a 32 bit non-LFS=20
app breaking?

What kind of functionality are you thinking of? 100% guaranteed unique=20
inode numbers, assuming that all fileids are unique? You already have that=
=20
on 64 bit systems, and as far as I understand, it should be possible to=20
get this for LFS-aware 32 bit apps as well.=20

Or are you referring to 100% guaranteed unique inode numbers for 32 bit=20
apps, LFS aware or not? Why is this important?

Or are you thinking of some other functionality?


Regards,=20
---
Peter =C3=85strand=09=09ThinLinc Chief Developer
Cendio AB=09=09http://www.cendio.se
Wallenbergs gata 4
583 30 Link=C3=B6ping=09Phone: +46-13-21 46 00
--789237761-1503657597-1187023575=:19529
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--789237761-1503657597-1187023575=:19529
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--789237761-1503657597-1187023575=:19529--

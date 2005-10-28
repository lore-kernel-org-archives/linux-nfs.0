From: email builder <emailbuilder88@yahoo.com>
Subject: Re: OT: RAID perf doldrums: advice/recommendations?
Date: Fri, 28 Oct 2005 15:41:50 -0700 (PDT)
Message-ID: <20051028224150.55430.qmail@web51910.mail.yahoo.com>
References: <Pine.LNX.4.63.0510281029570.9348@hawking.exa.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EVcv8-0003dM-1q
	for nfs@lists.sourceforge.net; Fri, 28 Oct 2005 15:41:58 -0700
Received: from web51910.mail.yahoo.com ([206.190.48.73])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1EVcv6-00033t-Q6
	for nfs@lists.sourceforge.net; Fri, 28 Oct 2005 15:41:58 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <Pine.LNX.4.63.0510281029570.9348@hawking.exa.com>
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

> I have two NFS servers which are basically clones of each other, from a=
=20
> hardware perspective.  One was set up with Red Hat 8.0, and the other w=
as=20
> running Red Hat Enterprise 3.  That becomes important later.  Both have
> Intel=20
> SE7500CW2 motherboards and 3Ware 7506 RAID controllers.
>=20
> When I set up the first system, I noticed that I was having all sorts o=
f=20
> trouble with the gigabit card.  I'll just paste in some of my notes:

<snip> we don't seem to have any actual eth problems
=20
> The other problem we noticed is that the server with RH8 had pretty dec=
ent=20
> NFS performance, where the RHEL3 system seemed very slow.  After a lot =
of=20
> conferring with Red Hat on this, I was told that it was because of the
> change=20
> from async to sync as the default for exports and that I should specify
> async=20
> when exporting.  I asked them about the safety of this (FAQ: B6), but d=
on't
>=20
> recall getting much by way of response; however, since performance *was=
*=20
> better with async and since the complaints about performance were very
> loud,=20
> I had little choice but to stick with that.

Ouch.  I have spent many hours reading about this, and general consensus
seems to say this is not a good idea.  This to me (along with their appar=
ent
inability to solve the issues with the 3Ware card) indicates that RedHat =
is a
bad choice for NFS servers.... I mean, if they just say you should do
something dangerous because it is the only way to get better performance =
but
then not back it up or have any kind of real response to the fact that th=
is
should not be the appropriate thing to do....  well, you get the picture.=
=20
Maybe we'll try FreeBSD before we change anything else or buy new hardwar=
e.

> The other thing I've done to (hopefully) improve performance was to
> increase=20
> the number of NFS threads being spawned, and give them each a bunch of

Yeah, we bumped ours to 128 just to be safe (beside the severe iowait, ou=
r
machine is lightly used).  The default 8 were being absolutely swamped.

> memory=20
> ([rw]mem_{default,max}).  I figure these boxes are NFS servers and they=
've=20

Where do you set their memory and what are people's recommended changes f=
or
getting more "umph" out of NFS?

Thanks a ton for sharing!

> got the memory to spare, so I may as well dedicate that memory to what=20
> they're supposed to be doing.  I can't speak to the "Extremely high iow=
ait=20
> with 3Ware array and moderate disk activity", but if anyone hears anyth=
ing=20
> about that, I'd certainly be interested in hearing as well.



=09
	=09
__________________________________=20
Yahoo! Mail - PC Magazine Editors' Choice 2005=20
http://mail.yahoo.com


-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.
Get Certified Today * Register for a JBoss Training Course
Free Certification Exam for All Training Attendees Through End of 2005
Visit http://www.jboss.com/services/certification for more information
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: NFS client write performance issue ... thoughts?
Date: Wed, 7 Jan 2004 12:50:45 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C6113020AC9B7@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1AeKdj-0004yZ-4S
	for nfs@lists.sourceforge.net; Wed, 07 Jan 2004 12:50:55 -0800
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1AeKdi-00079C-Rr
	for nfs@lists.sourceforge.net; Wed, 07 Jan 2004 12:50:54 -0800
To: "Paul Smith" <pausmith@nortelnetworks.com>
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

ClearCase is a unique situation.

i would love an opportunity to work directly with the
Rational folks to make their products work well on
Linux NFS.  my (limited) experience with ClearCase
is that it is not terribly NFS friendly.


> -----Original Message-----
> From: Paul Smith [mailto:pausmith@nortelnetworks.com]
> Sent: Tuesday, January 06, 2004 1:10 PM
> To: nfs@lists.sourceforge.net
> Subject: Re: [NFS] NFS client write performance issue ... thoughts?
>=20
>=20
> %% "Lever, Charles" <Charles.Lever@netapp.com> writes:
>=20
>   lc> large commercial databases write whole pages, and never
>   lc> parts of pages, at once, to their data files.  and they
>   lc> write log files by extending them in a single write
>   lc> request.
>=20
>   lc> thus the single-write-request per-page limit is not a
>   lc> problem for them.
>=20
> I'm sure you're correct, but in our environment (ClearCase) the usage
> characteristics are very different.
>=20
> I'm working on getting you some hard numbers but I think we=20
> do all agree
> that for this particular use case as I've described it, the=20
> Linux method
> would result in less performance than the Sun method.  I'm not saying
> the Sun method is better in all cases, or even in most cases, I'm just
> saying that for this particular usage we are seeing a performance
> penalty on Linux.
>=20
>=20
> The question is, is there anything to be done about this?  Or is this
> too much of a niche situation for the folks on this list to worry much
> about?
>=20
> I took Trond's comments on using mmap() to heart: in retrospect it
> surprises me that they don't already use mmap() because I would think
> that would give better performance.  But in any case all we can do is
> suggest this to IBM/Rational and a major change like that=20
> will be a long
> time coming, even if they do accept it is a good idea.
>=20
> --=20
> --------------------------------------------------------------
> -----------------
>  Paul D. Smith <psmith@nortelnetworks.com>   HASMAT--HA=20
> Software Mthds & Tools
>  "Please remain calm...I may be mad, but I am a=20
> professional." --Mad Scientist
> --------------------------------------------------------------
> -----------------
>    These are my opinions---Nortel Networks takes no=20
> responsibility for them.
>=20
>=20
> -------------------------------------------------------
> This SF.net email is sponsored by: Perforce Software.
> Perforce is the Fast Software Configuration Management System offering
> advanced branching capabilities and atomic changes on 50+ platforms.
> Free Eval! http://www.perforce.com/perforce/loadprog.html
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>=20


-------------------------------------------------------
This SF.net email is sponsored by: Perforce Software.
Perforce is the Fast Software Configuration Management System offering
advanced branching capabilities and atomic changes on 50+ platforms.
Free Eval! http://www.perforce.com/perforce/loadprog.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

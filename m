From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: [Storage_sig] Re: Question on bug tracking for NFSv4 work
Date: Thu, 9 Dec 2004 14:24:27 -0800
Message-ID: <482A3FA0050D21419C269D13989C61130435EC84@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>, <storage_sig@osdl.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CcWiA-0004jr-Gb
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 14:24:34 -0800
Received: from mx2.netapp.com ([216.240.18.37])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CcWi9-0005v5-Rr
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 14:24:34 -0800
To: "J. Bruce Fields" <bfields@fieldses.org>,
        "Bryce Harrington" <bryce@osdl.org>
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

> On Thu, Dec 09, 2004 at 01:53:53PM -0800, Bryce Harrington wrote:
> > Maybe a good compromise would be for those of us doing testing who
> > want to track bugs, to do so, but continue using the=20
> mailing lists as
> > the primary mechanism.  That way if the bug tracking=20
> approach fizzles
> > out, it doesn't affect normal processes, but if it succeeds then
> > people can make heavier use of it.  Does this sound like a feasible
> > approach?
>=20
> I think that's the only way to go.  Some developers may just=20
> never look
> at the bug database, so it may be necessary for other people to do
> things like retest and close old bugs for them.
>=20
> A bug database is certainly worth a try, though.

we tried this once already.  i set up a cvstrac bug database here at
CITI.  you and i were the only ones who actually touched the thing, and
now it is long since dead.

will something like this work if some people use it and others don't?
there's no way i can assign a bug to someone who won't use the database.
that means we have to have two separate processes for tracking bugs
(email and database) to accomodate both types of developers.  and we
have to remember which process to use when submitting a bug report for
each developer.

i'd rather have a single common bug tracking system.  that common
denominator seems to be e-mail.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: [Storage_sig] Re: Question on bug tracking for NFSv4 work
Date: Wed, 15 Dec 2004 11:45:56 -0800
Message-ID: <482A3FA0050D21419C269D13989C611307CF4B8B@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>, <storage_sig@osdl.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cef63-0002vV-Lv
	for nfs@lists.sourceforge.net; Wed, 15 Dec 2004 11:46:03 -0800
Received: from mx2.netapp.com ([216.240.18.37])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1Cef62-00053p-SA
	for nfs@lists.sourceforge.net; Wed, 15 Dec 2004 11:46:03 -0800
To: "Bryce Harrington" <bryce@osdl.org>
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

> On Fri, 10 Dec 2004, Lever, Charles wrote:
> > we may not "lose" bugs if we record them in the database, but we may
> > "lose" them because they get ignored after they are added. =20
> what kind of
> > resources are available to manage (police) the process?  do=20
> we have a
> > triage mechanism for incoming bugs?
>=20
> Well, the approach I've used in the past is to establish four
> criticalities (high, med, low, and unsorted).  Stuff that=20
> causes crashes
> or data loss go into high.  Stuff that is really minor is set to low,
> everything else is medium.  In the run-up to a release, developers try
> to fix most of the high criticality items (with the rest left=20
> as 'known
> issues').  The bug tracker isn't used for prioritization of which bugs
> to fix (that's up to whomever is wrangling the releases to decide).
>=20
> With the SourceForge bug tracker, it's also possible to CC=20
> all bugs and
> bug reports to a mailing list, so I typically configure a
> foo-tracking@lists.sf.net list for people to get notified=20
> about bugs.  I
> think Bugzilla can be likewise configured.
>=20
> For managing the process, I personally prefer treating it less as
> something that needs 'policing' and more like a collective whiteboard
> that the developers have strong ownership of and use to assist in
> preparing for the release.  Most of the time it's left fairly=20
> informal,
> with users, testers, and developers using it as a place to share info
> about the bugs.  In the weeks leading up to the release, the list is
> more carefully analyzed and tracked by the release coordinator.

there are several processes a bug tracker can help us with.  i think
some of these issues are more tractable than others.  to wit:

1.  personal bug to-do lists

    this will work well, i think, and is what most folks
    would like to have.  each tester and developer can
    chose to use or not use the bug tracker.  it will
    provide a venue for publishing bug lists.  and each
    developer or tester can track problems in his or her
    own source trees.

2.  release management

    this is probably impractical unless we have 100%
    participation and the maintainers want to use the
    tool this way.  we don't need or want group
    process here yet (do we?).  but it could work quite
    well if we require bugs & patches to be in the
    database as part of the process of submitting a
    patch to one of the maintainers.

3.  user/outside bug submission

    this is also probably impractical.  testers and
    developers can assign and chase their own bugs;
    users need an area expert to do this.  i expect
    that if a user reports a problem on the mailing
    list and a tester or developer wants to register
    it and track it themselves, then that's fine.
    (see below)

4.  others?

i think it would be best to track all bugs in the Linux NFS/RPC clients,
servers, and user-level utilities in one database.

> The area I personally have seen bug trackers pay off the most is for
> users reporting issues.  This can be especially useful with obscure or
> hard to reproduce bugs, since it can be entered, and then someone else
> (such as a tester) can later validate it and add more info, until it
> becomes clear enough to a developer that it can be fixed.

i think this is impractical without defining human resources who can
assign and track these problems, as we are making participation
optional, who can help users refine the problem description if it is
lacking, and who can filter out duplicates and pilot error.  also i
would rather that the distributors handle as much customer support as
possible.

imho the e-mail list is still the best place for this.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

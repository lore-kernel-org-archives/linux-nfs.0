From: Bryce Harrington <bryce@osdl.org>
Subject: RE: [Storage_sig] Re: Question on bug tracking for NFSv4 work
Date: Mon, 13 Dec 2004 17:14:32 -0800 (PST)
Message-ID: <Pine.LNX.4.33.0412102133320.30320-100000@osdlab.pdx.osdl.net>
References: <482A3FA0050D21419C269D13989C611307CF4B7F@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <nfs@lists.sourceforge.net>, <storage_sig@osdl.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ce1Gy-0001OJ-IH
	for nfs@lists.sourceforge.net; Mon, 13 Dec 2004 17:14:40 -0800
Received: from fw.osdl.org ([65.172.181.6] helo=mail.osdl.org)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1Ce1Gt-0005Gf-Ep
	for nfs@lists.sourceforge.net; Mon, 13 Dec 2004 17:14:40 -0800
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C611307CF4B7F@lavender-fe.eng.netapp.com>
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

On Fri, 10 Dec 2004, Lever, Charles wrote:
> > So I think that keeping the bugs themselves up to date
> > (updating status, etc.) would be our principle challenge.
>
> my concern exactly.  i wonder about the effectiveness v. overhead ratio
> because we won't have 100% developer participation.  i wonder who will
> define and enforce the tracking process.  ie. bug databases are great in
> theory, but in practice, sometimes there are big problems...

Well, anyway, I'm willing to put some time to help in this area if it
would be needed.  I had seen this listed on the NFS priorities page, and
we've heard the need expressed by several others, so am of the
assumption that there are people interested in using and participating
with it.  I've seen it work well elsewhere, like I mentioned, and feel
like it could be an effective tool for the NFS project.  It does work
best if developers view it as a useful tool, though.

A lot of open source projects do use bug trackers and find them handy,
but there's also a lot that don't use them, or that only use them
partially (like the Linux kernel).

> we may not "lose" bugs if we record them in the database, but we may
> "lose" them because they get ignored after they are added.  what kind of
> resources are available to manage (police) the process?  do we have a
> triage mechanism for incoming bugs?

Well, the approach I've used in the past is to establish four
criticalities (high, med, low, and unsorted).  Stuff that causes crashes
or data loss go into high.  Stuff that is really minor is set to low,
everything else is medium.  In the run-up to a release, developers try
to fix most of the high criticality items (with the rest left as 'known
issues').  The bug tracker isn't used for prioritization of which bugs
to fix (that's up to whomever is wrangling the releases to decide).

With the SourceForge bug tracker, it's also possible to CC all bugs and
bug reports to a mailing list, so I typically configure a
foo-tracking@lists.sf.net list for people to get notified about bugs.  I
think Bugzilla can be likewise configured.

For managing the process, I personally prefer treating it less as
something that needs 'policing' and more like a collective whiteboard
that the developers have strong ownership of and use to assist in
preparing for the release.  Most of the time it's left fairly informal,
with users, testers, and developers using it as a place to share info
about the bugs.  In the weeks leading up to the release, the list is
more carefully analyzed and tracked by the release coordinator.

> is this for just development testers, or do we accept bug reports from
> users, NFS implementation partners, or the Linux distributors?  are we
> interested solely in NFSv4 issues, or do we want reports on
> v2/3-specific problems, side band protocol issues, problems occuring in
> advanced development projects, or RPC SEC issues?  do we have a good
> reason to exclude any of these bug types?

OSDL's mainly interested in NFS on linux.  My own area of focus is v4.
However, I would think that a general purpose bug tracker with
categories for the different areas would could be logical.

The area I personally have seen bug trackers pay off the most is for
users reporting issues.  This can be especially useful with obscure or
hard to reproduce bugs, since it can be entered, and then someone else
(such as a tester) can later validate it and add more info, until it
becomes clear enough to a developer that it can be fixed.

I know that they can also be used for tracking day-to-day development
bugs, but since you can just email the developer directly this probably
wouldn't be an area where you'd be using a bug tracker.

> my position is that i would like this to work, as bruce would.  but i
> would also like not to waste time if there is a good chance that a bug
> database will be ineffective and eventually abandoned, as both citi's
> NFSv4 cvstrac and SF's NFS bug database were.

*Nod* Well, I'm willing to help with it if folks want to give it a shot.
I agree with you that if it's considered to be not worth the effort,
then time would be better spent elsewhere.  I'm optimistic that it could
be made to work, but I'm still just a newbie in this project so would
appreciate if others would make the call of whether it's worth trying.

Thanks,
Bryce





-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Bryce Harrington <bryce@osdl.org>
Subject: Re: [Storage_sig] Re: Question on bug tracking for NFSv4 work
Date: Thu, 9 Dec 2004 13:53:53 -0800 (PST)
Message-ID: <Pine.LNX.4.33.0412091330180.8023-100000@osdlab.pdx.osdl.net>
References: <200412091441.PAA173944@isatis.frec.bull.fr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <hch@infradead.org>, <nfs@lists.sourceforge.net>, <storage_sig@osdl.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CcWEt-0002VY-Sl
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 13:54:19 -0800
Received: from fw.osdl.org ([65.172.181.6] helo=mail.osdl.org)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CcWEq-0004zh-R7
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 13:54:19 -0800
To: Tony Reix <Tony.Reix@bull.net>
In-Reply-To: <200412091441.PAA173944@isatis.frec.bull.fr>
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

On Thu, 9 Dec 2004, Tony Reix wrote:
> { > The reason for the question is that a number of companies
> { > (CITI, Polyserv, Novell, NetApp, etc.) we've been talking with are doing
> { > testing of NFSv4, and have expressed interest in sharing of results,
> { > including a public bug tracker (both for posting bugs that are found,
> { > and for reviewing/validating/elaborating bugs that others post).
> {
> { I suspect the best thing would be to post them to the mailinglist, the
> { same way bugs are reported for just about any other subsystem.
>
> I think a mailing list is not appropriate for NFSv4 bug tracking.
> The testers need to have tools for checking that the bugs they have opened
> have make progress, and to add new information.
> The developpers need tools for managing all the bugs they are working on
> and to answer to testers.
> Managing defects is a pain we cannot go without. Just make it easier to live with.

As an example of how a bug tracker can really help in an open source
project, one project I am involved with (Inkscape) originally used
a mailing list for handling bugs, however it was rather infamous for
crashing, losing data, and big problems going unresolved for a long
time.

About a year and a half ago, the development team started making use of
a bug tracker (just the simple one on SourceForge), encouraging users to
report bugs there, and involving a lot of people in testing out the bug
reports both to verify that the bugs are recreatable and that the
patches solved the problem.  This was particularly useful at around
release time because we could track and review all of the critical bugs
and focus on getting those resolved (and verfied fixed) before
releasing.

Today, because of this effort, Inkscape's reputation is that it is very
robust and difficult to make crash.  Also, most of the common problems
people run into are documented (sometimes with work-arounds) in the bug
tracker.

It's true that most open source projects don't use bug trackers, and
certainly a fact that they're more work to manage, however I've seen
them have a very beneficial long term effect on projects and I would
love to see NFSv4 benefit this way as well.  If NFSv4 can gain a
reputation of being extremely robust, that could become a great selling
point for it.

However, I know that not everyone likes having to use bug trackers, and
that's understandable.  Maybe a good compromise would be for those of us
doing testing who want to track bugs, to do so, but continue using the
mailing lists as the primary mechanism.  That way if the bug tracking
approach fizzles out, it doesn't affect normal processes, but if it
succeeds then people can make heavier use of it.  Does this sound like a
feasible approach?

Bryce




-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

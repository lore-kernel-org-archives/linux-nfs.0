From: Bryce Harrington <bryce@osdl.org>
Subject: Re: [Storage_sig] Re: Question on bug tracking for NFSv4 work
Date: Thu, 9 Dec 2004 17:07:45 -0800 (PST)
Message-ID: <Pine.LNX.4.33.0412091610451.8023-100000@osdlab.pdx.osdl.net>
References: <20041209224837.GE22994@fieldses.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Lever, Charles" <Charles.Lever@netapp.com>, <nfs@lists.sourceforge.net>,
   <storage_sig@osdl.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CcZG8-0000ut-LV
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 17:07:48 -0800
Received: from fw.osdl.org ([65.172.181.6] helo=mail.osdl.org)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CcZG7-00026T-MW
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 17:07:48 -0800
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20041209224837.GE22994@fieldses.org>
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

On Thu, 9 Dec 2004, J. Bruce Fields wrote:

> On Thu, Dec 09, 2004 at 02:24:27PM -0800, Lever, Charles wrote:
> > we tried this once already.  i set up a cvstrac bug database here at
> > CITI.  you and i were the only ones who actually touched the thing, and
> > now it is long since dead.

Do you think any of the bugs in that system still valid?  If so would
it be possible for us to get a copy in some form (db dump or whatever)?

> Part of the problem was just that we didn't have the time to maintain
> the database.  (It was crashing periodically at one point).

The two options we have both have dedicated sysadmin staff attached.
The existing nfs bug tracker on SourceForge has the SF administration;
there's outages every once and a while but it tends to be good enough.
For the other option, Bugzilla hosted at OSDL, we can get the normal
admin support as we do for the Linux kernel Bugzilla.

So I think that keeping the bugs themselves up to date (updating status,
etc.) would be our principle challenge.  Keeping the system running
shouldn't be a problem.

> > will something like this work if some people use it and others don't?
>
> I don't know.  We might be able to deal with a few who didn't if there
> were testers willing to do some of the work for them.  E.g. retest old
> bugs and email the list if necessary.

I also don't know how it'll work, however at Inkscape we definitely have
some people who are more attentive to using it than others, and they
tend to make up for those who aren't.  Also, a lot of bugs don't ever
make it to the tracker before getting fixed, and that ends up being
fine; the main value of the tracker is for bugs that can't (or won't) be
fixed right away, so they don't get lost.

> To me it seems at least worth a try, if there's people willing to spend
> the time.

Same here.  I can dedicate time to getting it organized over the coming
months, if we have enough testers willing to make use of it.

Bryce



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

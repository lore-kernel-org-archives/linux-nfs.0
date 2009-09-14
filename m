Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:34630 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750815AbZINHHj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Sep 2009 03:07:39 -0400
From: Neil Brown <neilb@suse.de>
To: Chuck Lever <chuck.lever@oracle.com>
Date: Mon, 14 Sep 2009 17:08:37 +1000
Content-Type: text/plain; charset=us-ascii
Message-ID: <19117.60405.793389.323010@notabene.brown>
Cc: "Trond Myklebust" <trond.myklebust@fys.uio.no>,
        "Jeff Layton" <jlayton@redhat.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, steved@redhat.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/4] nfs-utils: introduce new statd implementation (1st part)
In-Reply-To: message from Chuck Lever on Thursday September 10
References: <20090805143550.12866.8377.stgit@matisse.1015granger.net>
	<20090805144540.12866.22084.stgit@matisse.1015granger.net>
	<20090805174811.GB9944@fieldses.org>
	<DBAD3130-0633-414A-914B-CC2F15ABB219@oracle.com>
	<20090805181545.GF9944@fieldses.org>
	<7330021D-C95A-463D-8D18-29453EF185BC@oracle.com>
	<1249507356.5428.11.camel@heimdal.trondhjem.org>
	<D503383F-3D52-4F93-B850-AFE84316435C@oracle.com>
	<1249515004.5428.34.camel@heimdal.trondhjem.org>
	<20090909142945.755da393@tlielax.poochiereds.net>
	<1252521599.8722.53.camel@heimdal.trondhjem.org>
	<20B7C2F0-E566-4292-91E9-41A3FA6C9D4C@oracle.com>
	<1252525327.8722.81.camel@heimdal.trondhjem.org>
	<D2B488FA-2630-4355-8E3B-FE1243E4C3AE@oracle.com>
	<9eae93545189a6be6eebe0460b860fc7.squirrel@neil.brown.name>
	<BA66527C-2F6E-4378-8CC1-35B26C444D0E@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thursday September 10, chuck.lever@oracle.com wrote:
> On Sep 10, 2009, at 4:44 AM, NeilBrown wrote:
> > On Thu, September 10, 2009 8:18 am, Chuck Lever wrote:
> >> The idea that "the Linux way" is the best and only way is ridiculous
> >> on its face, anyway.  I mean, what do you expect when we have no
> >> requirements and specification process, no formal testing, C coding
> >> style conventions based on 20-year old coding practices, a hit-or- 
> >> miss
> >> review process that relies more on reviewers' personal preferences
> >> than any kind of standards, no static code analysis tools, no defect
> >> metrics or bug meta-analysis tools, kernel debuggers are verboten, a
> >> combative mailing list environment, and parts of our knowledge base
> >> and team history are lost every time a developer leaves (in this  
> >> case,
> >> Olaf and Neil)?  It's no wonder we never change anything unless
> >> absolutely necessary!
> >
> > And yet is largely works!
> > I could summarise a lot of your points by observing that the community
> > values people over process.  I really think that is the right place to
> > put value, because people are richer and more flexible than process.
> 
> Agreed, but there are risks to that approach as well, which are  
> largely ignored by the Linux community.  The last point in my list is  
> probably the biggest risk: when people leave, we are stuck with  
> decades-old code that no-one understands.  Cf: statd.
> 

Much of my understanding of statd is embedded in the code in
nfs-utils, and in the change log (which is much better since we
changed to git).
By discarding all that and creating a new project you risk losing that
legacy.

There can certainly be a case of discarding and starting again.  I did
that with the support tools for raid (raidtools is no-more, mdadm
reigns :-).  But this is not a decision to be taken lightly and is not
without it's costs.  The fact that raidtools was by that time
essentially an unmaintained orphan made some of those costs
unavoidable in my case.

You obviously could do the same thing - you don't need anyone's
permission: create a new project called "statd" and make it whatever
you want and hope that distributors will pick it up.  If your statd
supports IPv6, and the nfs-utils one does not, then there is a good
chance that distros will pick it up as people like to see that big
tick next to "IPv6 support".

Maintaining and developing such a thing long enough to establish a
self-sustaining community would be a big effort.  You would need to
compare that with the effort of taking the incremental approach and
revising the code in nfs-utils and getting those revisions accepted.
That would probably have a higher development cost, but a lower
maintenance cost.  It is very hard to know up front which cost is
lower.

But you will leave one day.  How can you best make sure that you leave
something that others can maintain????


> My point is that many of the items I mentioned above are expressly  
> designed to allow quicker, less risky change, precisely to decrease  
> the amount of time and effort to get new features into our code.  Yet  
> we turn our back on all of them in favor of an antique "don't touch  
> that!" policy.  "Don't touch that!" is not a reasonable argument  
> against replacing components that need to be replaced.

The only "Don't touch that" which I am aware of relates to interfaces,
particularly with established code.
In the case of statd, the files in sm/ and sm.bak/ are a well
established interface.  Exactly how much is dependant on it is hard to
say.  Not much formal code I expect but maybe some obscure scripts and
lots of sysadmin knowledge.

Can you run them both in parallel??  i.e. have a database with all the
data, but also store it in the files (if the hostname can be
represented in ASCII)... It is hard to guess how easy that would be
and how worthwhile it would be.  And it doesn't answer the question of
whether sqlite is stable enough.

> 
> > I agree that combative mailing lists are a problem, but even there, I
> > believe most of the aggression is more perceived than real, and that
> > a graceful, humble, polite attitude can have a positive-feedback  
> > effect
> > too.
> 
> Years ago I believed that, but I have seen much evidence to the  
> contrary in this community.  More often such an attitude is entirely  
> ignored, or treated as an invitation for abuse, especially by people  
> who have no interest in politeness.  This kind of approach has no  
> effect on the leaders in the Linux community, who set an example of  
> extreme rudeness and belligerence.

That last comment is interesting.  At the 2007 kernel summit (the last
one I was at) the topic of mailing list etiquette was discussed and
there seemed to be agreement that we, the leaders (I guess the kernel
summit attendees are the closest we have to group leadership) have a
role in damping down the fire, not building it up.  My feeling is that
most high profile people do quite well, but maybe I am too forgiving.

> 
> I've made an effort to stop arguing small points, and to make  
> observations and not argue.  I still get e-mail full of "crap" this  
> and "bullshit" that and "NACK!" with little explanation.

I certainly agree that sort of response is best not sent.  And I must
confess to a recent experience (on a different list) where I gave up
due to similar behaviour.   That is partly why I decided to join in
this discussion (though I'm not sure if I'm being helpful yet).

> 
> > Yes, there are lots of practices that might improve things that we  
> > don't
> > have standardised.  But one practice we do have that has proven very
> > effective is incremental refinement.  It can be hard to understand  
> > what
> > order to make changes until after you have made them, but once you
> > understand what you want to do, going back and doing it in logical
> > order really is very effective.  It makes it easier for others to
> > review, it makes it easy for you to review yourself.  It means
> > less controversial bits can be included quickly leaving room for the
> > more controversial bits to be discussed in isolation.
> 
> I am a fan of incremental refinement, and I use that approach as often  
> as I can.  There are some things that incremental refinement cannot  
> do, however.
> 
> > I think that the switch from portmap to rpcbind was a bad idea,
> > and I think that a wholesale replacement of statd is probably a
> > bad idea too.  It might seem like the easiest way to get something
> > useful working, but you'll probably be paying the price for years as
> > little regression turn up because you didn't completely understand
> > the original statd (and face it, who does?)
> 
> Yes, but _why_ is it a bad idea?  All I hear is "this is a bad idea"  
> and "you could do it some other way" but these are qualitative, not  
> quantitative arguments.  They are religious statements, not specific  
> technical criticisms.

It is a bad idea because it doesn't have the legacy of testing and
refinement.  Almost as soon as we started using it bugs were found -
or at least differences in behaviour to portmap (something about the
privilege level required to register a binding I think).

Now I admit that no one put their hand up to add IPv6 support to
portmap, arguably it could have been a worse idea to stay with portmap
as it meant no IPv6.  But changing was still a bad idea.

Had we (had the man power to) incrementally enhance portmap we would
have had a much more reviewable process, and a bisectable result which
would allow regression to be isolated more directly.

> 
> This leaves me with the impression that folks are responding out of a  
> fear of the unknown, and not out of a considered technical opinion.   
> If sqlite3 is outside of people's comfort zone, that's OK.  Please  
> let's be honest about it instead of slinging mud and throwing up a  
> bunch of generic arguments that no one can rebut.
> 
> > As for the use of sql-lite ... I must admit that I wouldn't choose
> > it.  Maybe it is a good idea.  If it is, you probably need to merge
> > that change early with a clear argument and tools to make it  
> > manageable
> > (e.g. a developer will want to tool to be able to look inside the
> > database easily and make changes, without having to know sql).
> > It is much easier to discuss one thing at a time on these
> > combative mailing lists ;-)
> 
> That's a fine and constructive comment, thanks.
> 
> There is already a tool for managing the data in the database:  
> 'sqlite3' the executable, which can be used in shell scripts.  There  
> are also sqlite3 libraries for Python and Perl and C.  This is really  
> not very different from POSIX file system calls and using 'cat'.  SQL  
> is not difficult to learn, and a one or two page recipe document is  
> easy to provide.  I certainly have not used any advanced features of  
> SQL to implement new statd.
> 
> Given the complexity of the change, it makes it much easier to argue  
> against sqlite3, however, if it is separated from the set of changes  
> that motivate its use.  Bruce, for example, has stated to me  
> specifically that he prefers having such changes and their  
> motivational requirements included in the same patch.  I regularly  
> code for several different maintainers, and each one has his own  
> preferences, often contradicting other maintainers.  I don't think  
> regular maintainers have any idea how confusing and challenging this is.
> 

:-)

I think there has to be room for balance here.  Certainly it is best
to use new functionality as soon as it is added so the use case is
clear.  But I can imagine that converting from a files database to a
sqlite database would be several patches in itself.  And then if you
want to start adding 'search' or 'utf-16' functionality, that would be
more patches still.  Combining all that in to one big patch just to
keep the change with the motivation seems unlikely to be a win from
anyone's perspective.
Certainly having a real big changelog comment early on that
explains the value of sqlite would be essential, and that patch would
not be merged until the subsequent ones were reviewed.


> Note, however, I am not married to the specifics of sqlite3.  What I  
> am attached to is the ideas that the current system is inadequate for  
> the kinds of features we want to add to statd, and that statd should  
> not worry about the details of data storage, or search and management  
> of the host records, because we have other tools that are better at  
> this.  If there is another solution that provides a durable and  
> flexible way to store and search host records and offload the details  
> to pre-existing code, I'm open.  However, sqlite3 is the most widely  
> used embedded database on the planet, and is eminently suitable for  
> this task.
> 
> > And we do have static code analysis tools.  Both 'gcc' and 'sparse'
> > fit that description.
> 
> Yes, gcc can provide some static analysis, if the correct options are  
> specified, and care is taken to eliminate the noise of false  
> positives.  There is a prevailing attitude, however, that this is a  
> worthless endeavor.  Witness the amount of noise that comes out when  
> you build a Red Hat kernel or the nfs-utils package.  Witness also the  
> sarcasm of Linus who repeatedly chides folks for not running sparse  
> regularly.
> 
> Additionally, gcc is not the best tool for this job, given the often  
> oblique way it calls out errors and warnings.  There are purify,  
> fortify, and splint, just to name three, that are standard analysis  
> tools we don't even consider.
> 
> My comment goes more to the point that static analysis is not  
> considered of any value.

You might be right....

I see there be a "law of diminishing returns" here.
sparse (aka "make C=1") has almost never shown me anything
interesting.  So while there is a (small) cost in running it, there is
almost no perceived value.

For my own C projects I always compile with "-Wall -Werror" to
remove the cost of running it and to artificially increase the value.

I just tried "make C=1" on a couple of bits of kernel code and it did
provide some vaguely interesting things that I'll probably fix.
But there was a lot of noise like:
  warning: potentially expensive pointer subtraction
which I don't think I want to fix, but don't know how to silence the
warning for just that case.  It would be nice of "C=1" was a default
and either the warning, or sparse, were fixed.   That might increase
the perception that this sort of thing was of value.

Some time ago Greg Banks went on a pursuit of warnings in nfs-utils
and got rid of all of them -- except those generated by rpcgen. 
Have more been introduced?

NeilBrown

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:18063 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753316AbZIJOJj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Sep 2009 10:09:39 -0400
From: Chuck Lever <chuck.lever@oracle.com>
To: NeilBrown <neilb@suse.de>
In-Reply-To: <9eae93545189a6be6eebe0460b860fc7.squirrel@neil.brown.name>
Subject: Re: [PATCH 1/4] nfs-utils: introduce new statd implementation (1st part)
References: <20090805143550.12866.8377.stgit@matisse.1015granger.net> <20090805144540.12866.22084.stgit@matisse.1015granger.net> <20090805174811.GB9944@fieldses.org> <DBAD3130-0633-414A-914B-CC2F15ABB219@oracle.com> <20090805181545.GF9944@fieldses.org> <7330021D-C95A-463D-8D18-29453EF185BC@oracle.com> <1249507356.5428.11.camel@heimdal.trondhjem.org> <D503383F-3D52-4F93-B850-AFE84316435C@oracle.com> <1249515004.5428.34.camel@heimdal.trondhjem.org> <20090909142945.755da393@tlielax.poochiereds.net> <1252521599.8722.53.camel@heimdal.trondhjem.org> <20B7C2F0-E566-4292-91E9-41A3FA6C9D4C@oracle.com> <1252525327.8722.81.camel@heimdal.trondhjem.org> <D2B488FA-2630-4355-8E3B-FE1243E4C3AE@oracle.com> <9eae93545189a6be6eebe0460b860fc7.squirrel@neil.brown.name>
Message-Id: <BA66527C-2F6E-4378-8CC1-35B26C444D0E@oracle.com>
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Date: Thu, 10 Sep 2009 10:09:09 -0400
Cc: "Trond Myklebust" <trond.myklebust@fys.uio.no>,
        "Jeff Layton" <jlayton@redhat.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, steved@redhat.com,
        linux-nfs@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sep 10, 2009, at 4:44 AM, NeilBrown wrote:
> On Thu, September 10, 2009 8:18 am, Chuck Lever wrote:
>> The idea that "the Linux way" is the best and only way is ridiculous
>> on its face, anyway.  I mean, what do you expect when we have no
>> requirements and specification process, no formal testing, C coding
>> style conventions based on 20-year old coding practices, a hit-or- 
>> miss
>> review process that relies more on reviewers' personal preferences
>> than any kind of standards, no static code analysis tools, no defect
>> metrics or bug meta-analysis tools, kernel debuggers are verboten, a
>> combative mailing list environment, and parts of our knowledge base
>> and team history are lost every time a developer leaves (in this  
>> case,
>> Olaf and Neil)?  It's no wonder we never change anything unless
>> absolutely necessary!
>
> And yet is largely works!
> I could summarise a lot of your points by observing that the community
> values people over process.  I really think that is the right place to
> put value, because people are richer and more flexible than process.

Agreed, but there are risks to that approach as well, which are  
largely ignored by the Linux community.  The last point in my list is  
probably the biggest risk: when people leave, we are stuck with  
decades-old code that no-one understands.  Cf: statd.

My point is that many of the items I mentioned above are expressly  
designed to allow quicker, less risky change, precisely to decrease  
the amount of time and effort to get new features into our code.  Yet  
we turn our back on all of them in favor of an antique "don't touch  
that!" policy.  "Don't touch that!" is not a reasonable argument  
against replacing components that need to be replaced.

> I agree that combative mailing lists are a problem, but even there, I
> believe most of the aggression is more perceived than real, and that
> a graceful, humble, polite attitude can have a positive-feedback  
> effect
> too.

Years ago I believed that, but I have seen much evidence to the  
contrary in this community.  More often such an attitude is entirely  
ignored, or treated as an invitation for abuse, especially by people  
who have no interest in politeness.  This kind of approach has no  
effect on the leaders in the Linux community, who set an example of  
extreme rudeness and belligerence.

I've made an effort to stop arguing small points, and to make  
observations and not argue.  I still get e-mail full of "crap" this  
and "bullshit" that and "NACK!" with little explanation.

> Yes, there are lots of practices that might improve things that we  
> don't
> have standardised.  But one practice we do have that has proven very
> effective is incremental refinement.  It can be hard to understand  
> what
> order to make changes until after you have made them, but once you
> understand what you want to do, going back and doing it in logical
> order really is very effective.  It makes it easier for others to
> review, it makes it easy for you to review yourself.  It means
> less controversial bits can be included quickly leaving room for the
> more controversial bits to be discussed in isolation.

I am a fan of incremental refinement, and I use that approach as often  
as I can.  There are some things that incremental refinement cannot  
do, however.

> I think that the switch from portmap to rpcbind was a bad idea,
> and I think that a wholesale replacement of statd is probably a
> bad idea too.  It might seem like the easiest way to get something
> useful working, but you'll probably be paying the price for years as
> little regression turn up because you didn't completely understand
> the original statd (and face it, who does?)

Yes, but _why_ is it a bad idea?  All I hear is "this is a bad idea"  
and "you could do it some other way" but these are qualitative, not  
quantitative arguments.  They are religious statements, not specific  
technical criticisms.

This leaves me with the impression that folks are responding out of a  
fear of the unknown, and not out of a considered technical opinion.   
If sqlite3 is outside of people's comfort zone, that's OK.  Please  
let's be honest about it instead of slinging mud and throwing up a  
bunch of generic arguments that no one can rebut.

> As for the use of sql-lite ... I must admit that I wouldn't choose
> it.  Maybe it is a good idea.  If it is, you probably need to merge
> that change early with a clear argument and tools to make it  
> manageable
> (e.g. a developer will want to tool to be able to look inside the
> database easily and make changes, without having to know sql).
> It is much easier to discuss one thing at a time on these
> combative mailing lists ;-)

That's a fine and constructive comment, thanks.

There is already a tool for managing the data in the database:  
'sqlite3' the executable, which can be used in shell scripts.  There  
are also sqlite3 libraries for Python and Perl and C.  This is really  
not very different from POSIX file system calls and using 'cat'.  SQL  
is not difficult to learn, and a one or two page recipe document is  
easy to provide.  I certainly have not used any advanced features of  
SQL to implement new statd.

Given the complexity of the change, it makes it much easier to argue  
against sqlite3, however, if it is separated from the set of changes  
that motivate its use.  Bruce, for example, has stated to me  
specifically that he prefers having such changes and their  
motivational requirements included in the same patch.  I regularly  
code for several different maintainers, and each one has his own  
preferences, often contradicting other maintainers.  I don't think  
regular maintainers have any idea how confusing and challenging this is.

Note, however, I am not married to the specifics of sqlite3.  What I  
am attached to is the ideas that the current system is inadequate for  
the kinds of features we want to add to statd, and that statd should  
not worry about the details of data storage, or search and management  
of the host records, because we have other tools that are better at  
this.  If there is another solution that provides a durable and  
flexible way to store and search host records and offload the details  
to pre-existing code, I'm open.  However, sqlite3 is the most widely  
used embedded database on the planet, and is eminently suitable for  
this task.

> And we do have static code analysis tools.  Both 'gcc' and 'sparse'
> fit that description.

Yes, gcc can provide some static analysis, if the correct options are  
specified, and care is taken to eliminate the noise of false  
positives.  There is a prevailing attitude, however, that this is a  
worthless endeavor.  Witness the amount of noise that comes out when  
you build a Red Hat kernel or the nfs-utils package.  Witness also the  
sarcasm of Linus who repeatedly chides folks for not running sparse  
regularly.

Additionally, gcc is not the best tool for this job, given the often  
oblique way it calls out errors and warnings.  There are purify,  
fortify, and splint, just to name three, that are standard analysis  
tools we don't even consider.

My comment goes more to the point that static analysis is not  
considered of any value.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




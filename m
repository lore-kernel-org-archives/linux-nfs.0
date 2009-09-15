Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:51451 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758020AbZIOCpe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Sep 2009 22:45:34 -0400
Cc: "Trond Myklebust" <trond.myklebust@fys.uio.no>,
        "Jeff Layton" <jlayton@redhat.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, steved@redhat.com,
        linux-nfs@vger.kernel.org
Message-Id: <6F53A5C5-63EF-44AD-92AB-A5AE8E8C3098@oracle.com>
From: Chuck Lever <chuck.lever@oracle.com>
To: Neil Brown <neilb@suse.de>
In-Reply-To: <19117.60405.793389.323010@notabene.brown>
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Subject: Re: [PATCH 1/4] nfs-utils: introduce new statd implementation (1st part)
Date: Mon, 14 Sep 2009 22:45:03 -0400
References: <20090805143550.12866.8377.stgit@matisse.1015granger.net> <20090805144540.12866.22084.stgit@matisse.1015granger.net> <20090805174811.GB9944@fieldses.org> <DBAD3130-0633-414A-914B-CC2F15ABB219@oracle.com> <20090805181545.GF9944@fieldses.org> <7330021D-C95A-463D-8D18-29453EF185BC@oracle.com> <1249507356.5428.11.camel@heimdal.trondhjem.org> <D503383F-3D52-4F93-B850-AFE84316435C@oracle.com> <1249515004.5428.34.camel@heimdal.trondhjem.org> <20090909142945.755da393@tlielax.poochiereds.net> <1252521599.8722.53.camel@heimdal.trondhjem.org> <20B7C2F0-E566-4292-91E9-41A3FA6C9D4C@oracle.com> <1252525327.8722.81.camel@heimdal.trondhjem.org> <D2B488FA-2630-4355-8E3B-FE1243E4C3AE@oracle.com> <9eae93545189a6be6eebe0460b860fc7.squirrel@neil.brown.name> <BA66527C-2F6E-4378-8CC1-35B26C444D0E@oracle.com> <19117.60405.793389.323010@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sep 14, 2009, at 3:08 AM, Neil Brown wrote:
> On Thursday September 10, chuck.lever@oracle.com wrote:
>> On Sep 10, 2009, at 4:44 AM, NeilBrown wrote:

> But you will leave one day.  How can you best make sure that you leave
> something that others can maintain????

By writing code that is self-explanatory, providing lots of comments  
in the code, adding to the git log (as you suggested) and writing  
expansive man pages that describe the interfaces in as clear a manner  
as possible.  The review process is also part of that effort.

There is also the possibility of mentoring others, as FreeBSD does,  
and providing extensive written documentation and specifications in  
wikis.  Agile methodologies suggest that rewriting as a regular  
practice is a good way for a team to retain familiarity with a code  
base.  Having a full test suite that can be used to verify the  
behavior of new or existing code is also a way to codify requirements  
and create an institutional memory of regressions, as well as to  
insulate users from regressions in new code.

>> My point is that many of the items I mentioned above are expressly
>> designed to allow quicker, less risky change, precisely to decrease
>> the amount of time and effort to get new features into our code.  Yet
>> we turn our back on all of them in favor of an antique "don't touch
>> that!" policy.  "Don't touch that!" is not a reasonable argument
>> against replacing components that need to be replaced.
>
> The only "Don't touch that" which I am aware of relates to interfaces,
> particularly with established code.
> In the case of statd, the files in sm/ and sm.bak/ are a well
> established interface.  Exactly how much is dependant on it is hard to
> say.  Not much formal code I expect but maybe some obscure scripts and
> lots of sysadmin knowledge.

There is no documentation I'm aware of of statd's on-disk format as a  
formal interface.  I have had some recent conversations with Lon about  
this, to handle any dependencies his clustering scripts may have, and  
he didn't throw up any flags.  He told me that all we needed was to  
provide a mechanism to access this data from a shell script, which we  
would have in 'sqlite3' the executable.

So this is a new requirement (to me, anyway).  If these files  
constitute a formal interface, how can statd be modified to store  
additional data or new data types in these files?  Am I allowed to put  
IPv6 presentation addresses in these files in place of IPv4  
addresses?  Am I allowed to add new fields?  Not rhetorical  
questions... really... how should I go about doing this and testing  
the result?  You seem to be suggesting that the sm/* files can't be  
used for the kind of features we want to add.

> Can you run them both in parallel??  i.e. have a database with all the
> data, but also store it in the files (if the hostname can be
> represented in ASCII)... It is hard to guess how easy that would be
> and how worthwhile it would be.  And it doesn't answer the question of
> whether sqlite is stable enough.

Is it even a good thing to freeze the sm/* files as a formal  
interface, or should we go about providing a real documented  
programming interface for this, and migrate to it?  There is a real  
risk to maintaining undocumented interfaces like this, and that is  
that we can't make any change to this code without a significant  
possibility of breaking something.

>>> I think that the switch from portmap to rpcbind was a bad idea,
>>> and I think that a wholesale replacement of statd is probably a
>>> bad idea too.  It might seem like the easiest way to get something
>>> useful working, but you'll probably be paying the price for years as
>>> little regression turn up because you didn't completely understand
>>> the original statd (and face it, who does?)
>>
>> Yes, but _why_ is it a bad idea?  All I hear is "this is a bad idea"
>> and "you could do it some other way" but these are qualitative, not
>> quantitative arguments.  They are religious statements, not specific
>> technical criticisms.
>
> It is a bad idea because it doesn't have the legacy of testing and
> refinement.  Almost as soon as we started using it bugs were found -
> or at least differences in behaviour to portmap (something about the
> privilege level required to register a binding I think).
>
> Now I admit that no one put their hand up to add IPv6 support to
> portmap, arguably it could have been a worse idea to stay with portmap
> as it meant no IPv6.  But changing was still a bad idea.
>
> Had we (had the man power to) incrementally enhance portmap we would
> have had a much more reviewable process, and a bisectable result which
> would allow regression to be isolated more directly.

What we have now is an inherited body of code (with its own history of  
incremental improvement) that is shared with many other operating  
systems, which improves our ability to interoperate with them, and  
includes bug fixes that have been made to it over the years.

I think we would have had some bugs and regressions pursuing either  
path.  There are well-understood ways to manage these risks, either way.

But this is a sidebar.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




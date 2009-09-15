Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:21219 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754643AbZIOBaN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Sep 2009 21:30:13 -0400
Cc: NeilBrown <neilb@suse.de>, Jeff Layton <jlayton@redhat.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, steved@redhat.com,
        linux-nfs@vger.kernel.org
Message-Id: <E02AB981-0157-411B-9496-A1CF223F1CBD@oracle.com>
From: Chuck Lever <chuck.lever@oracle.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1252936467.6866.54.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Subject: Re: [PATCH 1/4] nfs-utils: introduce new statd implementation (1st part)
Date: Mon, 14 Sep 2009 21:29:44 -0400
References: <20090805143550.12866.8377.stgit@matisse.1015granger.net> <20090805144540.12866.22084.stgit@matisse.1015granger.net> <20090805174811.GB9944@fieldses.org> <DBAD3130-0633-414A-914B-CC2F15ABB219@oracle.com> <20090805181545.GF9944@fieldses.org> <7330021D-C95A-463D-8D18-29453EF185BC@oracle.com> <1249507356.5428.11.camel@heimdal.trondhjem.org> <D503383F-3D52-4F93-B850-AFE84316435C@oracle.com> <1249515004.5428.34.camel@heimdal.trondhjem.org> <20090909142945.755da393@tlielax.poochiereds.net> <1252521599.8722.53.camel@heimdal.trondhjem.org> <20B7C2F0-E566-4292-91E9-41A3FA6C9D4C@oracle.com> <1252525327.8722.81.camel@heimdal.trondhjem.org> <D2B488FA-2630-4355-8E3B-FE1243E4C3AE@oracle.com> <9eae93545189a6be6eebe0460b860fc7.squirrel@neil.brown.name> <BA66527C-2F6E-4378-8CC1-35B26C444D0E@oracle.com> <1252936467.6866.54.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sep 14, 2009, at 9:54 AM, Trond Myklebust wrote:
> On Thu, 2009-09-10 at 10:09 -0400, Chuck Lever wrote:
>> On Sep 10, 2009, at 4:44 AM, NeilBrown wrote:
>>> I agree that combative mailing lists are a problem, but even  
>>> there, I
>>> believe most of the aggression is more perceived than real, and that
>>> a graceful, humble, polite attitude can have a positive-feedback
>>> effect
>>> too.
>>
>> Years ago I believed that, but I have seen much evidence to the
>> contrary in this community.  More often such an attitude is entirely
>> ignored, or treated as an invitation for abuse, especially by people
>> who have no interest in politeness.  This kind of approach has no
>> effect on the leaders in the Linux community, who set an example of
>> extreme rudeness and belligerence.
>>
>> I've made an effort to stop arguing small points, and to make
>> observations and not argue.  I still get e-mail full of "crap" this
>> and "bullshit" that and "NACK!" with little explanation.
>
> As you said above, you've been part of the community for years. It is
> not as if you haven't learned by now that a review might turn up  
> issues
> that may give rise to a NACK, and that you need to be open to changing
> your code should this happen.

The tone of your vetoes is unnecessarily aggressive, and often the  
comments are entirely negative.  A mention of the pieces of new statd  
that you liked, for example, would have been welcome, and even useful  
for this conversation.

Naturally, you are free to disagree with me as much as you like.  But  
I wish you could be more constructive about it.  This is not a  
contest... we're supposed to be working together to improve the code  
base.

> If you need more information about what needs to be changed, then you
> know to ask.
>
> That hasn't been your approach in this case, though, and the responses
> you got were a direct consequence of that approach.
> You tried reversing the burden of proof as to why we should change an
> established interface instead of supplying adequate evidence  
> justifying
> that change.

I think it's reasonable to ask for evidence on both sides.

> When problems were pointed out to you (e.g. backward compatibility)  
> your
> response was to deny they existed instead of proposing a change to  
> your
> code.

The problem you described seemed to stem from a basic disagreement  
about how statd with IPv6 would be deployed -- an issue that neither  
of us (being upstream developers and not distributors) can resolve.   
Your objection still doesn't make sense to me.  But see below.

> Finally, you tried changing the thread into a discussion about mean  
> rude
> people obstructing you and failing to give you adequate guidance.

I was responding to Neil's comments, not changing the subject.

In any event, since all of the NFS maintainers have now passed their  
judgement, it's clear that I will have to withdraw new statd, and  
proceed with a re-write that uses the existing on-disk format.  I've  
never claimed that sqlite3 is a _requirement_ to solve these issues,  
but only that some changes would be necessary to the on-disk format,  
and that a database seemed an appropriate improvement.

No maintainers agree with that, so I will rework it.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




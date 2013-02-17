Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:18671 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752754Ab3BQT6a convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 17 Feb 2013 14:58:30 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Subject: Re: [PATCH RFC] nfsd: report length of the largest hash chain in reply cache stats
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20130217160056.GC11441@fieldses.org>
Date: Sun, 17 Feb 2013 14:58:19 -0500
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org
Message-Id: <79B64934-86E5-481F-B711-12D6E4C43BB2@oracle.com>
References: <20130215133406.20b1ef09@tlielax.poochiereds.net> <1360958672-5692-1-git-send-email-jlayton@redhat.com> <299C8DF9-5BFC-4E26-8F7E-CE3415D1140F@oracle.com> <20130215172058.29941a54@tlielax.poochiereds.net> <20130216133927.GA28824@fieldses.org> <BA5562CC-9236-4EC1-BC7A-341387B9F452@oracle.com> <20130217160056.GC11441@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 17, 2013, at 11:00 AM, J. Bruce Fields <bfields@fieldses.org> wrote:

> On Sat, Feb 16, 2013 at 12:18:18PM -0500, Chuck Lever wrote:
>> 
>> On Feb 16, 2013, at 8:39 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
>>> With a per-client maximum number of entries, sizing the hash tables
>>> should be easier.
>> When a server has only one client, should that client be allowed to
>> maximize the use of a server's resources (eg, use all of the DRC
>> resource the server has available)?
> 
> I've been assuming there's rapidly diminishing returns to caching a lot
> of replies to a single client.  But that might not be true--I guess a
> busy UDP client with a long retry timeout might benefit from a large
> cache?

I was thinking that the possible value of holding a reply diminishes the _longer_ you hold it.  The number of replies held depends then on how busy each client is, and of course, how much memory is available to hold cached replies.

Jeff's metrics may help us sort this out.

> 
>> How about when a server has one active client and multiple quiescent
>> clients?
> 
> I think there's a chance in that case that one of the quiescent clients
> is experiencing a temporary network problem, in which case we may want
> to preserve a few entries for them even if the active client's activity
> would normally evict them.

OK, sure.  So, we might express that as a lower bound on the number of replies cached per client?  Or would we express it as an upper bound on the age of each cached reply?

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com





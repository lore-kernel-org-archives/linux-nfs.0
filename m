From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 3/7] gssd: add support for callback authentication
Date: Mon, 18 May 2009 11:18:57 -0400
Message-ID: <4A117C61.9000504@RedHat.com>
References: <20090429214300.25811.81332.stgit@jazz.citi.umich.edu>	 <20090429215626.25811.13927.stgit@jazz.citi.umich.edu>	 <20090430212457.GA5700@fieldses.org> <4d569c330905061422t53d4a96as712678f2805c81ac@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Kevin Coffman <kwc@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:51812 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752072AbZERPV5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 May 2009 11:21:57 -0400
In-Reply-To: <4d569c330905061422t53d4a96as712678f2805c81ac-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since I'm just getting around to this now... just
replace this patch please....

tia,

steved

Kevin Coffman wrote:
> On Thu, Apr 30, 2009 at 5:24 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
>> On Wed, Apr 29, 2009 at 05:56:26PM -0400, Kevin Coffman wrote:
>>> From: Olga Kornievskaia <aglo@citi.umich.edu>
>>>
>>> Add support for handling upcalls on the new "nfsd4_cb" directory pipes.
>>> Only new kernels (2.6.29) have support for this new pipe directory.
>>> (The need for this new pipe directory will go away with NFSv4.1 where
>>> the callback can be done on the same connection as the fore-channel.)
>> My only complaint is that the code would be robust (and more
>> future-proof) if instead of specifically looking for "nfs" and
>> "nfsd4_cb", we just look at all top-level rpc_pipefs directories and
>> handed directories under any of them in the same way.
>>
>> --b.
> 
> In our offline discussion, Bruce convinced me that we should just
> treat all the directories under the rpc_pipefs directory as equal, and
> process any clnt directories that show up within them.  (This
> currently includes, "lockd  mount  nfs  nfsd4_cb  portmap  statd".)
> Any new directories appearing in the future will automatically get the
> same treatment.
> 
> Steve, I don't know what you might have already done with these
> patches.  Would you prefer a replacement for this patch, or patch on
> top of this?
> 
> K.C.

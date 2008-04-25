From: Jeff Layton <jlayton@redhat.com>
Subject: Re: The text-based mount interface doesn't support -s (--sloppy)
Date: Fri, 25 Apr 2008 11:03:19 -0400
Message-ID: <20080425110319.479a0e80@tupile.poochiereds.net>
References: <20080425081114.GA5148@uio.no>
	<DF3AF794-BD55-40E8-9696-BC6C40E82713@oracle.com>
	<20080425143543.GA6292@uio.no>
	<54BFCFD6-18D0-42E9-ADE9-867BEB1B2AB5@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "Steinar H. Gunderson" <sgunderson-jG/AHqQBv7lBDgjK7y7TUQ@public.gmane.org>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:39100 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751967AbYDYPFQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Apr 2008 11:05:16 -0400
In-Reply-To: <54BFCFD6-18D0-42E9-ADE9-867BEB1B2AB5@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 25 Apr 2008 10:50:09 -0400
Chuck Lever <chuck.lever@oracle.com> wrote:

> On Apr 25, 2008, at 10:35 AM, Steinar H. Gunderson wrote:
> > On Fri, Apr 25, 2008 at 10:30:35AM -0400, Chuck Lever wrote:
> >> It's not exactly clear what the "sloppy" option is supposed to allow.
> >> We are trying to figure out right now precisely how this should work.
> >
> > Well, in general it seems to ignore any new options that come into  
> > it. The
> > problem in question was -o grpid= that was coming in through autofs  
> > mounts and was not too easy to remove for the user.
> 
> The grpid mount option is what triggered our earlier discussion of -- 
> sloppy as well.
> 
> An expedient solution may be to tell the kernel mount option parser  
> specifically to ignore these common automounter options, like grpid.   
> Jeff, what do you think of that?
> 

That might reduce the pain for now...

I tend to think the big problem is people sharing autofs maps between
different OS's. It's hard to predict what options we might see that are
valid on another OS. We really need to define what the sloppy flag
means and how it behaves. It's a reasonably safe assumption that autofs
will use it, so hooking that up is probably the best solution.

Personally, I like the idea of just adding a "sloppy" mount option and
making "-s" add it to the string. When someone adds that option, the
kernel could just skip over options it doesn't recognize. When it's not
present, then it would fail on any unrecognized options.

This might mean that we need to have the kernel parser do more than one
pass over the string though. Once to look for the sloppy option, and
again to parse the others. This is not such a bad thing, IMO...there
are some other options that can get clobbered depending on order.

For instance, if retrans or timeo is parsed before "tcp" those options
can get overwritten. We may end up needing a multi-pass parser anyway...

-- 
Jeff Layton <jlayton@redhat.com>

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from linuxhacker.ru ([217.76.32.60]:44224 "EHLO fiona.linuxhacker.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751827AbcLFCXp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 5 Dec 2016 21:23:45 -0500
Subject: Re: Revalidate failure leads to unmount
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=us-ascii
From: Oleg Drokin <green@linuxhacker.ru>
In-Reply-To: <20161206020059.GL1555@ZenIV.linux.org.uk>
Date: Mon, 5 Dec 2016 21:22:47 -0500
Cc: "<linux-fsdevel@vger.kernel.org>" <linux-fsdevel@vger.kernel.org>,
        Trond Myklebust <trondmy@primarydata.com>,
        List Linux NFS Mailing <linux-nfs@vger.kernel.org>,
        "Eric W. Biederman" <ebiederm@xmission.com>
Message-Id: <02B48074-7E2E-4DB5-9A88-4FD4E37088FA@linuxhacker.ru>
References: <37A073FB-726E-4AF8-BC61-0DFBA6C51BD7@linuxhacker.ru> <CA893F6B-6EC3-477C-B20B-0E74CAFEA53C@linuxhacker.ru> <5B453EA9-676D-4240-BF2F-4827188962E4@linuxhacker.ru> <20161206020059.GL1555@ZenIV.linux.org.uk>
To: Al Viro <viro@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Dec 5, 2016, at 9:00 PM, Al Viro wrote:

> On Mon, Dec 05, 2016 at 08:39:15PM -0500, Oleg Drokin wrote:
>>>  Basically it all started with mountpoints randomly getting unmounted during
>>>  testing that I could not quite explain (see my quoted message at the end).
>>> 
>>>  Now I finally caught the culprit and it's lookup_dcache calling d_invalidate
>>>  that in turn detaches all mountpoints on the entire subtree like this:
> 
> Yes, it does.
> 
>>>  While I imagine the original idea was "cannot revalidate? Nuke the whole
>>>  tree from orbit", cases for "Why cannot we revalidate" were not considered.
> 
> What would you do instead?

Retry? Not always, of course, but if it was EINTR, why not?
Sure, it needs some more logic to actually propagate those codes, or perhaps
revalidate itself needs to be smarter not to fail for such cases?
Or is this something that you think should be wholly within filesystem
and as such in this case it's just an nfs bug?

>>>  So this brings up the question:
>>>  Is revalidate really required to go to great lengths to avoid returning 0
>>>  unless the underlying name has really-really changed? My reading
>>>  of documentation does not seem to match this as the whole LOOKUP_REVAL logic
>>>  is then redundant more or less?
> 
> LOOKUP_REVAL is about avoiding false _postives_ on revalidation - i.e. if
> you have several layers of actually stale entries in dcache and notice only
> when you try to do lookup in the last one, with server telling you to fuck
> off, your only hope is to apply full-strength revalidation from the very
> beginning.  Again, the problem it tries to avoid is over-optimistic fs
> assuming that directories are valid without asking the server.

Right, but in this case it's not server telling us off, not that we know at that
point.

>>>  Or is totally nuking the whole underlying tree a little bit over the top and
>>>  could be replaced with something less drastic, after all following re-lookup
>>>  could restore the dentries, but unmounts are not really reversible.
> 
> Like what?  Seriously, what would you do in such situation?  Leave the
> damn thing unreachable (and thus impossible to unmount)?  Suppose the
> /mnt/foo really had been removed (along with everything under it) on
> the server.  You had something mounted on /mnt/foo/bar/baz; what should
> the kernel do?

Well, if *I* ended up in this situation, I'd probably just recreate the missing
path and then then did umount (ESTALE galore?) ;)
(or course there are other less sane approaches like pinning the whole path until
unmount happens, but that's likely rife with a lot of other gotchas, but
there's a limited version of this already - if I have /mnt/foo mountpoint
and I delete /mnt/foo on the server, nobody would notice because we pin
the foo part already and all accesses go to the filesystem mounted on top).
But sure, when stuff is really missing, unmounting the subtrees looks like a very
sensible thing to do.
It's just I suspect revalidate for a network filesystem is more than just
"valid" and "invalid", there's a third option of "I don't know, ask me later"
(because the server is busy, down for a moment or whatever) and there's
at least some value in being able to interrupt a process that's stuck on a network
mountpoint without killing the whole thing under it, no?


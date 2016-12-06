Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:60310 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751570AbcLFCBB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Dec 2016 21:01:01 -0500
Date: Tue, 6 Dec 2016 02:00:59 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Oleg Drokin <green@linuxhacker.ru>
Cc: "<linux-fsdevel@vger.kernel.org>" <linux-fsdevel@vger.kernel.org>,
        Trond Myklebust <trondmy@primarydata.com>,
        List Linux NFS Mailing <linux-nfs@vger.kernel.org>,
        "Eric W. Biederman" <ebiederman@twitter.com>
Subject: Re: Revalidate failure leads to unmount
Message-ID: <20161206020059.GL1555@ZenIV.linux.org.uk>
References: <37A073FB-726E-4AF8-BC61-0DFBA6C51BD7@linuxhacker.ru>
 <CA893F6B-6EC3-477C-B20B-0E74CAFEA53C@linuxhacker.ru>
 <5B453EA9-676D-4240-BF2F-4827188962E4@linuxhacker.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5B453EA9-676D-4240-BF2F-4827188962E4@linuxhacker.ru>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 05, 2016 at 08:39:15PM -0500, Oleg Drokin wrote:
> >   Basically it all started with mountpoints randomly getting unmounted during
> >   testing that I could not quite explain (see my quoted message at the end).
> > 
> >   Now I finally caught the culprit and it's lookup_dcache calling d_invalidate
> >   that in turn detaches all mountpoints on the entire subtree like this:

Yes, it does.

> >   While I imagine the original idea was "cannot revalidate? Nuke the whole
> >   tree from orbit", cases for "Why cannot we revalidate" were not considered.

What would you do instead?

> >   So this brings up the question:
> >   Is revalidate really required to go to great lengths to avoid returning 0
> >   unless the underlying name has really-really changed? My reading
> >   of documentation does not seem to match this as the whole LOOKUP_REVAL logic
> >   is then redundant more or less?

LOOKUP_REVAL is about avoiding false _postives_ on revalidation - i.e. if
you have several layers of actually stale entries in dcache and notice only
when you try to do lookup in the last one, with server telling you to fuck
off, your only hope is to apply full-strength revalidation from the very
beginning.  Again, the problem it tries to avoid is over-optimistic fs
assuming that directories are valid without asking the server.

> >   Or is totally nuking the whole underlying tree a little bit over the top and
> >   could be replaced with something less drastic, after all following re-lookup
> >   could restore the dentries, but unmounts are not really reversible.

Like what?  Seriously, what would you do in such situation?  Leave the
damn thing unreachable (and thus impossible to unmount)?  Suppose the
/mnt/foo really had been removed (along with everything under it) on
the server.  You had something mounted on /mnt/foo/bar/baz; what should
the kernel do?

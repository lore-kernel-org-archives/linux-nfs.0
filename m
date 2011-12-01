Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp1.onthe.net.au ([203.22.196.249]:34412 "EHLO
	smtp1.onthe.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751958Ab1LAH3u (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Dec 2011 02:29:50 -0500
Date: Thu, 1 Dec 2011 18:29:47 +1100
From: Chris Dunlop <chris@onthe.net.au>
To: Tyler Hicks <tyhicks@canonical.com>
Cc: David Howells <dhowells@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        Eric Van Hensbergen <ericvh@gmail.com>,
        Ron Minnich <rminnich@sandia.gov>, Latchesar Ionkov <lucho@ionkov.net>,
        Jan Harkes <jaharkes@cs.cmu.edu>,
        "maintainer:CODA FILE SYSTEM" <coda@cs.cmu.edu>,
        Dave Kleikamp <shaggy@kernel.org>,
        Petr Vandrovec <petr@vandrovec.name>,
        Greg Kroah-Hartman <gregkh@suse.de>,
        v9fs-developer@lists.sourceforge.net, linux-afs@lists.infradead.org,
        codalist@TELEMANN.coda.cs.cmu.edu,
        jfs-discussion@lists.sourceforge.net, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/1] fix d_revalidate oopsen on NFS exports
Message-ID: <20111201072947.GA10329@onthe.net.au>
References: <20111130071319.GA16711@onthe.net.au>
 <1321861008-20611-1-git-send-email-chris@onthe.net.au>
 <20111129082501.GA569@onthe.net.au>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430C3CBC20@SACMVEXC2-PRD.hq.netapp.com>
 <24960.1322643283@redhat.com>
 <20111201004709.GA26085@onthe.net.au>
 <20111201063157.GA495@boyd>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20111201063157.GA495@boyd>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 01, 2011 at 12:31:58AM -0600, Tyler Hicks wrote:
> On 2011-12-01 11:47:09, Chris Dunlop wrote:
>> On Wed, Nov 30, 2011 at 08:54:43AM +0000, David Howells wrote:
>>> Chris Dunlop <chris@onthe.net.au> wrote:
>>> 
>>>> To avoid other people further wasting their and your time on
>>>> exactly the same thing future, how something like the following
>>>> patch, based on your comment in:
>>>> 
>>>> http://article.gmane.org/gmane.linux.nfs/40370
>>>> 
>>>> ...and, if that's acceptable, is it worthwhile doing for the
>>>> other file systems which are likewise currently vulnerable when
>>>> abused by broken layered file systems?
>>> 
>>> Also, this may get fixed by Al's atomic open patches - but obviously it hasn't
>>> been yet...
>>> 
>>>> Don't oops when abused by broken layered file systems
>>>> 
>>>> Signed-off-by: Chris Dunlop <chris@onthe.net.au>
>>> 
>>> Acked-by: David Howells <dhowells@redhat.com>
>>> 
>>> It's also worth printing a message - this *is* a kernel bug of some description
>>> if it happens.
>> 
>> Like the below?  This covers the d_revalidate for 9p, afs, coda,
>> hfs, ncpfs, proc, sysfs.
> 
> I don't like the looks of this patch. It makes sense for NFS to error
> out of d_revalidate() when passed a NULL nameidata pointer because NFS
> actually uses the nameidata to do something useful. That can't be said
> about the other filesystems in this patch.

I can see nd is used in nfs_open_revalidate(), but is it
necessarily used in nfs_lookup_revalidate()?  I'm way out of my
depth here, but everywhere it's used in nfs_lookup_revalidate()
(nfs_neg_need_reval(), nfs_is_exclusive_create(),
nfs_lookup_verify_inode()) there are also checks for nd != NULL.

> Why not handle the other filesystems like the previous fixes you
> referenced in your original email by checking for a non-NULL nd like
> this:
> 
> 	if (nd && nd->flags & LOOKUP_RCU)
> 		return -ECHILD;

'Cos Trond scared me into it!  ;-)

But mostly because I don't really know what I'm doing. The
original patch came about because I was tracking down the Oops
in the NFS code and it seemed such an obvious fix that
lookup_one_len() passes down a hard-coded NULL and that NULL
isn't checked in all the d_revalidate routines. I thought I'd do
the right thing and make sure it was checked everywhere. Little
did I know there's "history" behind it! I'm afraid I don't know
anywhere near enough to argue about the right way to deal with it.

> I'm also not sure about the printk in the NFS case. Instead of littering
> the logs, we should probably just disallow the stacked filesystem (are
> we talking about eCryptfs here?) from mounting on top of NFS in the
> first place.

See other reply: it wasn't a stacked file system.

But it seems useful to have the d_revalidate routines indicate
via the log that they're being abused.

Chris

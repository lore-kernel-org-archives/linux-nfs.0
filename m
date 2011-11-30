Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp1.onthe.net.au ([203.22.196.249]:41798 "EHLO
	smtp1.onthe.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751415Ab1K3HNZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Nov 2011 02:13:25 -0500
Date: Wed, 30 Nov 2011 18:13:19 +1100
From: Chris Dunlop <chris@onthe.net.au>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        Eric Van Hensbergen <ericvh@gmail.com>,
        Ron Minnich <rminnich@sandia.gov>, Latchesar Ionkov <lucho@ionkov.net>,
        David Howells <dhowells@redhat.com>, Jan Harkes <jaharkes@cs.cmu.edu>,
        "maintainer:CODA FILE SYSTEM" <coda@cs.cmu.edu>,
        Dave Kleikamp <shaggy@kernel.org>,
        Petr Vandrovec <petr@vandrovec.name>,
        Greg Kroah-Hartman <gregkh@suse.de>, Al Viro <viro@zeniv.linux.org.uk>,
        v9fs-developer@lists.sourceforge.net, linux-afs@lists.infradead.org,
        codalist@TELEMANN.coda.cs.cmu.edu,
        jfs-discussion@lists.sourceforge.net, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/1] fix d_revalidate oopsen on NFS exports
Message-ID: <20111130071319.GA16711@onthe.net.au>
References: <1321861008-20611-1-git-send-email-chris@onthe.net.au>
 <20111129082501.GA569@onthe.net.au>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430C3CBC20@SACMVEXC2-PRD.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430C3CBC20@SACMVEXC2-PRD.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 29, 2011 at 03:58:07AM -0800, Myklebust, Trond wrote:
>> -----Original Message-----
>> From: Chris Dunlop [mailto:chris@onthe.net.au]
>> Sent: Tuesday, November 29, 2011 3:25 AM
>> 
>> I haven't seen any response to this patch which fixes an Oops in
>> d_revalidate. I hit this using NFS, but various other file systems look to be
>> likewise vulnerable, hence the broadness of the patch. The sequence leading
>> to the Oops is:
>> 
>> lookup_one_len() [fs/namei.c]
>>    calls __lookup_hash() [fs/namei.c] with nd == NULL,
>>       which can then call the file system specific d_revalidate(), passing in nd == NULL
>>          which will then Oops if nd is used without checking
> 
> That's because you are "fixing" the wrong bug and if you'd checked the
> list archives, you'd know that this has already been discussed several
> times...

Augh! Apologies.

> By allowing stacked filesystems to pass nd==NULL (the VFS doesn't do
> this), you're circumventing  the lookup intent mechanisms and will hit
> all sorts of problems further down the road. If you want to fix the
> problem, then please fix the broken stacking filesystems to stop using
> lookup_one_len...

OK.

To avoid other people further wasting their and your time on
exactly the same thing future, how something like the following
patch, based on your comment in:

http://article.gmane.org/gmane.linux.nfs/40370

...and, if that's acceptable, is it worthwhile doing for the
other file systems which are likewise currently vulnerable when
abused by broken layered file systems?

Chris

----------------------------------------------------------------------
Don't oops when abused by broken layered file systems

Signed-off-by: Chris Dunlop <chris@onthe.net.au>
---
 fs/nfs/dir.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index b238d95..f872f29 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1103,6 +1103,12 @@ static int nfs_lookup_revalidate(struct dentry *dentry, struct nameidata *nd)
 	struct nfs_fattr *fattr = NULL;
 	int error;
 
+	/*
+	 * We don't support layered filesystems that don't do intents
+	 */
+	if (nd == NULL)
+		return -EIO;
+
 	if (nd->flags & LOOKUP_RCU)
 		return -ECHILD;
 
-- 
1.7.0.4
----------------------------------------------------------------------


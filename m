Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:36212 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752615AbbGWXrM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Jul 2015 19:47:12 -0400
Date: Fri, 24 Jul 2015 09:46:57 +1000
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Kinglong Mee <kinglongmee@gmail.com>, Al Viro <viro@zeniv.linux.org.uk>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: export table lookup: was [PATCH 10/10 v7] nfsd: Allows user
 un-mounting filesystem where nfsd exports base on
Message-ID: <20150724094657.0ca793b4@noble>
In-Reply-To: <20150722150840.GH22718@fieldses.org>
References: <55A11010.6050005@gmail.com>
	<55A111A8.2040701@gmail.com>
	<20150713133934.6a4ef77d@noble>
	<20150715210756.GE21669@fieldses.org>
	<20150716094046.445c038b@noble>
	<20150716205148.GC10673@fieldses.org>
	<20150722075824.3e7498ce@noble>
	<20150722150840.GH22718@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 22 Jul 2015 11:08:40 -0400 "J. Bruce Fields"
<bfields@fieldses.org> wrote:


> I've had this nagging todo to work out if there are other interesting
> consequences of the fact that the cache is internally keyed on one thing
> and appears to mountd to be keyed on another.  (And that there's a
> complicated many<->many relationship between those two things.)  But I
> haven't gotten to it.  Could be all unlikely corner cases, for all I
> know.

Even corner cases are worth resolving - and you got me interested now:-)

I think the distinction between pathnames and mnt+dentry is not quite
the important one.
I think mnt+dentry is the primary object - it is what a filehandle maps
to and what a pathname maps to.

The problem is that some mnt+dentry pairs do not have matching path
names.  If nfsd gets hold of one of these pairs, it shouldn't try
asking mountd about it because there is no way to ask the question, and
even if there was it isn't clear there is any way for mountd to answer.

If think that nfsd should assume that any such mountpoint is not
exported.

So something vaguely like:

diff --git a/fs/dcache.c b/fs/dcache.c
index 5c8ea15e73a5..a0651872ae8e 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -2943,6 +2943,12 @@ restart:
 		if (error)
 			break;
 
+		if (unlikely(d_mountpoint(dentry))) {
+			struct mount *mounted = __lookup_mnt(vfsmnt, dentry);
+			if (mounted)
+				prepend(&bptr, &blen, "//(unreachable)",15);
+		}
+
 		dentry = parent;
 	}
 	if (!(seq & 1))

Would mean that if I

# cd /tmp/a/b/c
# mount --bind /etc /tmp/a
# /bin/pwd

I get 

/tmp//(unreachable)/a/b/c

would could be checked for by nfsd to decide that there is no point asking user-space.
I'm not at all certain that this is a good interface (or that the code isn't racy) - it is just
a proof-of-concept.

We should probably place the (unreachable) at the front rather than in the middle.

Does that seem like a reasonable approach from your understanding of the problem?

Thanks,
NeilBrown










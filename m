Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:25072 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758527Ab2DYMEe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Apr 2012 08:04:34 -0400
Date: Wed, 25 Apr 2012 08:04:03 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: Peter Staubach <pstaubach@exagrid.com>, Steve Dickson <SteveD@redhat.com>,
        "linux-fsdevel\@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "viro\@ZenIV.linux.org.uk" <viro@ZenIV.linux.org.uk>,
        "hch\@infradead.org" <hch@infradead.org>,
        "michael.brantley\@deshaw.com" <michael.brantley@deshaw.com>,
        "sven.breuner\@itwm.fraunhofer.de" <sven.breuner@itwm.fraunhofer.de>,
        "chuck.lever\@oracle.com" <chuck.lever@oracle.com>,
        "malahal\@us.ibm.com" <malahal@us.ibm.com>,
        "bfields\@fieldses.org" <bfields@fieldses.org>,
        "trond.myklebust\@fys.uio.no" <trond.myklebust@fys.uio.no>,
        "rees\@umich.edu" <rees@umich.edu>
Subject: Re: [PATCH RFC v3] vfs: make fstatat retry once on ESTALE errors
 from getattr call
Message-ID: <20120425080403.2a17896c@tlielax.poochiereds.net>
In-Reply-To: <87bomgkv1b.fsf@tucsk.pomaz.szeredi.hu>
References: <1334316311-22331-1-git-send-email-jlayton@redhat.com>
	<1334749927-26138-1-git-send-email-jlayton@redhat.com>
	<20120420104055.511e15bc@tlielax.poochiereds.net>
	<4F91C49D.8070908@RedHat.com>
	<20120420171300.326d6e36@corrin.poochiereds.net>
	<4F956D5C.5050801@RedHat.com>
	<20120423113216.01992555@tlielax.poochiereds.net>
	<4F959A36.2080402@RedHat.com>
	<FA8A9A935BFD3A4D8F0CDA1C4F611BCC063CF8E64B@IT-1874.Isys.com>
	<20120424105049.5ed96b40@tlielax.poochiereds.net>
	<87lillktv3.fsf@tucsk.pomaz.szeredi.hu>
	<20120424123413.17625d5d@tlielax.poochiereds.net>
	<87bomgkv1b.fsf@tucsk.pomaz.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 25 Apr 2012 11:41:52 +0200
Miklos Szeredi <miklos@szeredi.hu> wrote:

> Jeff Layton <jlayton@redhat.com> writes:
> 
> >> And an audit would still not ensure safety against future additions of
> >> ESTALE.
> >> 
> >
> > Well, nothing is safe from the future. It's incumbent upon us to review
> > patches and such before such breakage goes in.
> 
> Good interfaces are safe against stupidity, and that very much applies
> to the kernel too.  Review is not an excuse for bad interfaces.
> 

Exactly. The current behavior/interface is that we return ESTALE to
userspace, even when we have a pathname and can retry. That's a bad
interface that certainly isn't helpful to users.

ESTALE has a specific meaning -- stale NFS filehandle. If we expand
that definition a bit, then we can rephrase that to mean that the
results of the lookup now point to something that doesn't exist.

If FUSE or other filesystems are using ESTALE to mean something else,
then they're not returning the right error code. Is there something
documented in FUSE that told them to expect some specific behavior from
an ESTALE return?

> > But, let's say for the purposes of argument that we do have a fs (FUSE
> > or otherwise) that is persistently returning ESTALE on a lookup. Why
> > was Peter's check that we were making forward progress not enough to
> > guard against this problem?
> >
> > In particular, I'm talking about the code he added to link_path_walk in
> > this patch to check that the value of nd->path.dentry was changing:
> >
> >     https://lkml.org/lkml/2008/3/10/266
> >
> > It seems like that ought to be enough to alleviate your fears on this.
> > We could also check for fatal signals on each pass and that would allow
> > users to break out of the loop even when the underlying fs doesn't
> > handle signals properly.
> 
> AFAICS that doesn't ensure progress, only change.  It helps those cases
> which persistently return ESTALE, but not cases where there is change
> but no progress.  E.g. it doesn't prevent DoS by a client doing renames
> over a directory in a tight loop.
> 

Retrying indefinitely in that situation is sort of the point. What you
consider to be a DoS here could also be a completely valid use-case in
other situations. At least in the case of NFS, we have to expect "nice"
behavior out of the server. There are plenty of ways that the server
or another client can screw things up for you...

In any case, I think we can also minimize the impact on the system in
the event that we do have DoS. We can allow the user to break out of
the loop with a fatal signal. I also think we should take Chuck's
advice from earlier and add a backoff delay between retries to minimize
the impact while looping.

Here's sort of what I'm thinking. I'm still in the process of testing
this approach to make sure it does the right thing, so consider this
another RFC:

-------------------------------------------------------------------------------
vfs-add-an-retry_lookup-functi
-------------------------------------------------------------------------------
vfs: add an retry_estale function to handle retries on ESTALE

From: Jeff Layton <jlayton@redhat.com>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---

 fs/namei.c         |   32 ++++++++++++++++++++++++++++++++
 include/linux/fs.h |    2 ++
 2 files changed, 34 insertions(+), 0 deletions(-)


diff --git a/fs/namei.c b/fs/namei.c
index 0062dd1..0555819 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -116,6 +116,38 @@
  * POSIX.1 2.4: an empty pathname is invalid (ENOENT).
  * PATH_MAX includes the nul terminator --RR.
  */
+
+/**
+ * retry_estale - determine whether the caller should retry an operation
+ *
+ * @error: the error we'll be returning
+ * @try: number of retries already performed
+ *
+ * See if the error code is -ESTALE. If so, then calculate the amount of
+ * delay that we want based on the number of tries already done, and go into
+ * TASK_KILLABLE sleep for that long.
+ *
+ * Returns true if the caller should try again, false if not.
+ */
+bool
+retry_estale(const long error, const unsigned int try)
+{
+	long timeout;
+
+	if (likely(error != -ESTALE))
+		return false;
+
+	/* don't try to schedule if the timeout will be 0 */
+	if (try == 0)
+		return true;
+
+	/* arbitrarily cap backoff delay at 1s */
+	timeout = try * 2;
+	timeout = timeout > HZ ? HZ : timeout;
+
+	return !schedule_timeout_killable(timeout);
+}
+
 static int do_getname(const char __user *filename, char *page)
 {
 	int retval;
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 8de6755..c9b6684 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2026,6 +2026,8 @@ extern struct file * dentry_open(struct dentry *, struct vfsmount *, int,
 extern int filp_close(struct file *, fl_owner_t id);
 extern char * getname(const char __user *);
 
+extern bool retry_estale(const long error, const unsigned int retry);
+
 /* fs/ioctl.c */
 
 extern int ioctl_preallocate(struct file *filp, void __user *argp);
-------------------------------------------------------------------------------
vfs-retry-lookups-indefinitely
-------------------------------------------------------------------------------
vfs: retry lookups indefinitely on an ESTALE error

From: Jeff Layton <jlayton@redhat.com>

...but at the same time, attempt to ensure that we're making forward
progress by ensuring that the nd->path.dentry pointer is changing on
each attempt. If it isn't then give up and return -ENOENT instead.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---

 fs/namei.c |   39 ++++++++++++++++++++++++++++++++++++---
 1 files changed, 36 insertions(+), 3 deletions(-)


diff --git a/fs/namei.c b/fs/namei.c
index 0555819..57822a7 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -1805,11 +1805,22 @@ static int path_lookupat(int dfd, const char *name,
 static int do_path_lookup(int dfd, const char *name,
 				unsigned int flags, struct nameidata *nd)
 {
+	unsigned int try = 0;
+	struct dentry *saved = NULL;
 	int retval = path_lookupat(dfd, name, flags | LOOKUP_RCU, nd);
 	if (unlikely(retval == -ECHILD))
 		retval = path_lookupat(dfd, name, flags, nd);
-	if (unlikely(retval == -ESTALE))
+	while (unlikely(retry_estale(retval, try++))) {
+		/*
+		 * Note that the dentry pointers may be bogus by now. We do
+		 * not attempt to dereference them, but simply use them to
+		 * ensure that we're making progress on the lookup attempt.
+		 */
+		if (saved == nd->path.dentry)
+			break;
+		saved = nd->path.dentry;
 		retval = path_lookupat(dfd, name, flags | LOOKUP_REVAL, nd);
+	}
 
 	if (likely(!retval)) {
 		if (unlikely(!audit_dummy_context())) {
@@ -2459,20 +2470,33 @@ out_filp:
 struct file *do_filp_open(int dfd, const char *pathname,
 		const struct open_flags *op, int flags)
 {
+	unsigned int try = 0;
+	struct dentry *saved = NULL;
 	struct nameidata nd;
 	struct file *filp;
 
 	filp = path_openat(dfd, pathname, &nd, op, flags | LOOKUP_RCU);
 	if (unlikely(filp == ERR_PTR(-ECHILD)))
 		filp = path_openat(dfd, pathname, &nd, op, flags);
-	if (unlikely(filp == ERR_PTR(-ESTALE)))
+	while (unlikely(retry_estale(PTR_ERR(filp), try++))) {
+		/*
+		 * Note that the dentry pointers may be bogus by now. We do
+		 * not attempt to dereference them, but simply use them to
+		 * ensure that we're making progress on the lookup attempt.
+		 */
+		if (saved == nd.path.dentry)
+			break;
+		saved = nd.path.dentry;
 		filp = path_openat(dfd, pathname, &nd, op, flags | LOOKUP_REVAL);
+	}
 	return filp;
 }
 
 struct file *do_file_open_root(struct dentry *dentry, struct vfsmount *mnt,
 		const char *name, const struct open_flags *op, int flags)
 {
+	unsigned int try = 0;
+	struct dentry *saved = NULL;
 	struct nameidata nd;
 	struct file *file;
 
@@ -2487,8 +2511,17 @@ struct file *do_file_open_root(struct dentry *dentry, struct vfsmount *mnt,
 	file = path_openat(-1, name, &nd, op, flags | LOOKUP_RCU);
 	if (unlikely(file == ERR_PTR(-ECHILD)))
 		file = path_openat(-1, name, &nd, op, flags);
-	if (unlikely(file == ERR_PTR(-ESTALE)))
+	while (unlikely(retry_estale(PTR_ERR(file), try++))) {
+		/*
+		 * Note that the dentry pointers may be bogus by now. We do
+		 * not attempt to dereference them, but simply use them to
+		 * ensure that we're making progress on the lookup attempt.
+		 */
+		if (saved == nd.path.dentry)
+			break;
+		saved = nd.path.dentry;
 		file = path_openat(-1, name, &nd, op, flags | LOOKUP_REVAL);
+	}
 	return file;
 }
 

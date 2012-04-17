Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f42.google.com ([74.125.82.42]:35876 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755983Ab2DQPtz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Apr 2012 11:49:55 -0400
Received: by wgbds11 with SMTP id ds11so728454wgb.1
        for <linux-nfs@vger.kernel.org>; Tue, 17 Apr 2012 08:49:54 -0700 (PDT)
From: Miklos Szeredi <miklos@szeredi.hu>
To: Jeff Layton <jlayton@redhat.com>
Cc: Steve Dickson <SteveD@redhat.com>,
        "Myklebust\, Trond" <Trond.Myklebust@netapp.com>,
        Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>,
        Malahal Naineni <malahal@us.ibm.com>,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel\@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "pstaubach\@exagrid.com" <pstaubach@exagrid.com>,
        "viro\@ZenIV.linux.org.uk" <viro@ZenIV.linux.org.uk>,
        "hch\@infradead.org" <hch@infradead.org>,
        "michael.brantley\@deshaw.com" <michael.brantley@deshaw.com>,
        "sven.breuner\@itwm.fraunhofer.de" <sven.breuner@itwm.fraunhofer.de>
Subject: Re: [PATCH RFC] vfs: make fstatat retry on ESTALE errors from getattr call
References: <1334316311-22331-1-git-send-email-jlayton@redhat.com>
	<20120413150518.GA1987@us.ibm.com>
	<20120413114236.0e557e01@tlielax.poochiereds.net>
	<4F8B1B7B.3040304@itwm.fraunhofer.de>
	<20120416073655.7cdb90cf@corrin.poochiereds.net>
	<4F8C3036.2030702@itwm.fraunhofer.de>
	<20120416134642.1754cd3e@corrin.poochiereds.net>
	<1334604785.2879.23.camel@lade.trondhjem.org>
	<20120416154322.0d95e435@corrin.poochiereds.net>
	<1334607906.2879.36.camel@lade.trondhjem.org>
	<20120416190548.2463d1d0@corrin.poochiereds.net>
	<4F8D580B.7060104@RedHat.com>
	<20120417093643.7f172057@corrin.poochiereds.net>
	<4F8D7ADF.9030709@RedHat.com> <87k41eo2m3.fsf@tucsk.pomaz.szeredi.hu>
	<20120417110219.0db9bdee@corrin.poochiereds.net>
Date: Tue, 17 Apr 2012 17:50:06 +0200
In-Reply-To: <20120417110219.0db9bdee@corrin.poochiereds.net> (Jeff Layton's
	message of "Tue, 17 Apr 2012 11:02:19 -0400")
Message-ID: <87aa2anys1.fsf@tucsk.pomaz.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jeff Layton <jlayton@redhat.com> writes:

> On Tue, 17 Apr 2012 16:27:16 +0200
> Miklos Szeredi <miklos@szeredi.hu> wrote:
>
>> Steve Dickson <SteveD@redhat.com> writes:
>> 
>> > True, but even so... Giving file systems an opt-out option with the 
>> > default being out, maybe still have some merit... Making file systems
>> > enable this new type of functionality would cut down on any of the
>> > "surprise" that might occur with this redo ;-) 
>> 
>> I've been arguing for something slightly different for quite some time:
>> I never liked errno values which have side effects in the kernel yet
>> might be visible to userspace.
>> 
>> So why not introduce ERETRYSTALE, a *kernel internal* errno value that
>> userspace will never see and filesystems never accidentally set.  The
>> VFS can turn this into ESTALE if it doesn't retry for some reason
>> (e.g. already retried).
>> 
>
> That's possible but it's certainly a lot more invasive. It's also far
> more difficult for filesystems to opt-in to this sort of behavior.

As a first step all that is needed to opt in is to convert -ESTALE to
-ESTALERETRY on those operations that allow retrying.  Which is lookup,
at the moment.

If we decide to make more ops retryable (I'm not convinced that's the
best approach, but it might be) then those can be converted without too
much pain.

Thanks,
Miklos


diff --git a/fs/namei.c b/fs/namei.c
index 0062dd1..66b7d06 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -1776,9 +1776,14 @@ static int do_path_lookup(int dfd, const char *name,
 	int retval = path_lookupat(dfd, name, flags | LOOKUP_RCU, nd);
 	if (unlikely(retval == -ECHILD))
 		retval = path_lookupat(dfd, name, flags, nd);
-	if (unlikely(retval == -ESTALE))
+	if (unlikely(retval == -ERETRYLOOKUP)) {
 		retval = path_lookupat(dfd, name, flags | LOOKUP_REVAL, nd);
 
+		/* retry only once */
+		if (retval == -ERETRYLOOKUP)
+			retval = -ESTALE;
+	}
+
 	if (likely(!retval)) {
 		if (unlikely(!audit_dummy_context())) {
 			if (nd->path.dentry && nd->inode)
@@ -2433,8 +2438,12 @@ struct file *do_filp_open(int dfd, const char *pathname,
 	filp = path_openat(dfd, pathname, &nd, op, flags | LOOKUP_RCU);
 	if (unlikely(filp == ERR_PTR(-ECHILD)))
 		filp = path_openat(dfd, pathname, &nd, op, flags);
-	if (unlikely(filp == ERR_PTR(-ESTALE)))
+	if (unlikely(filp == ERR_PTR(-ERETRYLOOKUP))) {
 		filp = path_openat(dfd, pathname, &nd, op, flags | LOOKUP_REVAL);
+		if (filp == ERR_PTR(-ERETRYLOOKUP))
+			filp = ERR_PTR(-ESTALE);
+	}
+
 	return filp;
 }
 
@@ -2455,8 +2464,11 @@ struct file *do_file_open_root(struct dentry *dentry, struct vfsmount *mnt,
 	file = path_openat(-1, name, &nd, op, flags | LOOKUP_RCU);
 	if (unlikely(file == ERR_PTR(-ECHILD)))
 		file = path_openat(-1, name, &nd, op, flags);
-	if (unlikely(file == ERR_PTR(-ESTALE)))
+	if (unlikely(file == ERR_PTR(-ESTALE))) {
 		file = path_openat(-1, name, &nd, op, flags | LOOKUP_REVAL);
+		if (file == ERR_PTR(-ERETRYLOOKUP))
+			file = ERR_PTR(-ESTALE);
+	}
 	return file;
 }
 
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 4aaf031..cd35da3 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1303,6 +1303,8 @@ static struct dentry *nfs_lookup(struct inode *dir, struct dentry * dentry, stru
 	if (error == -ENOENT)
 		goto no_entry;
 	if (error < 0) {
+		if (error == -ESTALE)
+			error = -ERETRYLOOKUP;
 		res = ERR_PTR(error);
 		goto out_unblock_sillyrename;
 	}
diff --git a/include/linux/errno.h b/include/linux/errno.h
index 2d09bfa..cfaedb8 100644
--- a/include/linux/errno.h
+++ b/include/linux/errno.h
@@ -17,6 +17,7 @@
 #define ENOIOCTLCMD	515	/* No ioctl command */
 #define ERESTART_RESTARTBLOCK 516 /* restart by calling sys_restart_syscall */
 #define EPROBE_DEFER	517	/* Driver requests probe retry */
+#define ERETRYLOOKUP	519	/* Retry lookup */
 
 /* Defined for the NFSv3 protocol */
 #define EBADHANDLE	521	/* Illegal NFS file handle */




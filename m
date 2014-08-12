Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f50.google.com ([209.85.192.50]:63653 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753505AbaHLTD3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Aug 2014 15:03:29 -0400
Received: by mail-qg0-f50.google.com with SMTP id q108so9770328qgd.23
        for <linux-nfs@vger.kernel.org>; Tue, 12 Aug 2014 12:03:27 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Tue, 12 Aug 2014 15:03:26 -0400
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, Anna.Schumaker@netapp.com
Subject: Re: [PATCH] nfsd: mark CONFIG_NFSD_FAULT_INJECTION as deprecated
Message-ID: <20140812150326.6d738022@tlielax.poochiereds.net>
In-Reply-To: <20140812184849.GA25914@fieldses.org>
References: <1407351771-11435-1-git-send-email-jlayton@primarydata.com>
	<20140812184849.GA25914@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 12 Aug 2014 14:48:49 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Wed, Aug 06, 2014 at 03:02:51PM -0400, Jeff Layton wrote:
> > The fault injection code is shaky at best. If you have a lot of stateful
> > objects, then you can end up overflowing the client's refcount. The code
> > is not widely used and is starting to become a maintenance burden mark
> > it DEPRECATED and document that we'll remove it in v3.19.
> 
> I doubt anyone will notice a config text change on upgrade.
> 
> If we think a deprecation warning's necessary then it would be more
> useful to put it in a printk() that fires the first time somebody uses
> one of these.
> 
> --b.
> 
> > 
> > Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> > ---
> >  fs/nfsd/Kconfig | 5 ++++-
> >  1 file changed, 4 insertions(+), 1 deletion(-)
> > 
> > diff --git a/fs/nfsd/Kconfig b/fs/nfsd/Kconfig
> > index f994e750e0d1..aad734c0b48a 100644
> > --- a/fs/nfsd/Kconfig
> > +++ b/fs/nfsd/Kconfig
> > @@ -98,11 +98,14 @@ config NFSD_V4_SECURITY_LABEL
> >  	For now we recommend "Y" only for developers and testers.
> >  
> >  config NFSD_FAULT_INJECTION
> > -	bool "NFS server manual fault injection"
> > +	bool "NFS server manual fault injection (DEPRECATED)"
> >  	depends on NFSD_V4 && DEBUG_KERNEL
> >  	help
> >  	  This option enables support for manually injecting faults
> >  	  into the NFS server.  This is intended to be used for
> >  	  testing error recovery on the NFS client.
> >  
> > +	  This feature should not be enabled on production systems
> > +	  and will be removed in v3.19.
> > +
> >  	  If unsure, say N.
> > -- 
> > 1.9.3
> > 

Good point. Maybe something like this patch then? The printk is a
little sparse, but I'm not sure what else we should say there...

-----------------------[snip]--------------------------

[PATCH] nfsd: mark CONFIG_NFSD_FAULT_INJECTION as deprecated

The fault injection code is shaky at best. If you have a lot of stateful
objects, then you can end up overflowing the client's refcount. The code
is not widely used and is starting to become a maintenance burden. Mark
it DEPRECATED and document that we'll remove it in v3.19.

Also add a printk that will fire once whenever someone tries to use this
facility.

Cc: Anna Schumaker <Anna.Schumaker@netapp.com>
Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/Kconfig        |  5 ++++-
 fs/nfsd/fault_inject.c | 16 ++++++++++++++++
 2 files changed, 20 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/Kconfig b/fs/nfsd/Kconfig
index f994e750e0d1..aad734c0b48a 100644
--- a/fs/nfsd/Kconfig
+++ b/fs/nfsd/Kconfig
@@ -98,11 +98,14 @@ config NFSD_V4_SECURITY_LABEL
 	For now we recommend "Y" only for developers and testers.
 
 config NFSD_FAULT_INJECTION
-	bool "NFS server manual fault injection"
+	bool "NFS server manual fault injection (DEPRECATED)"
 	depends on NFSD_V4 && DEBUG_KERNEL
 	help
 	  This option enables support for manually injecting faults
 	  into the NFS server.  This is intended to be used for
 	  testing error recovery on the NFS client.
 
+	  This feature should not be enabled on production systems
+	  and will be removed in v3.19.
+
 	  If unsure, say N.
diff --git a/fs/nfsd/fault_inject.c b/fs/nfsd/fault_inject.c
index c16bf5af6831..91874de13ae4 100644
--- a/fs/nfsd/fault_inject.c
+++ b/fs/nfsd/fault_inject.c
@@ -24,6 +24,18 @@ struct nfsd_fault_inject_op {
 
 static struct dentry *debug_dir;
 
+static void
+warn_deprecated(void)
+{
+	static bool warned = false;
+
+	if (!warned) {
+		pr_notice("nfsd: the NFSD fault injection framework is "
+			  "scheduled for removal in v3.19.\n");
+		warned = true;
+	}
+}
+
 static ssize_t fault_inject_read(struct file *file, char __user *buf,
 				 size_t len, loff_t *ppos)
 {
@@ -33,6 +45,8 @@ static ssize_t fault_inject_read(struct file *file, char __user *buf,
 	loff_t pos = *ppos;
 	struct nfsd_fault_inject_op *op = file_inode(file)->i_private;
 
+	warn_deprecated();
+
 	if (!pos)
 		val = op->get();
 	size = scnprintf(read_buf, sizeof(read_buf), "%llu\n", val);
@@ -51,6 +65,8 @@ static ssize_t fault_inject_write(struct file *file, const char __user *buf,
 	u64 val;
 	char *nl;
 
+	warn_deprecated();
+
 	if (copy_from_user(write_buf, buf, size))
 		return -EFAULT;
 	write_buf[size] = '\0';
-- 
1.9.3


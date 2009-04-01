From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 12995] New: NFS mount from avr32 platform
 crashes on 2.6.29
Date: Wed, 1 Apr 2009 13:07:26 -0700
Message-ID: <20090401130726.8a305e43.akpm@linux-foundation.org>
References: <bug-12995-10286@http.bugzilla.kernel.org/>
	<20090401124113.9026ea09.akpm@linux-foundation.org>
	<AD89F6AE-DD50-4D8E-9C94-A403E9AFFC8C@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: brm-EoLPgbz1DBzQT0dZR+AlfA@public.gmane.org, bugme-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org, okir@suse.de,
	linux-nfs@vger.kernel.org, stable@kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:37200 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755411AbZDAUMl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Apr 2009 16:12:41 -0400
In-Reply-To: <AD89F6AE-DD50-4D8E-9C94-A403E9AFFC8C@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

(cc stable)

On Wed, 1 Apr 2009 15:50:51 -0400
Chuck Lever <chuck.lever@oracle.com> wrote:

> >>
> >> Perhaps the solution is to malloc the nsm_private data and sm_priv  
> >> is then a
> >> pointer to this data. This would guarantee the correct alignment.
> >>
> >
> > nsm_private is:
> >
> > struct nsm_private {
> > 	unsigned char		data[SM_PRIV_SIZE];
> > };
> >
> > so the compiler is permitted to byte-align this.
> >
> > I assume that some code somewhere is accessing this with a
> > larger-than-one-byte typecast?
> 
> nsm_init_private().
> 
> A patch just went upstream for 2.6.30 that addresses that

commit ad5b365c1266b0c9e8e254a3c1cc4ef66bf33cba
Author:     Mans Rullgard <mans-2StjZFpD7GcAvxtiuMwx3w@public.gmane.org>
AuthorDate: Sat Mar 28 19:55:20 2009 +0000
Commit:     Trond Myklebust <Trond.Myklebust@netapp.com>
CommitDate: Wed Apr 1 13:24:14 2009 -0400

    NSM: Fix unaligned accesses in nsm_init_private()
    
    This fixes unaligned accesses in nsm_init_private() when
    creating nlm_reboot keys.
    
    Signed-off-by: Mans Rullgard <mans-2StjZFpD7GcAvxtiuMwx3w@public.gmane.org>
    Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 5e2c4d5..6d5d4a4 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -16,6 +16,8 @@
 #include <linux/sunrpc/svc.h>
 #include <linux/lockd/lockd.h>
 
+#include <asm/unaligned.h>
+
 #define NLMDBG_FACILITY		NLMDBG_MONITOR
 #define NSM_PROGRAM		100024
 #define NSM_VERSION		1
@@ -274,10 +276,12 @@ static void nsm_init_private(struct nsm_handle *nsm)
 {
 	u64 *p = (u64 *)&nsm->sm_priv.data;
 	struct timespec ts;
+	s64 ns;
 
 	ktime_get_ts(&ts);
-	*p++ = timespec_to_ns(&ts);
-	*p = (unsigned long)nsm;
+	ns = timespec_to_ns(&ts);
+	put_unaligned(ns, p);
+	put_unaligned((unsigned long)nsm, p + 1);
 }
 
 static struct nsm_handle *nsm_create_handle(const struct sockaddr *sap,

Is this the best way of fixing it?  We'll crash again if some other
code starts to access .data with non-byte-sized accesses.  What makes
this especially risky is that the code will pass testing on x86.

__aligned would be one way.  But it would be far far cleaner to just do


--- a/include/linux/lockd/xdr.h~a
+++ a/include/linux/lockd/xdr.h
@@ -17,7 +17,7 @@
 #define SM_PRIV_SIZE		16
 
 struct nsm_private {
-	unsigned char		data[SM_PRIV_SIZE];
+	u64 data[SM_PRIV_SIZE/sizeof(u64)];
 };
 
 struct svc_rqst;

all the typecasting and the put_unaligned()s just go away then.

> but did not mention that it fixed an oops.

That was a fairly significant failing.  Guys, please please do remember
that we're also maintaining the stable kernels.  When merging a patch
please always think whether it needs to be backported.


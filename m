From: Luoqi Chen <Luoqi.Chen@brion.com>
Subject: RE: NFS open/setuid/ftruncate problem
Date: Tue, 10 Jun 2008 22:24:49 -0700
Message-ID: <0707E37B6D2E244C85660487B602C9221D9D9883@ex02.briontech.com>
References: <0707E37B6D2E244C85660487B602C9221D9D9846@ex02.briontech.com>
 <1213141630.20459.113.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754422AbYFKFZO@vger.kernel.org>
In-Reply-To: <1213141630.20459.113.camel@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date: Tue, 10 Jun 2008 19:39:41 -0400
> NFS: Fix the ftruncate() credential problem
>
> ftruncate() access checking is supposed to be performed at
> open() time,
> just like reads and writes.
>
Thanks, Trond. Is there any chance this patch could be
included in the linux kernel in the near future? For now,
I guess I'll workaround this problem by moving the ftruncate()
to before setuid().

-luoqi

PS: I haven't tried the patch, just browsing through, and I noticed
a typo, pointing out here to save some trouble for anyone who
wants to give it a try (I guess gcc would issue a warning too),

        /* Search for an existing open(O_WRITE) file */
-       ctx = nfs_find_open_context(inode, cred, FMODE_WRITE);
-       if (ctx != NULL)
-               state = ctx->state;
+       if (sattr->ia_valid && ATTR_FILE) {  <=== && should be &
+               ctx = nfs_file_open_context(sattr->ia_file);
+               if (ctx != NULL)
+                       state = ctx->state;
+       }

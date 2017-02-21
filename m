Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f45.google.com ([209.85.214.45]:36347 "EHLO
        mail-it0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752443AbdBUVnb (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Feb 2017 16:43:31 -0500
Received: by mail-it0-f45.google.com with SMTP id h10so119329360ith.1
        for <linux-nfs@vger.kernel.org>; Tue, 21 Feb 2017 13:43:31 -0800 (PST)
MIME-Version: 1.0
From: Olga Kornievskaia <aglo@umich.edu>
Date: Tue, 21 Feb 2017 16:43:29 -0500
Message-ID: <CAN-5tyGWFYp-dU=8Prpmyyr=B=Z3jAfiO_qs0-KfC_xvDwUMaA@mail.gmail.com>
Subject: changing error message for mount failure
To: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In the upstream kernel when doing the mount without specifying the
security flavor and the server returning EACCES to the
PUTROOTFH|GETATTR, the code ends up translating this to EPERM which
mount fails with "Operation not permitted". Doing the same mount, but
specifying "sec=sys" on the command line translates to the "Access
denied" error. While not too terrible, it's just a bit inconsistent.

Anna pointed me to this discussion
https://lists.gt.net/linux/kernel/1366207#1366207 that was possibly
the reason for the translation of EACCES to EPERM in
nfs4_find_root_sec().

Is this still a needed correction? I tried: no gssd running and asking
for a krb5 mount and it leads to "an incorrect mount option was
specified" (EINVAL returned by nfs).

I propose to remove it to address the difference in error messages for EACCES:
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index d293f06..a03f587 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3576,15 +3576,6 @@ static int nfs4_find_root_sec(struct nfs_server
*server, struct nfs_fh *fhandle,
  }
  }

- /*
- * -EACCESS could mean that the user doesn't have correct permissions
- * to access the mount.  It could also mean that we tried to mount
- * with a gss auth flavor, but rpc.gssd isn't running.  Either way,
- * existing mount programs don't handle -EACCES very well so it should
- * be mapped to -EPERM instead.
- */
- if (status == -EACCES)
- status = -EPERM;
  return status;
 }

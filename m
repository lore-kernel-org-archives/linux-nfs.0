From: Shahar Klein <shaharklein@yahoo.com>
Subject: kernel BUG at fs/nfs/namespace.c:108!
Date: Sun, 3 Aug 2008 03:07:53 -0700 (PDT)
Message-ID: <72924.9082.qm@web39205.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from web39205.mail.mud.yahoo.com ([209.191.87.242]:31229 "HELO
	web39205.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752647AbYHCKHy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 3 Aug 2008 06:07:54 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi  All

I came across this panic due to bad server and I am wondering
why should an nfs client panic when stumbling upon an IS_ROOT dentry
in the point where it tries to cross mount. I mean: should an 'Innocent' client
'pay' for bad server behavior?

Is it unsafe to just clear the path and return error?


--- a/namespace.c       2008-08-03 12:29:21.000000000 +0300
+++ b/namespace.c       2008-08-03 12:30:54.000000000 +0300
@@ -100,7 +100,11 @@

        dprintk("--> nfs_follow_mountpoint()\n");
  
-       BUG_ON(IS_ROOT(dentry));
+       if (IS_ROOT(dentry)) {
+                 err = -EBUSY; // or any reasonable error
+                 goto out_err;
+                                                                                
+       }
        dprintk("%s: enter\n", __FUNCTION__);
        dput(nd->dentry);
        nd->dentry = dget(dentry);



      

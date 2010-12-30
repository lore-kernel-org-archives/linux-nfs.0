Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:55016 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751207Ab0L3EIe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Dec 2010 23:08:34 -0500
Message-ID: <4D1C06E7.5060009@cn.fujitsu.com>
Date: Thu, 30 Dec 2010 12:13:27 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/3] nfsd4: implement secinfo_no_name
References: <1292612511-14203-1-git-send-email-bfields@redhat.com> <1292612511-14203-4-git-send-email-bfields@redhat.com> <4D183265.70608@cn.fujitsu.com> <20101229185609.GA12218@fieldses.org>
In-Reply-To: <20101229185609.GA12218@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



J. Bruce Fields:
> On Mon, Dec 27, 2010 at 02:29:57PM +0800, Mi Jinlong wrote:
>> When testing this patch, oops appears.
>>
>> We should implement a nfsd4_encode_secinfo_no_name() instead using 
>> nfsd4_encode_secinfo(). 
>>
>> With the following patch, kernel will run correctly.
> 
> Whoops, yes, you're correct.  I've applied your patch.  Thanks!
> 
> (What are you using for testing?)

Hi Bruce:

  I test it by the pynfs41 at your tree, and add some simple
  test case as following.

  I have a question about the op.secinfo_no_name(), should it take 
  a argument? 
  Right now, maybe it always request with NFS4_SECINFO_STYLE4_CURRENT_FH,
  or I can't find how to set the argument.

thanks,
Mi Jinlong  

>From 31ae25c04295888fa54ea531cdfaa4cfdefbe877 Mon Sep 17 00:00:00 2001
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
Date: Wed, 29 Dec 2010 17:23:35 +0800
Subject: [PATCH] CLNT: Add some simple secinfo_no_name tests

 Add two simple secinfo_no_name tests as Bruce said:
    - send PUTROOTFH+SECINFO_NO_NAME, check that you get back a
      legal result.
    - send PUTROOTFH+SECINFO+GETFH, and/or
      PUTROOTFH+SECINFO_NO_NAME+GETFH, check that the GETFH returns
      NOFILEHANDLE.

 Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
---
 nfs4.1/server41tests/__init__.py           |    1 +
 nfs4.1/server41tests/st_secinfo_no_name.py |   35 ++++++++++++++++++++++++++++
 2 files changed, 36 insertions(+), 0 deletions(-)
 create mode 100644 nfs4.1/server41tests/st_secinfo_no_name.py

diff --git a/nfs4.1/server41tests/__init__.py b/nfs4.1/server41tests/__init__.py
index 22cd664..6aee88e 100644
--- a/nfs4.1/server41tests/__init__.py
+++ b/nfs4.1/server41tests/__init__.py
@@ -2,6 +2,7 @@ __all__ = ["st_exchange_id.py", # draft 21
            "st_compound.py",
            "st_create_session.py",
            "st_destroy_session.py",
+           "st_secinfo_no_name.py",
            "st_sequence.py",
 	   "st_trunking.py",
            "st_open.py",
diff --git a/nfs4.1/server41tests/st_secinfo_no_name.py b/nfs4.1/server41tests/st_secinfo_no_name.py
new file mode 100644
index 0000000..a4b148d
--- /dev/null
+++ b/nfs4.1/server41tests/st_secinfo_no_name.py
@@ -0,0 +1,35 @@
+from st_create_session import create_session
+from nfs4_const import *
+from environment import check, fail, bad_sessionid, create_file
+from nfs4_type import channel_attrs4
+import nfs4_ops as op
+import nfs4lib
+
+def testSupported(t, env):
+    """Do a simple SECINFO_NO_NAME
+       send PUTROOTFH+SECINFO_NO_NAME, check is result legal
+
+    FLAGS: all 
+    CODE: SECNN1
+    """
+    c = env.c1.new_client(env.testname(t))
+    sess = c.create_session()
+    res = sess.compound([op.putrootfh(), op.secinfo_no_name()])
+    check(res);
+
+def testSupported2(t, env):
+    """GETFH after do a SECINFO_NO_NAME or SECINFO
+       result in a NOFILEHANDLE error, See rfc 5661 section 2.6.3.1.1.8
+
+    FLAGS: all
+    CODE: SECNN2
+    """
+    c = env.c1.new_client(env.testname(t))
+    sess = c.create_session()
+    res = sess.compound([op.putrootfh(), op.secinfo_no_name(), op.getfh()])
+    print res
+    check(res, NFS4ERR_NOFILEHANDLE);
+
+    res = sess.compound([op.putrootfh(), op.secinfo("tree"), op.getfh()])
+    print res
+    check(res, NFS4ERR_NOFILEHANDLE);
-- 
1.7.3.3


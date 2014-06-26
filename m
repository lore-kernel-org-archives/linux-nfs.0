Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f54.google.com ([209.85.160.54]:63218 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757173AbaFZAGY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Jun 2014 20:06:24 -0400
Received: by mail-pb0-f54.google.com with SMTP id un15so2335872pbc.41
        for <linux-nfs@vger.kernel.org>; Wed, 25 Jun 2014 17:06:24 -0700 (PDT)
Message-ID: <53AB63D3.90509@gmail.com>
Date: Thu, 26 Jun 2014 08:05:39 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>, kinglongmee@gmail.com
Subject: Re: [PATCH 3/3 v3] ACL: Add some test cases for nfsv4 acl
References: <539AD7DD.5060108@gmail.com> <20140618145626.GC17790@fieldses.org>
In-Reply-To: <20140618145626.GC17790@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 6/18/2014 22:56, J. Bruce Fields wrote:
> On Fri, Jun 13, 2014 at 06:52:13PM +0800, Kinglong Mee wrote:
>> v3, modify for exist st_acl.py
>>
>> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
>> ---
>>  nfs4.0/servertests/st_acl.py | 337 +++++++++++++++++++++++++++++++++++++++++--
>>  1 file changed, 326 insertions(+), 11 deletions(-)
... snip ...
>> +def doSetACLEnv(t, env, type = NF4REG):
>> +    c = env.c1
>> +    path = c.homedir + [t.code]
>> +    res = c.create_obj(path, attrs={FATTR4_MODE:0777})
>> +    check(res)
>> +
>> +    c1 = env.c2
> 
> That's pretty confusing variable naming.

A new patch fixing the variable is added below.
Please have a check, thanks.

> 
>> +    c1.init_connection()
>> +
>> +    path += [t.code]
>> +    attrs = {FATTR4_MODE: 0777}
>> +
>> +    if type == NF4REG:
>> +        fh, stateid = c1.create_confirm(t.code, path, attrs=attrs,
>> +                                        deny=OPEN4_SHARE_DENY_NONE)
> 
> Also, this creates a minor cleanup annoyance: a later run of pynfs will
> attempt to reuse the already-existing tree and if it's not running as
> root tries to make everything writable (see nfs4.0/nfs4lib.py:clean_dir)
> so pynfs gives up when a setattr of mode fails (because this file is
> owned by someone else).

Yes, that's right.
I will check the problem with running as a non-root user,
and try to find the resolve.

> 
> Honestly I don't really understand how pynfs is meant to work here or
> who's fault this is, but I'm setting this patch aside for now.
> 

As you said, I always run it as a root-user, so pynfs works correctly.

thanks,
Kinglong Mee

>From b340bb95ab063d19f421fb987114ef05c395ee64 Mon Sep 17 00:00:00 2001
From: Kinglong Mee <kinglongmee@gmail.com>
Date: Thu, 26 Jun 2014 15:57:11 +0800
Subject: [PATCH] nfs4.0/acl: meaningful variable naming for session

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 nfs4.0/servertests/st_acl.py | 21 ++++++++++++---------
 1 file changed, 12 insertions(+), 9 deletions(-)

diff --git a/nfs4.0/servertests/st_acl.py b/nfs4.0/servertests/st_acl.py
index 5c7146a..7869189 100644
--- a/nfs4.0/servertests/st_acl.py
+++ b/nfs4.0/servertests/st_acl.py
@@ -130,25 +130,28 @@ def doCheckACL(t, c, file, acl):
 #    print printableacl(attrs[FATTR4_ACL])
 
 def doSetACLEnv(t, env, type = NF4REG):
-    c = env.c1
-    path = c.homedir + [t.code]
-    res = c.create_obj(path, attrs={FATTR4_MODE:0777})
+    """ Create a directory with 0777 as top dir, and create a directory
+        or a regualr file for testing by other user under the above dir.
+    """
+    cdir = env.c1
+    path = cdir.homedir + [t.code]
+    res = cdir.create_obj(path, attrs={FATTR4_MODE:0777})
     check(res)
 
-    c1 = env.c2
-    c1.init_connection()
+    ctest = env.c2
+    ctest.init_connection()
 
     path += [t.code]
     attrs = {FATTR4_MODE: 0777}
 
     if type == NF4REG:
-        fh, stateid = c1.create_confirm(t.code, path, attrs=attrs,
+        fh, stateid = ctest.create_confirm(t.code, path, attrs=attrs,
                                         deny=OPEN4_SHARE_DENY_NONE)
-        return (c1, path, fh, stateid)
+        return (ctest, path, fh, stateid)
     else:
-        res = c1.create_obj(path, attrs=attrs)
+        res = ctest.create_obj(path, attrs=attrs)
         check(res)
-        return (c1, path)
+        return (ctest, path)
 
 def testWriteFileWithoutACL(t, env):
     """ Check write file without write ACL
-- 
1.9.3


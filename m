Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:64006 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1757566Ab0KOIJO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Nov 2010 03:09:14 -0500
Message-ID: <4CE0EB7B.5060509@cn.fujitsu.com>
Date: Mon, 15 Nov 2010 16:12:43 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: NFSv3 list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS4.1: Fix bug server don't reply the right fore_channel
 to client at create_session
References: <4CDBBF7C.90108@cn.fujitsu.com> <20101112204554.GF32745@fieldses.org>
In-Reply-To: <20101112204554.GF32745@fieldses.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



J. Bruce Fields:
> On Thu, Nov 11, 2010 at 06:03:40PM +0800, Mi Jinlong wrote:
>> At the latest kernel(2.6.37-rc1), server just initialize the forechannel
>> at init_forechannel_attrs, but don't reflect it to reply.
>>
>> After initialize the session success, we should copy the forechannel info
>> to nfsd4_create_session struct.
> 
> Thanks!
> 
> Is there a chance you could write a pynfs test for this?

Maybe the following one is OK.
------------

SRVR: Can server return fore_channel maxreqs correctly 

When client set the fore_channel maxreqs larger than server's
NFSD_MAX_SLOTS_PER_SESSION at create_sessino, the fore_channel
maxreqs at the reply must less than NFSD_MAX_SLOTS_PER_SESSION.

At 2.6.37-rc1, the NFSD_MAX_SLOTS_PER_SESSION is 160.

Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
---
 nfs4.1/server41tests/st_create_session.py |   19 +++++++++++++++++++
 1 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/nfs4.1/server41tests/st_create_session.py b/nfs4.1/server41tests/st_create_session.py
index 5f425d4..174d31e 100644
--- a/nfs4.1/server41tests/st_create_session.py
+++ b/nfs4.1/server41tests/st_create_session.py
@@ -156,6 +156,25 @@ def testReplay1b(t, env):
     if not nfs4lib.test_equal(res1, res2):
         fail("Replay results not equal")
 
+def testReplay1c(t, env):
+    """Replay a successful CREATE_SESSION with right maxreqs 
+        (less than NFSD_MAX_SLOTS_PER_SESSION)
+
+    FLAGS: create_session all
+    CODE: CSESS5c
+    """
+    NFSD_MAX_SLOTS_PER_SESSION = 160
+
+    c = env.c1.new_client(env.testname(t))
+    # CREATE_SESSION with fore_channel = NFSD_MAX_SLOTS_PER_SESSION + 1
+    chan_attrs = channel_attrs4(0,8192,8192,8192,128,
+                                NFSD_MAX_SLOTS_PER_SESSION + 1,[])
+    sess1 = c.create_session(fore_attrs=chan_attrs)
+
+    if nfs4lib.test_equal(sess1.fore_channel.maxrequests,
+                          chan_attrs.ca_maxrequests, "count4"):
+        fail("Replay wrong fore_channel maxreqs")
+
 def testReplay2(t, env):
     """Replay a unsuccessful CREATE_SESSION
     
-- 
1.7.3.2



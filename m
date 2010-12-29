Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:51072 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753752Ab0L2Tfx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Dec 2010 14:35:53 -0500
Date: Wed, 29 Dec 2010 14:35:52 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Cc: NFSv3 list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS4.1: Fix bug server don't reply the right
 fore_channel to client at create_session
Message-ID: <20101229193551.GB12218@fieldses.org>
References: <4CDBBF7C.90108@cn.fujitsu.com>
 <20101112204554.GF32745@fieldses.org>
 <4CE0EB7B.5060509@cn.fujitsu.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4CE0EB7B.5060509@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Nov 15, 2010 at 04:12:43PM +0800, Mi Jinlong wrote:
> 
> 
> J. Bruce Fields:
> > On Thu, Nov 11, 2010 at 06:03:40PM +0800, Mi Jinlong wrote:
> >> At the latest kernel(2.6.37-rc1), server just initialize the forechannel
> >> at init_forechannel_attrs, but don't reflect it to reply.
> >>
> >> After initialize the session success, we should copy the forechannel info
> >> to nfsd4_create_session struct.
> > 
> > Thanks!
> > 
> > Is there a chance you could write a pynfs test for this?
> 
> Maybe the following one is OK.

Yes, thanks very much.  But could we use a larger MAX_SLOTS_PER_SESSION
value, to increase the chances this test will make sense for any
server?

Also, this is a "reply", not a "replay", test, so move it a little
later; how about the following?

--b.

commit bf41254ab3583f6e41c96b1861956dd31595928d
Author: Mi Jinlong <mijinlong@cn.fujitsu.com>
Date:   Mon Nov 15 16:12:43 2010 +0800

    SRVR: Can server return fore_channel maxreqs correctly
    
    When client set the fore_channel maxreqs larger than server's
    NFSD_MAX_SLOTS_PER_SESSION at create_session, the fore_channel
    maxreqs at the reply must less than NFSD_MAX_SLOTS_PER_SESSION.
    
    At 2.6.37-rc1, the NFSD_MAX_SLOTS_PER_SESSION is 160.
    
    Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/nfs4.1/server41tests/st_create_session.py b/nfs4.1/server41tests/st_create_session.py
index 5f425d4..efb2641 100644
--- a/nfs4.1/server41tests/st_create_session.py
+++ b/nfs4.1/server41tests/st_create_session.py
@@ -363,3 +363,23 @@ def testCallbackVersion(t, env):
                  (cb_occurred.low, cb_occurred.hi, cb_occurred.vers))
     finally:
         env.c1._check_version = orig
+
+def testMaxreqs(t, env):
+    """A CREATE_SESSION with maxreqs too large should return
+       a modified value
+
+    FLAGS: create_session all
+    CODE: CSESS22
+    """
+    # Assuming this is too large for any server; increase if necessary:
+    TOO_MANY_SLOTS = 1000000
+
+    c = env.c1.new_client(env.testname(t))
+    # CREATE_SESSION with fore_channel = TOO_MANY_SLOTS
+    chan_attrs = channel_attrs4(0,8192,8192,8192,128, TOO_MANY_SLOTS, [])
+    sess1 = c.create_session(fore_attrs=chan_attrs)
+
+    if nfs4lib.test_equal(sess1.fore_channel.maxrequests,
+                          chan_attrs.ca_maxrequests, "count4"):
+        fail("Server allows surprisingly large fore_channel maxreqs");

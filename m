Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:50471 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752184Ab1EJJVa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 May 2011 05:21:30 -0400
Message-ID: <4DC90418.9040100@cn.fujitsu.com>
Date: Tue, 10 May 2011 17:23:36 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfsd41: Deny new lock before RECLAIM_COMPLETE done
References: <4DB76D60.3010802@cn.fujitsu.com> <20110427135422.GA1618@fieldses.org> <4DC902B9.5060103@cn.fujitsu.com>
In-Reply-To: <4DC902B9.5060103@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



Mi Jinlong :
> Hi Bruce,
> 
>  Sorry for so late to reply you.
> 
> J. Bruce Fields:
>> On Wed, Apr 27, 2011 at 09:12:00AM +0800, Mi Jinlong wrote:
>>> Before nfs41 client's RECLAIM_COMPLETE done, nfs server should 
>>> deny it's new lock.
>>>
>>> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
>> Is nfserr_grace the right error?  (Honest question, I haven't looked it
>> up.)
> 
>   Yes, rfc5661 says:
> 
>   " Whenever a client establishes a new client ID and before it does the
>     first non-reclaim operation that obtains a lock, it MUST send a
>     RECLAIM_COMPLETE with rca_one_fs set to FALSE, even if there are no
>     locks to reclaim.  If non-reclaim locking operations are done before
>     the RECLAIM_COMPLETE, an NFS4ERR_GRACE error will be returned. "
>  
>> Also I'd think this check should go in nfsd4_open: opens are also
>> prohibited before RECLAIM_COMPLETE, and if we check there then we don't
>> need to check here, as you have to have open state before you can do a
>> lock.
> 
>   Agree with you, what about the following one??

  After this patch, we should add a new patch to pynfs41 test site.
  Otherwise, the test site will walk out.

----
thanks
Mi Jinlong

>From baa71190a279f6b35a919088d985482dedf06a71 Mon Sep 17 00:00:00 2001
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
Date: Tue, 10 May 2011 14:14:38 +0800
Subject: [PATCH] CLNT: Send RECLAIM_COMPLETE to server before do 'maketree'

Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
---
 nfs4.1/server41tests/environment.py |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/nfs4.1/server41tests/environment.py b/nfs4.1/server41tests/environment.py
index 4ce7a70..857b29f 100644
--- a/nfs4.1/server41tests/environment.py
+++ b/nfs4.1/server41tests/environment.py
@@ -157,6 +157,10 @@ class Environment(testmod.Environment):
 
     def _maketree(self, sess):
         """Make test tree"""
+        # RECLAIM_COMPLETE
+        res = sess.compound([op.reclaim_complete(FALSE)])
+        check(res)
+
         # ensure /tmp (and path leading up) exists
         path = []
         for comp in self.opts.home:
-- 
1.7.4.5


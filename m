Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:51051 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752922Ab1CVJnT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Mar 2011 05:43:19 -0400
Message-ID: <4D886F71.8050001@cn.fujitsu.com>
Date: Tue, 22 Mar 2011 17:44:17 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 10/17] CLNT: test resues slot ID
References: <4D6DE26C.3010103@cn.fujitsu.com> <4D6DE4A5.1050702@cn.fujitsu.com> <20110303061442.GE7724@fieldses.org> <4D6F5B4E.7000903@cn.fujitsu.com> <4D70AB97.3070502@cn.fujitsu.com> <20110314184144.GB25442@fieldses.org> <20110314192434.GC25442@fieldses.org> <4D7ED324.4070600@cn.fujitsu.com> <20110317225245.GE31845@fieldses.org>
In-Reply-To: <20110317225245.GE31845@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



J. Bruce Fields:
> On Tue, Mar 15, 2011 at 10:47:00AM +0800, Mi Jinlong wrote:
>>
>> J. Bruce Fields:
>>> On Mon, Mar 14, 2011 at 02:41:44PM -0400, J. Bruce Fields wrote:
>>>> On Fri, Mar 04, 2011 at 05:06:31PM +0800, Mi Jinlong wrote:
>>>>>    Maybe the following one is better than before.
>>>> Looks good to me, thanks!
>>> But on testing I get a failure:
>>>
>>> SEQ14    st_sequence.testReuseSlotID                              : FAILURE
>>>            AttributeError: LOOKUP4res instance has no attribute
>>> 	   'object'
>>   See below.
>>
>>> I haven't tried to figure out what's going on there.
>>>
>>> --b.
>>>
>>>> Very minor nit:
>>>>
>>>>> +def testReuseSlotID(t, env):
>>>>> +    """ If client reuses a slot ID and sequence ID for a completely
>>>>> +        different request, server MAY treat the request as if it is
>>>>> +        a retry of what it has already executed. rfc5661 18.46.3
>>>>> +
>>>>> +    FLAGS: sequence all
>>>>> +    CODE: SEQ14
>>>>> +    """
>>>>> +    c = env.c1.new_client(env.testname(t))
>>>>> +    # CREATE_SESSION
>>>>> +    sess1 = c.create_session()
>>>>> +
>>>>> +    name = "%s_1" % env.testname(t)
>>>>> +    res = create_file(sess1, name) 
>>>> Could you check your patches for trailing whitespace?  (There's an extra
>>>> space at the end of that line.)
>>   I will pay attention to that in the future.
>>
>>>> (No need to resend anything.)
>>>>
>>>> --b.
>>>>
>>>>> +    check(res)
>>>>> +
>>>>> +    sid = sess1.sessionid
>>>>> +    seqid = nfs4lib.inc_u32(sess1.seqid)
>>>>> +    fh = res.resarray[3].object
>>   The error only appears here. 
>>
>>   At my machine, the res.resarray[3] is GETFHres. 
>>   As the above error message shown res.resarray[3] is LOOKUP4res.
>>   Is it the nfs4lib's problem?
> 
> Oh, are you assuming that the GETFH op is always at the same position in
> the compound?
> 
> You can't do that--the number of LOOKUPS required to get to the file
> depends on how deep in the server's pseudofs the file is.
> 
> Note the following "homedir = " line also assumes that the pynfs tests
> are being run on /, but that's not necessarily true.

  I have made a mistake about this case, we don't need the filehandle from GETFHres,
  that is just unnecessary.

  Thanks for your point about the homedir, 
  I found a function named use_obj at nfs4lib which can solve our problem.

  After fixed, maybe the following patch is OK now.

---
thanks,
Mi Jinlong 

>From e9faf0c2e86421012296f95ce5cd9cd3338f98a2 Mon Sep 17 00:00:00 2001
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
Date: Mon, 22 Mar 2011 19:25:23 +0800
Subject: [PATCH] CLNT: test resues slot ID

Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
---
 nfs4.1/server41tests/st_sequence.py |   29 +++++++++++++++++++++++++++++
 1 files changed, 29 insertions(+), 0 deletions(-)

diff --git a/nfs4.1/server41tests/st_sequence.py b/nfs4.1/server41tests/st_sequence.py
index c11fdc9..7277290 100644
--- a/nfs4.1/server41tests/st_sequence.py
+++ b/nfs4.1/server41tests/st_sequence.py
@@ -363,3 +363,32 @@ def testBadSequenceidAtSlot(t, env):
 
     res = c.c.compound([op.sequence(sid, nfs4lib.dec_u32(seqid), 2, 3, True)])
     check(res, NFS4ERR_SEQ_MISORDERED)
+
+def testReuseSlotID(t, env):
+    """ If client reuses a slot ID and sequence ID for a completely
+        different request, server MAY treat the request as if it is
+        a retry of what it has already executed. rfc5661 18.46.3
+
+    FLAGS: sequence all
+    CODE: SEQ14
+    """
+    c = env.c1.new_client(env.testname(t))
+    # CREATE_SESSION
+    sess1 = c.create_session()
+
+    name = "%s_1" % env.testname(t)
+    res = create_file(sess1, name)
+    check(res)
+
+    sid = sess1.sessionid
+    seqid = nfs4lib.inc_u32(sess1.seqid)
+    dir = sess1.c.homedir
+
+    res = c.c.compound([op.sequence(sid, seqid, 0, 0, TRUE)] +
+                        nfs4lib.use_obj(dir) + [op.remove(name)])
+    check(res)
+
+    # Reuses slot ID and sequence ID for different request
+    res = c.c.compound([op.sequence(sid, seqid, 0, 0, TRUE)] +
+                        nfs4lib.use_obj(dir) + [op.rename(name, "test")])
+    check(res)
-- 
1.7.4.1





Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cn.fujitsu.com ([222.73.24.84]:59803 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755923Ab1K1C2l (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 27 Nov 2011 21:28:41 -0500
Message-ID: <4ED2F306.8070707@cn.fujitsu.com>
Date: Mon, 28 Nov 2011 10:33:42 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: NFS <linux-nfs@vger.kernel.org>, Fred Isaman <iisaman@netapp.com>
Subject: Re: [PATCH] 4.1 CLNT: Test Case for OPEN file with claim_type is
 CLAIM_FH
References: <4EC46E76.5040907@cn.fujitsu.com> <20111122222632.GA23818@fieldses.org> <4ECC4A0A.9080601@cn.fujitsu.com>
In-Reply-To: <4ECC4A0A.9080601@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce,

 Sorry for so late replying you.

Mi Jinlong :
> 
> J. Bruce Fields:
>> On Thu, Nov 17, 2011 at 10:16:22AM +0800, Mi Jinlong wrote:
>>> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
>>> ---
>>>  nfs4.1/server41tests/st_open.py |   38 +++++++++++++++++++++++++++++++++++++-
>>>  1 files changed, 37 insertions(+), 1 deletions(-)
>>>
>>> diff --git a/nfs4.1/server41tests/st_open.py b/nfs4.1/server41tests/st_open.py
>>> index bd995a5..87b58b3 100644
>>> --- a/nfs4.1/server41tests/st_open.py
>>> +++ b/nfs4.1/server41tests/st_open.py
>>> @@ -1,6 +1,6 @@
>>>  from st_create_session import create_session
>>>  from nfs4_const import *
>>> -from environment import check, checklist, fail, create_file, open_file
>>> +from environment import check, checklist, fail, create_file, open_file, close_file
>>>  from nfs4_type import open_owner4, openflag4, createhow4, open_claim4
>>>  from nfs4_type import creatverfattr, fattr4
>>>  import nfs4_ops as op
>>> @@ -200,3 +200,39 @@ def testEXCLUSIVE4AtNameAttribute(t, env):
>>>      res = create_file(sess1, env.testname(t), mode=EXCLUSIVE4_1,
>>>                          verifier = "Justtest")
>>>      check(res, NFS4ERR_EXIST)
>>> +
>>> +def testOPENClaimFH(t, env):
>>> +    """OPEN file with claim_type is CLAIM_FH
>>> +
>>> +    FLAGS: open all
>>> +    CODE: OPEN7
>>> +    """
>>> +    sess1 = env.c1.new_client_session(env.testname(t))
>>> +    res = create_file(sess1, env.testname(t))
>>> +    check(res)
>>> +
>>> +    fh = res.resarray[-1].object
>>> +    stateid = res.resarray[-2].stateid
>>> +    res = close_file(sess1, fh, stateid=stateid)
>>> +    check(res)
>>> +
>>> +    claim = open_claim4(CLAIM_FH)
>>> +    how = openflag4(OPEN4_NOCREATE)
>>> +    oowner = open_owner4(0, "My Open Owner 2")
>>> +    open_op = op.open(0, OPEN4_SHARE_ACCESS_BOTH, OPEN4_SHARE_DENY_NONE,
>>> +                      oowner, how, claim)
>>> +    res = sess1.compound([op.putfh(fh), open_op])
>>> +    check(res)
>> You could just stop here.  But I suppose I don't see a problem with
>> doing some IO to the file too just to make sure the open is usable.
> 
>   Yes, that's right.
> 
>>> +
>>> +    stateid = res.resarray[-1].stateid
>>> +    stateid.seqid = 0
>> Why are you modifying the seqid?

  At any date writing or reading, seqid should be zero.
  And, NFS client do as it. So, we set seqid = 0 here.

>>
>>> +    data = "write test data"
>>> +    res = sess1.compound([op.putfh(fh), op.write(stateid, 5, FILE_SYNC4, data)])
>>> +    check(res)
>>> +    res = sess1.compound([op.putfh(fh), op.read(stateid, 0, 1000)])
>>> +    check(res)
>>> +    if not res.resarray[-1].eof:
>>> +        fail("EOF not set on read")
>>> +    desired = "\0"*5 + data
>> Why the five nulls?  I don't understand this code....

  Because we write data at offset 5 above, so there are five nulls exist.

+    res = sess1.compound([op.putfh(fh), op.write(stateid, 5, FILE_SYNC4, data)])

thanks,
Mi Jinlong



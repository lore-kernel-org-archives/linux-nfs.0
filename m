Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:51477 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750783Ab1CCJGU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Mar 2011 04:06:20 -0500
Message-ID: <4D6F5A3D.6050000@cn.fujitsu.com>
Date: Thu, 03 Mar 2011 17:07:09 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 02/17] CLNT: test lease period of unconfirmed record
References: <4D6DE26C.3010103@cn.fujitsu.com> <4D6DE34A.2020404@cn.fujitsu.com> <20110303060225.GD7724@fieldses.org>
In-Reply-To: <20110303060225.GD7724@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



J. Bruce Fields :
> On Wed, Mar 02, 2011 at 02:27:22PM +0800, Mi Jinlong wrote:
>> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
>> ---
>>  nfs4.1/server41tests/st_exchange_id.py |   26 ++++++++++++++++++++++++++
>>  1 files changed, 26 insertions(+), 0 deletions(-)
>>
>> diff --git a/nfs4.1/server41tests/st_exchange_id.py b/nfs4.1/server41tests/st_exchange_id.py
>> index b5e34e6..85f3092 100644
>> --- a/nfs4.1/server41tests/st_exchange_id.py
>> +++ b/nfs4.1/server41tests/st_exchange_id.py
>> @@ -1,5 +1,6 @@
>>  from nfs4_const import *
>>  import nfs4_ops as op
>> +import time
>>  from environment import check, fail
>>  from nfs4_type import *
>>  from rpc import RPCAcceptError, GARBAGE_ARGS, RPCTimeout
>> @@ -436,3 +437,28 @@ def testNotOnlyOp(t, env):
>>      res = c.compound([op.exchange_id(owner, 0, protect, [c.impl_id]), op.putrootfh()])
>>      # per draft 21 18.35.3, server MUST return NFS4ERR_NOT_ONLY_OP
>>      check(res, NFS4ERR_NOT_ONLY_OP)
>> +
>> +def testLeasePeriod(t, env):
>> +    """Any unconfirmed record that is not confirmed within
>> +       a lease period SHOULD be removed.
>> +
>> +    FLAGS: exchange_id all
>> +    CODE: EID9
>> +    """
>> +    c1 = env.c1.new_client("%s_1" % env.testname(t))
>> +    c2 = env.c1.new_client("%s_2" % env.testname(t))
>> +    # CREATE_SESSION
>> +    chan_attrs = channel_attrs4(0,8192,8192,8192,128,8,[])
>> +    time.sleep(80)
> 
> Let's not hard-code any lease time.  pynfs should do a getattr to find
> the server's lease time, and use that as the basis for calculations
> (we need something like the getLeaseTime in the 4.0 pynfs.)
> 
> I actually usually set the server lease time to 15 seconds for testing,
> just to make the tests go faster....

  Agree with you!
  What about the following one?

---
thanks,
Mi Jinlong

=================================

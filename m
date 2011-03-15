Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:50083 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752012Ab1CODFt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Mar 2011 23:05:49 -0400
Message-ID: <4D7ED7BE.70400@cn.fujitsu.com>
Date: Tue, 15 Mar 2011 11:06:38 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 15/17] CLNT: test lock before RECLAIM_COMPLETE
References: <4D6DE26C.3010103@cn.fujitsu.com> <4D6DE55F.6040205@cn.fujitsu.com> <20110314192733.GD25442@fieldses.org>
In-Reply-To: <20110314192733.GD25442@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



J. Bruce Fields:
> On Wed, Mar 02, 2011 at 02:36:15PM +0800, Mi Jinlong wrote:
>> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
> 
> I'm getting failures I don't understand on these reclaim complete tests
> too.

  Maybe there are some problem I have missing. 

  If testing reclaim-complete, we should restart server's NFS service.
  I think those tests about reclaim-complete need some fix.

  After fixed, I will send those patch again.

--
thanks,
Mi Jinlong 

> 
> --b.
> 
>> ---
>>  nfs4.1/server41tests/st_reclaim_complete.py |   26 ++++++++++++++++++++++++++
>>  1 files changed, 26 insertions(+), 0 deletions(-)
>>
>> diff --git a/nfs4.1/server41tests/st_reclaim_complete.py b/nfs4.1/server41tests/st_reclaim_complete.py
>> index 45ac9ad..a94f2ad 100644
>> --- a/nfs4.1/server41tests/st_reclaim_complete.py
>> +++ b/nfs4.1/server41tests/st_reclaim_complete.py
>> @@ -50,3 +50,29 @@ def testReclaimAfterRECC(t, env):
>>  
>>      res = sess.compound([op.putfh(cfh), op.lock(READ_LT, TRUE, 0, 1, lowner)])
>>      check(res, NFS4ERR_NO_GRACE)
>> +
>> +def testLockBeforeRECC(t, env):
>> +    """After a client establishes a new client ID, if non-reclaim
>> +       locking operations are done before the RECLAIM_COMPLETE,
>> +       error NFS4ERR_GRACE will be returned. rfc5661 18.51.3
>> +
>> +    FLAGS: all
>> +    CODE: RECC3
>> +    """
>> +    name = env.testname(t)
>> +    c = env.c1.new_client(name)
>> +    sess = c.create_session()
>> +
>> +    fname = "owner_%s" % name
>> +    path = sess.c.homedir + [name]
>> +    res = create_file(sess, fname, path, access=OPEN4_SHARE_ACCESS_BOTH)
>> +    check(res)
>> +
>> +    oseqid = res.resarray[2].stateid
>> +    cfh = res.resarray[3].object
>> +    owner = open_owner4(0, "My Open Owner")
>> +    otlowner = open_to_lock_owner4(0, oseqid, 0, owner)
>> +    lowner = locker4(TRUE, otlowner)
>> +
>> +    res = sess.compound([op.putfh(cfh), op.lock(READ_LT, FALSE, 0, 1, lowner)])
>> +    check(res, NFS4ERR_NO_GRACE)
>> -- 
>> 1.7.4.1
>>
>>
>>
> 


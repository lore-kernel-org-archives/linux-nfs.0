Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f52.google.com ([209.85.220.52]:37044 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752845AbaFQIJt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Jun 2014 04:09:49 -0400
Received: by mail-pa0-f52.google.com with SMTP id eu11so5453910pac.39
        for <linux-nfs@vger.kernel.org>; Tue, 17 Jun 2014 01:09:49 -0700 (PDT)
Message-ID: <539FF7BC.2010004@gmail.com>
Date: Tue, 17 Jun 2014 16:09:32 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>, kinglongmee@gmail.com
Subject: Re: [PATCH 2/3 v3] NFS4.0: Cases for SGID/SUID status after writing
References: <539AD76F.4000200@gmail.com> <20140616223243.GC12458@fieldses.org>
In-Reply-To: <20140616223243.GC12458@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 6/17/2014 06:32, J. Bruce Fields wrote:
> On Fri, Jun 13, 2014 at 06:50:23PM +0800, Kinglong Mee wrote:
>> v3, same as v2.
>> v2, Adds Environment.c3. 
> 
> I'm testing with norootsquash on the latest upstream (which includes
> your "NFSD: Don't clear SUID/SGID after root writing data") but still
> see these failing.  Exports have no_root_squash set.  Is there something
> else I'm missing?

In my testing,
# cat /etc/exports
/nfstest	*(ro,no_root_squash,no_subtree_check,insecure)
/nfstest/test	*(rw,no_root_squash,no_subtree_check,insecure)
# df | grep nfstest
/dev/sdb1        1047552       96   1043364   1% /nfstest
/dev/sdc1        1014680     1284    944636   1% /nfstest/test
# ./testserver.py 127.0.0.1:/nfstest/test --maketree --rundeps --outfile=result.log write
Sleeping for 1 seconds: 
Woke up
Got error: [Errno 32] Broken pipe
**************************************************
INIT     st_setclientid.testValid                                 : PASS
MKBLK    st_create.testBlock                                      : PASS
MKCHAR   st_create.testChar                                       : PASS
MKDIR    st_create.testDir                                        : PASS
MKFIFO   st_create.testFIFO                                       : PASS
MKFILE   st_open.testOpen                                         : PASS
MKLINK   st_create.testLink                                       : PASS
MKSOCK   st_create.testSocket                                     : PASS
OPEN24   st_open.testDenyRead4                                    : PASS
OPEN27   st_open.testDenyWrite3                                   : PASS
WRT1     st_write.testSimpleWrite                                 : PASS
WRT1b    st_write.testSimpleWrite2                                : PASS
WRT2     st_write.testStateidOne                                  : PASS
WRT3     st_write.testWithOpen                                    : PASS
WRT4     st_write.testNoData                                      : PASS
WRT5     st_write.testLargeData                                   : FAILURE
           error: [Errno 32] Broken pipe
WRT6a    st_write.testLink                                        : PASS
WRT6b    st_write.testBlock                                       : PASS
WRT6c    st_write.testChar                                        : PASS
WRT6d    st_write.testDir                                         : PASS
WRT6f    st_write.testFifo                                        : PASS
WRT6s    st_write.testSocket                                      : PASS
WRT7     st_write.testNoFh                                        : PASS
WRT8     st_write.testOpenMode                                    : PASS
WRT9     st_write.testShareDeny                                   : PASS
WRT11    st_write.testStaleStateid                                : PASS
WRT12    st_write.testOldStateid                                  : PASS
WRT13    st_write.testDoubleWrite                                 : PASS
WRT14    st_write.testLargeWrite                                  : PASS
WRT15    st_write.testSizes                                       : PASS
WRT16    st_write.testLargeReadWrite                              : PASS
WRT17    st_write.testMultipleReadWrites                          : PASS
**************************************************
Command line asked for 32 of 677 tests
Of those: 0 Skipped, 1 Failed, 0 Warned, 31 Passed

thanks,
Kinglong Mee

> 
> --b.
> 
>>
>> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
>> ---
>>  nfs4.0/servertests/environment.py |  4 ++
>>  nfs4.0/servertests/st_write.py    | 84 +++++++++++++++++++++++++++++++++++++++
>>  2 files changed, 88 insertions(+)
>>
>> diff --git a/nfs4.0/servertests/environment.py b/nfs4.0/servertests/environment.py
>> index 9852178..48d4e26 100644
>> --- a/nfs4.0/servertests/environment.py
>> +++ b/nfs4.0/servertests/environment.py
>> @@ -104,12 +104,16 @@ class Environment(testmod.Environment):
>>          sec1, sec2 = self._get_security(opts)
>>  #        authsys1 = rpc.SecAuthSys(0, opts.machinename, opts.uid, opts.gid, [])
>>          authsys2 = rpc.SecAuthSys(0, opts.machinename, opts.uid+1, opts.gid+1, [])
>> +        authsys3 = rpc.SecAuthSys(0, opts.machinename, opts.uid+2, opts.gid+2, [])
>>          self.c1 = NFS4Client('client1_pid%i' % os.getpid(),
>>                               opts.server, opts.port, opts.path,
>>                               sec_list=[sec1], opts=opts)
>>          self.c2 = NFS4Client('client2_pid%i' % os.getpid(),
>>                               opts.server, opts.port, opts.path,
>>                               sec_list=[authsys2], opts=opts)
>> +        self.c3 = NFS4Client('client3_pid%i' % os.getpid(),
>> +                             opts.server, opts.port, opts.path,
>> +                             sec_list=[authsys3], opts=opts)
>>          self.longname = "a"*512
>>          self.uid = 0
>>          self.gid = 0
>> diff --git a/nfs4.0/servertests/st_write.py b/nfs4.0/servertests/st_write.py
>> index c76cf94..3e58cba 100644
>> --- a/nfs4.0/servertests/st_write.py
>> +++ b/nfs4.0/servertests/st_write.py
>> @@ -457,3 +457,87 @@ def testMultipleReadWrites(t,env):
>>          if resdata != expect:
>>              t.fail("READ %d returned %s, expected %s" %
>>                      (i+1, repr(resdata), repr(expect)))
>> +
>> +def doCheckMode(t, c, fh, mode):
>> +    ops = c.use_obj(fh)
>> +    ops += [c.getattr([FATTR4_MODE, FATTR4_OWNER, FATTR4_OWNER_GROUP])]
>> +    res = c.compound(ops)
>> +    check(res)
>> +
>> +    attrs = res.resarray[-1].obj_attributes
>> +    if FATTR4_MODE not in attrs.keys():
>> +         t.fail("Attributes not contains FATTR4_MODE")
>> +    resmode = attrs[FATTR4_MODE]
>> +    if resmode != mode:
>> +         t.fail("Mode is %o, not expected %o" % (resmode, mode))
>> +
>> +def doCheckSGUID(t, env, cc, cw, cmode = 06777):
>> +    c = env.c1
>> +    path = c.homedir + [t.code]
>> +    res = c.create_obj(path, attrs={FATTR4_MODE:0777})
>> +    check(res)
>> +
>> +    cc.init_connection()
>> +    attrs = {FATTR4_SIZE: 32, FATTR4_MODE: 06777}
>> +    path += [t.code]
>> +    fh, stateid = cc.create_confirm(t.code, path, attrs=attrs,
>> +                                   deny=OPEN4_SHARE_DENY_NONE)
>> +    doCheckMode(t, cc, fh, 06777)
>> +
>> +    cw.init_connection()
>> +    ops = cw.use_obj(fh)
>> +    ops += [cw.write_op(stateid4(0, ''), 0, UNSTABLE4, 'for test')]
>> +    res = cw.compound(ops)
>> +    check(res)
>> +
>> +    doCheckMode(t, cw, fh, cmode)
>> +
>> +def testSGUIDRootRoot(t, env):
>> +    """ root writing data to file (blongs to root)
>> +        will not clear the SUID/SGID mode
>> +
>> +    FLAGS: wrtie file all
>> +    DEPEND: MODE MKFILE
>> +    CODE: WRT16a
>> +    """
>> +    doCheckSGUID(t, env, env.c1, env.c1)
>> +
>> +def testSGUIDRootNoRoot(t, env):
>> +    """ root writing data to file (blongs to no-root)
>> +        will not clear the SUID/SGID mode
>> +
>> +    FLAGS: wrtie file all
>> +    DEPEND: MODE MKFILE
>> +    CODE: WRT16b
>> +    """
>> +    doCheckSGUID(t, env, env.c2, env.c1)
>> +
>> +def testSGUIDNoRootSelf(t, env):
>> +    """ no-root writing data to file (blongs to self)
>> +        will clear the SUID/SGID mode
>> +
>> +    FLAGS: wrtie file all
>> +    DEPEND: MODE MKFILE
>> +    CODE: WRT16c
>> +    """
>> +    doCheckSGUID(t, env, env.c2, env.c2, 0777)
>> +
>> +def testSGUIDNoRootRoot(t, env):
>> +    """ no-root writing data to file (blongs to root)
>> +        will clear the SUID/SGID mode
>> +
>> +    FLAGS: wrtie file all
>> +    DEPEND: MODE MKFILE
>> +    CODE: WRT16d
>> +    """
>> +    doCheckSGUID(t, env, env.c1, env.c2, 0777)
>> +
>> +def testSGUIDNoRootNoRoot(t, env):
>> +    """ no-root writing data to file (blongs to no-root)
>> +        will clear the SUID/SGID mode
>> +
>> +    FLAGS: wrtie file all
>> +    DEPEND: MODE MKFILE
>> +    CODE: WRT16e
>> +    """
>> +    doCheckSGUID(t, env, env.c2, env.c3, 0777)
>> -- 
>> 1.9.3
>>
> 

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f174.google.com ([209.85.192.174]:48993 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755468AbaEGJzx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 May 2014 05:55:53 -0400
Received: by mail-pd0-f174.google.com with SMTP id w10so852278pde.5
        for <linux-nfs@vger.kernel.org>; Wed, 07 May 2014 02:55:53 -0700 (PDT)
Message-ID: <536A0312.2070303@gmail.com>
Date: Wed, 07 May 2014 17:55:30 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/3] NFS4.0: Case for linking to bad source patch with
 zero-length
References: <5358EE2F.9070301@gmail.com> <20140506203453.GP18281@fieldses.org>
In-Reply-To: <20140506203453.GP18281@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 5/7/2014 04:34, J. Bruce Fields wrote:
> On Thu, Apr 24, 2014 at 06:57:51PM +0800, Kinglong Mee wrote:
>> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
>> ---
>>  nfs4.0/servertests/st_create.py | 13 +++++++++++++
>>  1 file changed, 13 insertions(+)
>>
>> diff --git a/nfs4.0/servertests/st_create.py b/nfs4.0/servertests/st_create.py
>> index d2d6701..09c80cc 100644
>> --- a/nfs4.0/servertests/st_create.py
>> +++ b/nfs4.0/servertests/st_create.py
>> @@ -161,6 +161,19 @@ def testZeroLength(t, env):
>>      res = c.create_obj(c.homedir + [''])
>>      check(res, NFS4ERR_INVAL, "CREATE with zero-length name")
>>  
>> +def testZeroLengthForLNK(t, env):
>> +    """CREATE with zero length name should return NFS4ERR_INVAL
> 
> Is it actually true that attempts to create symlinks with zero-length
> content should fail with NFS4ERR_INVAL, and if so according to who?  (Is
> there language in the RFC's?)

This test is for Bernd Schubert's fix.
http://www.spinics.net/lists/linux-nfs/msg42800.html

According to rfc3530, 14.2.9, DESCRIPTION

   If the newname has a length of 0 (zero), or if newname does not obey
   the UTF-8 definition, the error NFS4ERR_INVAL will be returned.

thanks,
Kinglong Mee

>> +
>> +    FLAGS: create symlink all
>> +    CODE: CR9a
>> +    """
>> +    c = env.c1
>> +    ops = c.go_home()
>> +    objtype = createtype4(NF4LNK, **{'linkdata':''})
>> +    ops += [c.create_op(objtype, t.code, getDefaultAttr(c))]
>> +    res = c.compound(ops)
>> +    check(res, NFS4ERR_INVAL, "CREATE with zero-length name for SYMLINK")
>> +
>>  def testRegularFile(t, env):
>>      """CREATE should fail with NFS4ERR_BADTYPE for regular files
>>  
>> -- 
>> 1.9.0
>>
> 

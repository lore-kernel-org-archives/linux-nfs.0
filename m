Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ww0-f44.google.com ([74.125.82.44]:49707 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753260Ab1LINEN convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Dec 2011 08:04:13 -0500
Received: by mail-ww0-f44.google.com with SMTP id dr13so5696065wgb.1
        for <linux-nfs@vger.kernel.org>; Fri, 09 Dec 2011 05:04:12 -0800 (PST)
MIME-Version: 1.0
Reply-To: tigran.mkrtchyan@desy.de
In-Reply-To: <20111208213152.GH32505@fieldses.org>
References: <1323363112-13256-1-git-send-email-tigran.mkrtchyan@desy.de>
	<20111208213152.GH32505@fieldses.org>
Date: Fri, 9 Dec 2011 14:04:12 +0100
Message-ID: <CAGue13oF2fb6CdSk_EBdvz9RGjRQHdnhot3S6DmBu1KO2-4Jdw@mail.gmail.com>
Subject: Re: [PATCH 1/2] create open requests without executing
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 8, 2011 at 10:31 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Thu, Dec 08, 2011 at 05:51:51PM +0100, Tigran Mkrtchyan wrote:
>>
>> Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
>> ---
>>  nfs4.1/server41tests/environment.py |   13 ++++++++++++-
>>  1 files changed, 12 insertions(+), 1 deletions(-)
>>
>> diff --git a/nfs4.1/server41tests/environment.py b/nfs4.1/server41tests/environment.py
>> index 6e68e83..6f3bd0a 100644
>> --- a/nfs4.1/server41tests/environment.py
>> +++ b/nfs4.1/server41tests/environment.py
>> @@ -453,6 +453,17 @@ def open_create_file(sess, owner, path=None, attrs={FATTR4_MODE: 0644},
>>                    deleg_type=None,
>>                    open_create=OPEN4_NOCREATE,
>>                    seqid=0, clientid=0):
>> +    return sess.compound(open_create_file_op())
>
> I get:
>
>        ...
>        File "/root/pynfs/nfs4.1/server41tests/environment.py", line 456, in open_create_file
>        return sess.compound(open_create_file_op())
>    TypeError: open_create_file_op() takes at least 2 arguments (0 given)
>
> Also, the following patch has some minor conflicts with Mi Jinlong's
> recent patch.  I don't mind fixing that up myself, but if you're
> regenerating these patches anyway, maybe you could?


rebased, fixed, updated.

Tigran.


>
> Thanks.
>
> --b.
>
>> +
>> +def open_create_file_op(sess, owner, path=None, attrs={FATTR4_MODE: 0644},
>> +                     access=OPEN4_SHARE_ACCESS_BOTH,
>> +                     deny=OPEN4_SHARE_DENY_NONE,
>> +                  mode=GUARDED4, verifier=None,
>> +                  claim_type=CLAIM_NULL,
>> +                  want_deleg=False,
>> +                  deleg_type=None,
>> +                  open_create=OPEN4_NOCREATE,
>> +                  seqid=0, clientid=0):
>>      # Set defaults
>>      if path is None:
>>          dir = sess.c.homedir
>> @@ -485,7 +496,7 @@ def open_create_file(sess, owner, path=None, attrs={FATTR4_MODE: 0644},
>>      open_op = op.open(seqid, access, deny, open_owner4(clientid, owner),
>>                        openflag, openclaim)
>>
>> -    return sess.compound(fh_op + [open_op, op.getfh()])
>> +    return fh_op + [open_op, op.getfh()]
>>
>>  def create_file(sess, owner, path=None, attrs={FATTR4_MODE: 0644},
>>                  access=OPEN4_SHARE_ACCESS_BOTH,
>> --
>> 1.7.7
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html

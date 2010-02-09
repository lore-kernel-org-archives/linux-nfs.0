Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64442 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752291Ab0BIWpO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Feb 2010 17:45:14 -0500
Message-ID: <4B71E572.3020401@redhat.com>
Date: Tue, 09 Feb 2010 17:45:06 -0500
From: Peter Staubach <staubach@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: iisaman@citi.umich.edu, linux-nfs@vger.kernel.org
Subject: Re: [PATCH pynfs] Allow server to reject maximum commit offsets
References: <20100209201231.GC30951@fieldses.org> <4B71E1A4.1070604@redhat.com> <20100209224228.GA1645@fieldses.org>
In-Reply-To: <20100209224228.GA1645@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

J. Bruce Fields wrote:
> On Tue, Feb 09, 2010 at 05:28:52PM -0500, Peter Staubach wrote:
>> J. Bruce Fields wrote:
>>> From: J. Bruce Fields <bfields@citi.umich.edu>
>>>
>>> These two tests insist that a server must accept commits with offset
>>> 2^64-1 and 2^64-2.  I can find no justification in the spec for this
>>> requirement.
>>>
>>> The linux server was recently changed to reject (with INVAL) offsets
>>> over 2^63-1, which is the maximum that the vfs commit routine can
>>> accept.  That behavior is consistent with the NFSv3 commit
>>> implementation and with the NFSv4 write implementation.
>>>
>> I guess that I am missing something.  At least the NFSv3
>> COMMIT operation takes an unsigned 64 bit quantity.  That
>> would seem to make the test correct, would it not?
> 
> Yes, it's an unsigned 64 bit integer, but so what: there's no rule that
> says the server has to return NFS4ERR_OK to any operation for which all
> the arguments are valid xdr.
> 
> And just because the protocol allows 64-bit offsets doesn't mean every
> server and filesystem is going to support the full range.
> 

No, that's certainly true.  However, you are tailoring the
testsuite to a Linux specific implementation, which strikes
me as vaguely not so good.  What if you just commented out
the tests, with a comment indicating that the Linux server
can not handle the full 64 bits of range, instead of
deleting them completely?

	Thanx...

		ps


> --b.
> 
>> 		ps
>>
>>> The maximum offset allowed may vary depending on filesystem or server,
>>> so I think it's simplest just to delete these tests.  (Alternatively, we
>>> could replace the offset by whatever we consider a reasonable least
>>> common denominator, e.g. 2^31-1.)
>>>
>>> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
>>> ---
>>>  lib/nfs4/servertests/st_commit.py |   18 ------------------
>>>  1 files changed, 0 insertions(+), 18 deletions(-)
>>>
>>> diff --git a/lib/nfs4/servertests/st_commit.py b/lib/nfs4/servertests/st_commit.py
>>> index 2955d79..0005e54 100644
>>> --- a/lib/nfs4/servertests/st_commit.py
>>> +++ b/lib/nfs4/servertests/st_commit.py
>>> @@ -35,24 +35,6 @@ def testCommitOffset1(t, env):
>>>      """
>>>      _commit(t, env.c1, 1)
>>>  
>>> -def testCommitOffsetMax1(t, env):
>>> -    """COMMIT
>>> -
>>> -    FLAGS: commit all
>>> -    DEPEND: MKFILE
>>> -    CODE: CMT1c
>>> -    """
>>> -    _commit(t, env.c1, 0xffffffffffffffffL)
>>> -
>>> -def testCommitOffsetMax2(t, env):
>>> -    """COMMIT
>>> -
>>> -    FLAGS: commit all
>>> -    DEPEND: MKFILE
>>> -    CODE: CMT1d
>>> -    """
>>> -    _commit(t, env.c1, 0xfffffffffffffffeL)
>>> -
>>>  def testCommitCount1(t, env):
>>>      """COMMIT
>>>  


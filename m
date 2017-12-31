Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2120.oracle.com ([156.151.31.85]:46822 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750937AbdLaSgG (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 31 Dec 2017 13:36:06 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: NFSv4.1 regression with v4.15-rc
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <874F5218-43E6-423C-9F94-4DFC07FFDF8D@oracle.com>
Date: Sun, 31 Dec 2017 13:35:57 -0500
Cc: Bruce Fields <bfields@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <D8F54031-9F60-4DBA-8D22-FE3587227060@oracle.com>
References: <337F485E-4E53-4EBF-8186-009326C281EC@oracle.com> <20171230180526.GA4141@fieldses.org> <874F5218-43E6-423C-9F94-4DFC07FFDF8D@oracle.com>
To: Bruce Fields <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Dec 30, 2017, at 1:14 PM, Chuck Lever <chuck.lever@oracle.com> =
wrote:
>=20
>>=20
>> On Dec 30, 2017, at 1:05 PM, Bruce Fields <bfields@fieldses.org> =
wrote:
>>=20
>> On Wed, Dec 27, 2017 at 03:40:58PM -0500, Chuck Lever wrote:
>>> Last week I updated my test server from v4.14 to v4.15-rc4, and =
began to
>>> observe intermittent failures in the git regression suite on =
NFSv4.1.
>>=20
>> I haven't run that before.  Should I just
>>=20
>> 	mount -overs=3D4.1 server:/fs /mnt/
>> 	cd /mnt/
>> 	git clone git://git.kernel.org/pub/scm/git/git.git
>> 	cd git
>> 	make test
>>=20
>> ?
>=20
> You'll need to install SVN and CVS on your client as well.
> The failures seem to occur only in the SVN/CVS related
> tests.
>=20
>=20
>>> I
>>> was able to reproduce these failures with NFSv4.1 on both TCP and =
RDMA,
>>> yet there has not been a reproduction with NFSv3 or NFSv4.0.
>>>=20
>>> The server hardware is a single-socket 4-core system with 32GB of =
RAM.
>>> The export is a tmpfs. Networking is 56Gb InfiniBand (or IPoIB).
>>>=20
>>> The git regression suite reports individual test failures in the SVN
>>> and CVS tests. On occasion, the client mount point freezes, =
requiring
>>> that the client be rebooted in order to unstick the mount.
>>>=20
>>> Just before Christmas, I bisected the problem to:
>>=20
>> Thanks for the report!  I'll make some time for this next week.  =
What's
>> your client?

Oops, I didn't answer this question. The client is v4.15-rc4.


>> I guess one start might be to see if the reproducer can be
>> simplified e.g. by running just one of the tests from the suite.
>=20
> The failures are intermittent, and occur in a different test
> each time. You have to wait for the 9000-series scripts, which
> test SVN/CVS repo operations. To speed up time-to-failure, use
> "make -jN test" where N is more than a few.
>=20
> My client and server both have multiple real cores. I'm
> thinking it's the server that matters here (possibly a race
> condition is introduced by the below commit?).
>=20
>=20
>> --b.
>>=20
>>>=20
>>> commit 659aefb68eca28ba9aa482a9fc64de107332e256
>>> Author: Trond Myklebust <trond.myklebust@primarydata.com>
>>> Date:   Fri Nov 3 08:00:13 2017 -0400
>>>=20
>>>   nfsd: Ensure we don't recognise lock stateids after freeing them
>>>=20
>>>   In order to deal with lookup races, nfsd4_free_lock_stateid() =
needs
>>>   to be able to signal to other stateful functions that the lock =
stateid
>>>   is no longer valid. Right now, nfsd_lock() will check whether or =
not an
>>>   existing stateid is still hashed, but only in the "new lock" path.
>>>=20
>>>   To ensure the stateid invalidation is also recognised by the =
"existing lock"
>>>   path, and also by a second call to nfsd4_free_lock_stateid() =
itself, we can
>>>   change the type to NFS4_CLOSED_STID under the stp->st_mutex.
>>>=20
>>>   Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>>>   Signed-off-by: J. Bruce Fields <bfields@redhat.com>
>>>=20
>>>=20
>>> Since we're already at v4.15-rc5 I thought it would be best to break =
the
>>> holiday moratorium instead of waiting another week to report this.
>>>=20
>>>=20
>>> --
>>> Chuck Lever
>>>=20
>>>=20
>=20
> --
> Chuck Lever
>=20
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever




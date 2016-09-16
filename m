Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:46989 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750945AbcIPV2x (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Sep 2016 17:28:53 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: Oleg Drokin <green@linuxhacker.ru>
CC: Schumaker Anna <anna.schumaker@netapp.com>,
        List Linux NFS Mailing <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v4 00/20] Fix delegation behaviour when server revokes
 some state
Date: Fri, 16 Sep 2016 21:28:47 +0000
Message-ID: <931AEEED-EA89-4B8A-8ED3-3BB4BBA5E05B@primarydata.com>
References: <1473957960-10001-1-git-send-email-trond.myklebust@primarydata.com>
 <F3BA1CBE-EADB-4B0A-8DE6-A3B5FB2E2156@linuxhacker.ru>
 <1474040207.75849.1.camel@primarydata.com>
 <FC6D8393-2C79-47FC-98CB-67213BA2D27C@linuxhacker.ru>
 <3C143DE1-43AF-4E73-82D2-FE97A8EFFE3A@linuxhacker.ru>
In-Reply-To: <3C143DE1-43AF-4E73-82D2-FE97A8EFFE3A@linuxhacker.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Sep 16, 2016, at 17:21, Oleg Drokin <green@linuxhacker.ru> wrote:
>=20
>=20
> On Sep 16, 2016, at 5:15 PM, Oleg Drokin wrote:
>=20
>>=20
>> On Sep 16, 2016, at 11:36 AM, Trond Myklebust wrote:
>>=20
>>> On Fri, 2016-09-16 at 00:38 -0400, Oleg Drokin wrote:
>>>> On Sep 15, 2016, at 12:45 PM, Trond Myklebust wrote:
>>>>=20
>>>>>=20
>>>>> According to RFC5661, if any of the SEQUENCE status bits
>>>>> SEQ4_STATUS_EXPIRED_ALL_STATE_REVOKED,
>>>>> SEQ4_STATUS_EXPIRED_SOME_STATE_REVOKED,
>>>>> SEQ4_STATUS_ADMIN_STATE_REVOKED,
>>>>> or SEQ4_STATUS_RECALLABLE_STATE_REVOKED are set, then we need to
>>>>> use
>>>>> TEST_STATEID to figure out which stateids have been revoked, so we
>>>>> can acknowledge the loss of state using FREE_STATEID.
>>>>>=20
>>>>> While we already do this for open and lock state, we have not been
>>>>> doing
>>>>> so for all the delegations.
>>>>>=20
>>>>> v2: nfs_v4_2_minor_ops needs to set .test_and_free_expired too
>>>>> v3: Now with added lock revoke fixes and close/delegreturn/locku
>>>>> fixes
>>>>> v4: Close a bunch of corner cases
>>>>=20
>>>> This one seems to be looping on the client in a way very similar
>>>> to the first failure in that it's the serverip-named process that's
>>>> using the cpu, but the debug log is very similar to the second
>>>> failure
>>>> in test stateid, except this time it's not "success 0", but "success
>>>> -10025":
>>>>=20
>>> Ah... I think I see what the issue is... Does the following help?
>>=20
>> Well, it changed the output back to what I had with the first patch set,=
 I think:
>> I.e. now it's nfsid test succeded, 0, and the process using the cpu is a=
gain
>> a userspace one:
>=20
> Ah, I did not realize you probably meant not to apply this on top of the =
previous
> batch, but replace patch #14 with this one.
> So I am trying it now.

No, not at all. What you did was entirely correct. I=92ve inserted it into =
position 14 in the =91v5=92 patch series because that is where it belongs i=
n order to prevent bisection issues, but it should work identically on top =
of the existing v4...

Thanks!


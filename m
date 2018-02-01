Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:41413 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751669AbeBBJci (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 2 Feb 2018 04:32:38 -0500
From: NeilBrown <neilb@suse.com>
To: Olga Kornievskaia <aglo@umich.edu>
Date: Fri, 02 Feb 2018 09:04:21 +1100
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSv4: always set NFS_LOCK_LOST when a lock is lost.
In-Reply-To: <CAN-5tyHB50kKNfcXyTVgPO+6p6p1iZVCZpROMN-jxP7Be53_UQ@mail.gmail.com>
References: <87r2rzo8qi.fsf@notabene.neil.brown.name> <87bmiul8r6.fsf@notabene.neil.brown.name> <CAN-5tyGf6d=K_9baA6YucbfcVduufVjcLm72jLe2_8XMyT-P2g@mail.gmail.com> <CAN-5tyHB50kKNfcXyTVgPO+6p6p1iZVCZpROMN-jxP7Be53_UQ@mail.gmail.com>
Message-ID: <87tvv02wpm.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Thu, Feb 01 2018, Olga Kornievskaia wrote:

> On Thu, Feb 1, 2018 at 11:23 AM, Olga Kornievskaia <aglo@umich.edu> wrote:
>> On Tue, Dec 19, 2017 at 4:15 PM, NeilBrown <neilb@suse.com> wrote:
>>> On Wed, Dec 13 2017, NeilBrown wrote:
>>>
>>>> There are 2 comments in the NFSv4 code which suggest that
>>>> SIGLOST should possibly be sent to a process.  In these
>>>> cases a lock has been lost.
>>>> The current practice is to set NFS_LOCK_LOST so that
>>>> read/write returns EIO when a lock is lost.
>>>> So change these comments to code when sets NFS_LOCK_LOST.
>>>>
>>>> One case is when lock recovery after apparent server restart
>>>> fails with NFS4ERR_DENIED, NFS4ERR_RECLAIM_BAD, or
>>>> NFS4ERRO_RECLAIM_CONFLICT.  The other case is when a lock
>>>> attempt as part of lease recovery fails with NFS4ERR_DENIED.
>>>>
>>>> In an ideal world, these should not happen.  However I have
>>>> a packet trace showing an NFSv4.1 session getting
>>>> NFS4ERR_BADSESSION after an extended network parition.  The
>>>> NFSv4.1 client treats this like server reboot until/unless
>>>> it get NFS4ERR_NO_GRACE, in which case it switches over to
>>>> "nograce" recovery mode.  In this network trace, the client
>>>> attempts to recover a lock and the server (incorrectly)
>>>> reports NFS4ERR_DENIED rather than NFS4ERR_NO_GRACE.  This
>>>> leads to the ineffective comment and the client then
>>>> continues to write using the OPEN stateid.
>>>>
>>>> Signed-off-by: NeilBrown <neilb@suse.com>
>>>> ---
>>>>
>>>> Note that I have not tested this as I do not have direct access to a
>>>> faulty NFS server.  Once I get confirmation I will provide an update.
>>>
>>> Hi,
>>>  I have now received confirmation that this change does fix the locking
>>>  behavior in this case where the server is returning the wrong error
>>>  code.
>>>
>>
>> Hi Neil,
>>
>> I'm testing your patch and in my testing it does not address the
>> issue. But I'd like to double check if my testing scenario is the
>> problem the same as what the patch suppose to address.
>>
>> My testing,
>> 1. client 1 opens a file, grabs a lock (goes to sleep so that I could
>> trigger network partition).
>> 2. wait sufficient amount of time for the client 1's state goes stale
>> on the server.
>> 3. client 2 opens the same file, and grabs the lock and starting doing
>> IO (say writing).
>> 4. plug network back into client 1. it recovers its client id and
>> session and initiates state recovery. server didn't reboot so it
>> doesn't reply with ERR_NO_GRACE to client's open and it succeeds. the
>> client sends a LOCK and gets ERR_DENIED from the server (because
>> client 2 is holding the lock now).
>> 5. client 1's app now wakes up and does IO.
>>
>> What should happen is that IO should fail. What I see is client 1
>> continues to do IO (say writing).
>>
>> Is my scenario same as yours?
>
> Sorry never mind. The OS doesn't fail any writes but internally the
> kernel fails the NFS writes with EIO and nothing is sent on the wire.
> If an fsync() is called explicitly after the write, then that fails.
> So either mount needed "sync" and then writes fail. Or application
> needs to call fsync() and then that would fail.

Yes, or O_DIRECT.  The important thing to test is: was client 1 able to
change the file on the server?  You say your tests show that it wasn't,
so no data corruption happened.  Excellent.

Thanks for testing!!

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlpzjuUACgkQOeye3VZi
gbn38RAAoOPQ2T6hYzto24pk8JU3gFl+AfFyGYOXPPZFV0ujKxbHqduxpkW+TH7C
8GgVaVljm+TSxea5uBXpR1mRHwIY4cHUmvpBBlIkycBpmMd/p7k8Ly/WglYzwyUj
UMd/kSGPaduAW0PvzBy3ELxUMghSg/73YfjdqGskiyjtqO07ErmPSGiCr0JBFAyP
pLt+PxuTkfXZrHQh622ReZPw5Zoc202lfQQG9zYZZdKjZLnjJWgkfL8IfFa+HtCG
2wHkV8Dmg3tggyMs4JxgLLdCq44aNyqLbqqrtCkmGkReUCFc55wEufnyabzJrr6T
wlczTbNbPBzU236+4k8XaFlNMI+EnTdbh0XuiTvQ6FM+XzJH4DqSWyIHFNGONovW
Bmj5HMtOlrTPVZGYLlfu4w1+S/5ANE4+RR93FfL52ETTHTbsS4hFxtNto6sBplbx
f8l1AmxeeeJDkSOcKXv617fxloeYKajsWL7rWi9lqudzE0vhH8C2kv46EpB9JCMe
FhIGFDGyBWsfZ27xo+i0k7q+taB2MCZ0nqivLTpjyKLF5jIZbkiaw2Ojw4zKphM7
ocLrgjYU6d2xHOQd80vlvNEruUrlPAACsTRJRilvor7F0V7bOZF4MmNq2s8VNVdR
tblATBElzsy3ArRVexVbZf2/f6nnIJMBQKZntBHWnsdSkU975R8=
=sOWc
-----END PGP SIGNATURE-----
--=-=-=--

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:42501 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753115AbcBJBYA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Feb 2016 20:24:00 -0500
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Date: Wed, 10 Feb 2016 12:23:40 +1100
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] SUNRPC: restore fair scheduling to priority queues.
In-Reply-To: <CAHQdGtTekchy7+6phSJikhPYk_FW4G6fuFEHy8WPn_t2iRUvEA@mail.gmail.com>
References: <87twnjb7lq.fsf@notabene.neil.brown.name> <CAHQdGtSbawsf+=uqz3D5UAPntHVKFnUgVZAYh3ym_Fs_+fHAoQ@mail.gmail.com> <874mfjay1l.fsf@notabene.neil.brown.name> <CAHQdGtTekchy7+6phSJikhPYk_FW4G6fuFEHy8WPn_t2iRUvEA@mail.gmail.com>
Message-ID: <87mvr9xsrn.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha1; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Sun, Dec 27 2015, Trond Myklebust wrote:

> On Tue, Dec 15, 2015 at 10:10 PM, NeilBrown <neilb@suse.com> wrote:
>> On Wed, Dec 16 2015, Trond Myklebust wrote:
>>
>>> On Tue, Dec 15, 2015 at 6:44 PM, NeilBrown <neilb@suse.com> wrote:
>>>>
>>>> Commit: c05eecf63610 ("SUNRPC: Don't allow low priority tasks to pre-empt higher priority ones")
>>>>
>>>> removed the 'fair scheduling' feature from SUNRPC priority queues.
>>>> This feature caused problems for some queues (send queue and session slot queue)
>>>> but is still needed for others, particularly the tcp slot queue.
>>>>
>>>> Without fairness, reads (priority 1) can starve background writes
>>>> (priority 0) so a streaming read can cause writeback to block
>>>> indefinitely.  This is not easy to measure with default settings as
>>>> the current slot table size is much larger than the read-ahead size.
>>>> However if the slot-table size is reduced (seen when backporting to
>>>> older kernels with a limited size) the problem is easily demonstrated.
>>>>
>>>> This patch conditionally restores fair scheduling.  It is now the
>>>> default unless rpc_sleep_on_priority() is called directly.  Then the
>>>> queue switches to strict priority observance.
>>>>
>>>> As that function is called for both the send queue and the session
>>>> slot queue and not for any others, this has exactly the desired
>>>> effect.
>>>>
>>>> The "count" field that was removed by the previous patch is restored.
>>>> A value for '255' means "strict priority queuing, no fair queuing".
>>>> Any other value is a could of owners to be processed before switching
>>>> to a different priority level, just like before.
> <snip>
>>> Are we sure there is value in keeping FLUSH_LOWPRI for background writes?
>>
>> There is currently also FLUSH_HIGHPRI for "for_reclaim" writes.
>> Should they be allowed to starve reads?
>>
>> If you treated all reads and writed the same, then I can't see value in
>> restoring fair scheduling.   If there is any difference, then I suspect
>> we do need the fairness.
>
> I disagree. Reclaiming memory should always be able to pre-empt
> "interactive" features such as read. Everything goes down the toilet
> when we force the kernel into situations where it needs to swap.

That's your call I guess.  I certainly agree that memory-reclaim writes
should get some priority (e.g. two writes serviced for every read).
Whether they should be allowed to completely block reads I'm less sure
of.  But it is probably purely academic as if the system is busy
reclaiming you are unlikely to have any reads to want to send.

My problem would be solved (I think) by treating reads and non-reclaim
writes as equals.  I'll make a patch, see if I can test it, and let you
know.

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJWupEcAAoJEDnsnt1WYoG5VRoQAIkcwzN3mAv4M0KKQ2WcVjXE
XZgciLFadsaON9lfBiKw0Yq8z5Pu6OiednhXqYUdeESmLgWWjs6VvtoGp7VnR8wh
DF9QZLiQ2b24jni4MmI1s8VqP2ViEHFgTWxAZzsdv0tRIPbcQKGz917jjGSVfIsM
CojqcWcWMr89x4x4EBhrQ7thp1skDANPb6C4dtmkIl9YCBqgtovK9E47ub0kxfHb
w7wElhdIMPc2zFkuCFSunFzy2UOgbqLp/bmd6IycnogY3BgK1Ogqejsf9mZFew6N
U3R9yajxMF9P0X1GyxwLvo6Z7HQmam/C4cGBNECwYaLw3WgWzC+jQuD36m6uFiHA
vfDLRGMrsSg8z/38gr53Lvchh/xvU/uofuSQIv+9nrsXG1tiqnHi+Jtq0CZyIPGm
TKtQu5CKgmd01CPqI9Ik0fJvEhqR+Lc1XdSWTNPndCuIXgJa/T9A6aqNRZw3Wj4k
MNMeH+Twswbh/n3sRpdy0a2eZvmdGZOaFRdOfOehAvIQT/qwhxhE0EmN8GEntPZB
HJfK7TBtlOq/vhuWkuHFELJIHqx9D8fsxIv8dx/IGblqo1voussMicgn8x63iKko
A062byX1NbPnWxQBpbsi26pbMlycXLp/f8AAsJuCHAKQoB2Usa7GiKjDmZcRaKgl
BIWp/WyL7g7ccb3ZBnEz
=QXJb
-----END PGP SIGNATURE-----
--=-=-=--

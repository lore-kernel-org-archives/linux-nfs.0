Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:33890 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754559AbeBABn7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 31 Jan 2018 20:43:59 -0500
From: NeilBrown <neilb@suse.com>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Date: Thu, 01 Feb 2018 12:43:49 +1100
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 02/20] SUNRPC: add 'struct cred *' to auth_cred and rpc_cred
In-Reply-To: <87wp015h4c.fsf@notabene.neil.brown.name>
References: <151538903497.25812.13293229343061416612.stgit@noble> <151538917875.25812.10005878132438571890.stgit@noble> <ea9fad0d-a718-aba8-3dd1-042644577c81@Netapp.com> <3cfc2eb8-68c9-6c26-d5eb-21f50ca921e5@Netapp.com> <87wp015h4c.fsf@notabene.neil.brown.name>
Message-ID: <87607h4h7u.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, Jan 29 2018, NeilBrown wrote:

> On Thu, Jan 18 2018, Anna Schumaker wrote:
>
>> On 01/18/2018 01:39 PM, Anna Schumaker wrote:
>>> Hi Neil,
>>>=20
>>> On 01/08/2018 12:26 AM, NeilBrown wrote:
>>>> The SUNRPC credential framework was put together before
>>>> Linux has 'struct cred'.  Now that we have it, it makes sense to
>>>> use it.
>>>> This first step just includes a suitable 'struct cred *' pointer
>>>> in every 'struct auth_cred' and almost every 'struct rpc_cred'.
>>>>
>>>> The rpc_cred used for auth_null has a NULL 'struct cred *' as nothing
>>>> else really makes sense.
>>>>
>>>> For rpc_cred, the pointer is reference counted.
>>>> For auth_cred it isn't.  struct auth_cred are either allocated on
>>>> the stack, in which case the thread owns a reference to the auth,
>>>> or are part of 'struct generic_cred' in which case gc_base owns the
>>>> reference and acred shares it.
>>
>> This patch is also causing a kernel panic for me if I mount using sec=3D=
krb5, run cthon tests, and then unmount.  Here is the log message I'm getti=
ng:
>>
>> [   82.599174] Kernel panic - not syncing: CRED: put_cred_rcu() sees 000=
00000f5847a57 with usage -1
>> [   82.599174]
>> [   82.600227] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.15.0-rc7-ANNA=
+ #14336
>> [   82.600801] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
>> [   82.601435] Call Trace:
>> [   82.601639]  <IRQ>
>> [   82.601830]  dump_stack+0x5c/0x7e
>> [   82.602125]  panic+0xdf/0x228
>> [   82.602383]  ? try_to_wake_up+0x24b/0x420
>> [   82.602853]  put_cred_rcu+0x8a/0x90
>> [   82.603183]  rcu_process_callbacks+0x1ab/0x4f0
>> [   82.603577]  __do_softirq+0xcc/0x305
>> [   82.603881]  irq_exit+0xa9/0xb0
>> [   82.604159]  smp_apic_timer_interrupt+0x5b/0x140
>> [   82.604528]  apic_timer_interrupt+0x98/0xa0
>> [   82.604892]  </IRQ>
>> [   82.605133] RIP: 0010:native_safe_halt+0x2/0x10
>> [   82.605678] RSP: 0018:ffffffff82003ea8 EFLAGS: 00000246 ORIG_RAX: fff=
fffffffffff11
>> [   82.606619] RAX: 0000000080000000 RBX: 0000000000000000 RCX: 00000000=
00000000
>> [   82.607270] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 00000000=
00000000
>> [   82.608077] RBP: 0000000000000000 R08: 0000000000000002 R09: 00000000=
0001ea40
>> [   82.609066] R10: 0000000000000001 R11: 0000000000000000 R12: 00000000=
00000000
>> [   82.609951] R13: 0000000000000000 R14: 0000000000000000 R15: 00000000=
00000000
>> [   82.610771]  default_idle+0x15/0x120
>> [   82.611128]  do_idle+0x15c/0x1c0
>> [   82.611371]  cpu_startup_entry+0x6a/0x70
>> [   82.611762]  start_kernel+0x445/0x465
>> [   82.612104]  secondary_startup_64+0xa5/0xb0
>> [   82.612561] Kernel Offset: disabled
>> [   82.612862] ---[ end Kernel panic - not syncing: CRED: put_cred_rcu()=
 sees 00000000f5847a57 with usage -1
>> [   82.612862]
>>
>
> That's not good.
>
> I've just read through the patches again and didn't find anything that
> could cause this, so I must have missed something.
>
> You say "This patch is also causing", but I assume it is the whole patch
> set rather than just this one patch -  is that correct?
>
> Also, have you run tests without sec=3Dkrb5 and not had the error?
>
> I'll try to set up some more thorough testing myself.

I found the problem.
The crdestroy for auth_gss takes a new reference on the auth,
and then releases it again.
As I was calling put_auth() on ->cr_auth before calling crdestrory,
it got put twice.
I've move the responsibility for calling put_auth() into the crdestroy
function.
It now passes connectathon with krb5 and krb5p and without, etc.

I'll resend the series sometime next week, hopefully after getting some
sort of response to the cred-improvement patches I posted.

Thanks for your help,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlpycNYACgkQOeye3VZi
gbm5ABAAwmFRddoVP+GXk0JyJjYkQJVnKDzvGkBpLx/BlD/5XXJxWXcSkXG+zy4G
KqwqpxaQQd3ORktAuvqOFF4G17QLj3o249bNQfzWa4wmeHanNuIkanSqGRI7tj3B
qFU9zGM9xzKXeo3EX0s3SCP5pjQCUq0MKccsRZVXg4os8QEpG5uEl6Ij/aIKiTPC
aXePera0zE+MKe689qc4lJXJ46772ttRrb0gArn2LO81DMpGJA3S/WWtfs3J2D/e
89T2eicGNqLbyL9+u+Jvbpf1JvKa9dA4VqCcdK1jkdkUcwrlugWiuFVKbdOlyKF/
dE0KhtlKuJBDKYbk8tNFZ+PxvNVTm+WXAFQvIqPo8rTsdxe0/qOafVZTu3tOPnLG
zZWT3sBeA9mCCZmVbylvCWn85CEni2TFB3+gY5vOh/9dhxIu3PKSAfkp5Y6kr0x1
VjCPdhfHDP1Q/np2x0XruLjYq4J/FfkVhja+0/NjLf2KToIxU7nOY5VCLpS60nMu
N04WgGB3eOWjzyd7Bb+F23e0mfHdBhhH5HG26gAc28kDaOiIi0Er8U5yYDSLJlaG
vFPcO1O7cHwzNUOL1fkKfVeZ7En4cmgRe3ohwdV5KYTUvo3h8I+NYOmkPSiEbn7Z
tZxOOG7wp+M8pyAoeAi4rwmsPiCpdBWv56X7q6vgUhmI5SHZkEA=
=Onp4
-----END PGP SIGNATURE-----
--=-=-=--

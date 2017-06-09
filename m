Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:42033 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751560AbdFIWCG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 9 Jun 2017 18:02:06 -0400
From: NeilBrown <neilb@suse.com>
To: Lutz Vieweg <lvml@5t9.de>, linux-nfs@vger.kernel.org
Date: Sat, 10 Jun 2017 08:01:57 +1000
Subject: Re: PROBLEM: nfs I/O errors with sqlite applications
In-Reply-To: <593A8011.4080501@5t9.de>
References: <20151012164846.GA5017@draconx.ca> <20151012192538.GG28755@fieldses.org> <20151012194647.GJ28755@fieldses.org> <20151013030136.GA7081@draconx.ca> <20151013065225.44c5581d@synchrony.poochiereds.net> <CADyTPEyUKNdYuj0LwoX-r6jJJ0tEufwyA_mEKE=OVniX9rXPog@mail.gmail.com> <CADyTPEx=h95ODeG3BixMHc=kxLmkFt+aVyS+V_bK-b=CqK4_6Q@mail.gmail.com> <1469814735.19411.1.camel@poochiereds.net> <5936DC7B.8040804@5t9.de> <87vao8bilj.fsf@notabene.neil.brown.name> <59399945.2020507@5t9.de> <871squb0bo.fsf@notabene.neil.brown.name> <593A8011.4080501@5t9.de>
Message-ID: <87y3t095wq.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Fri, Jun 09 2017, Lutz Vieweg wrote:

> On 06/09/2017 12:07 AM, NeilBrown wrote:
>> But "soft" is generally a bad idea.  It can lead to data corruption in
>> various way as it ports errors to user-space which user-space is often
>> not expecting.
>
>  From reading "man 5 nfs" I understood the one situation in which this
> option makes a difference is when the NFS server becomes unavailable/unre=
achable.

Exactly - which should be independent of whether you use NFSv3 or
NFSv4...
The only case where NFSv3 vs NFSv4 would make a difference is if the
server starts misbehaving in some way that only affects one protocol.
This is exactly what happened to you.  The misbehaviour of rpcbind only
affects NFSv3.  NFSv4 wouldn't have noticed :-)

>
> With "hard" user-space applications will wait indefinitely in the hope
> that the NFS service will become available again.
>
> I see that if there was only some temporary glitch with connectivity
> to the NFS server, this waiting might yield a better outcome - but that
> should be covered by the timeout grace periods anyway.

"should be".  Servers and networks can get congested and take longer to
reply than you would expect.  Unless the total timeout is long enough
to notice and get annoyed and frustrated about, it probably isn't long
enough to cover all transient conditions.
>
> But if:
>
> - An unreachability of the service persists for a very long time,
>    it is bad that it will take a very long time for any monitoring
>    of the applications on the server to notice that this is no longer
>    a tolerable situation, so some sort of fail-over to different applicat=
ion
>    instances need to be triggered
>
> - The unavailability/unreachability of the service is resolved by rebooti=
ng
>    the NFS server, chances are that the files are then in a different sta=
te
>    than before (due to reverting to the last known consistent state of
>    the local filesystem on the server), and in that situation I don't
>    want to fool the client into thinking that everything I/O-wise is fine=
 -
>    better signal an error to make the application aware of the
>    situation

This isn't (or shouldn't be) a valid concern.  Any changes that the
client isn't certain are stable and consistent on the server, will be
resent after a server reboot.
If the server catches fire and you restore from yesterday's backups,
then you might have an issue here - but in that case you'd almost
certainly want to restart all client services anyway.

>
> - The unavailability/unreachability of the service is unresolvable, becau=
se
>    the primary NFS server died completely, then the files will clearly be
>    in a different state once a secondary service is brought up - and a
>    "kill -9" on all the processes waiting for NFS-I/O seems equally likely
>    to me to cause the applications trouble than returning an error on
>    the pending I/O operations.

A "kill -9" cannot be ignored, while IO errors can.  If your application
cannot cope with kill -9, it needs to be fixed or replaced.

>
>> These days, the processes in D state are (usually) killable.
>
> If that is true for processes waiting on (hard) mounted NFS services,
> that is really appreciated and good to know. It would certainly help
> us next time we try a newer NFS protocol release :-)

You mean "next time we try with the 'hard' mount option".

>
> (BTW: I recently had to reboot a machine because processes who
> waited for access to a long-removed USB device persisted in D-state...
> and were immune to "kill -9". So at least the USB driver subsystem
> seems to still contain such pitfalls.)

This isn't surprising.  It is easy to trigger NFS related problems, so
developers get annoyed and eventually something gets fixed.
It is much less common to hit these problems with USB device, so
developers don't get annoyed.
A concrete bug report might result in improvements, but I cannot promise.

>
>> Thanks. Probably the key line is
>>
>> [2339904.695240] RPC: 46702 remote rpcbind: RPC program/version unavaila=
ble
>>
>> The client is trying to talk to lockd on the server, and lockd doesn't
>> seem to be there.
>
> "ps" however says there is a process of that name running on that server:
>> USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
>> root      3753  0.0  0.0      0     0 ?        S    May26   0:02  \_ [lo=
ckd]
>
> Your assumption:
>> My guess is that rpcbind was restarted with the "-w" flag, so it lost
>> all the state that it previosly had.
> seems to be right:
>
>> > systemctl status rpcbind
>> =E2=97=8F rpcbind.service - RPC bind service
>>    Loaded: loaded (/usr/lib/systemd/system/rpcbind.service; enabled; ven=
dor preset: enabled)
>>    Active: active (running) since Wed 2017-05-31 10:06:05 CEST; 1 weeks =
2 days ago
>>   Process: 14043 ExecStart=3D/sbin/rpcbind -w $RPCBIND_ARGS (code=3Dexit=
ed, status=3D0/SUCCESS)
>>  Main PID: 14044 (rpcbind)
>>    CGroup: /system.slice/rpcbind.service
>>            =E2=94=94=E2=94=8014044 /sbin/rpcbind -w
>>
>> May 31 10:06:05 myserver systemd[1]: Starting RPC bind service...
>> May 31 10:06:05 myserver systemd[1]: Started RPC bind service.
>
> If that kind of invocation is known to cause trouble, I wonder why
> RedHat/CentOS chose to make it wath seems to be their default...

Sorry - typo on my part.  I should have say "was restarted withOUT the
=2Dw flag".  This configuration of rpcbind appears to be correct.

However.....
rpcbind stores its state in a file.  Until about 6 months ago, the
upstream rpcbind would use a file in /tmp.  Late last year we changed
the code to use a file in /var/run.

When a distro updates to the newer version with a different location,
they *should*
 - stop the running rpcbind
 - copy the state file from /tmp/ to /var/run
 - start rpcbind

If this sequence isn't followed, you will get exactly the symptoms you
report.  That might be what happened.

>
>> If you stop and restart NFS service on the server, it might start
>> working again.  Otherwise just reboot the nfs server.
>
> A "systemctl stop nfs ; systemctl start nfs" was not sufficent, only chan=
ged the symptom:
>> sqlite3 x.sqlite "PRAGMA case_sensitive_like=3D1;PRAGMA synchronous=3DOF=
F;PRAGMA recursive_triggers=3DON;PRAGMA foreign_keys=3DOFF;PRAGMA locking_m=
ode =3D NORMAL;PRAGMA journal_mode =3D TRUNCATE;"
>> Error: database is locked

By "stop NFS service on the server" I meant
  systemctl restart nfs-server
or something like that.  "nfs" is more client-side than server-side.

However you seem have have got things working again, and that is the
important thing.

You might like to report the (possible) upgrade bug to Fedora, though
maybe someone responsible is listening on the list.
(Hm... I should probably go make sure that openSUSE does the right thing
here...).

NeilBrown



>
> On the server, at the same time, the following message is emitted to the =
system log:
>> Jun  9 12:53:57 myserver kernel: lockd: cannot monitor myclient
>
> What did help, however, was running:
>> systemctl stop rpc-statd ; systemctl start rpc-statd
> on the server.
>
> So thanks for your analysis! - We now know a way to remove the symptom
> with relatively little disturbance of services.
>
> Should we somehow try to get rid of that "-w" to rpcbind, in an attempt
> to not re-trigger the symptom at a later time?
>
> Regards,
>
> Lutz Vieweg

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlk7GtcACgkQOeye3VZi
gblRpQ/+PJIYyAH8as7ovU4KXpp7/AYGiWDk8wHx2Ayzl3o0TdKDZb74ID8pPF7W
kUOdnerMRhuFTf1TaAkp3zry/r3OIKTC5hzScKNesyUqtOAFwlnsssQUnpLkNdGY
o1dQGV2K4D6fwnzingR52EPmEueFNymyNkNelBH7vKW/TZ7mtLIFUWipzG7gMDEA
yux78xbA3xWpe0gUa50xzsn4bOAl13cWVSOl2g8ZD3P/k4uy7hg3KTNKZimd5nt9
L0yEmgpPW51c48LyCioG5bwtVmZenJC3Bo3zJ/OoSpsy867nqz4Y6ULThNtgg/wS
7UR20iZAtt+Y9aj+tt6oExmD05P/W7s2E19t8i330wV5jNBS8D3gM/K+C2wRFSs5
dbj+TiPdWTt4RrH5M+/ZCa8mi76bRMeqOAMGgAQjO+hJz9fhbG6WyIID2Zdh+QQ2
LcLj6K+O/VKRkawTxYv/NTCWxfCnVIpFXR3pYn/SSZ5F7OaeaOPnEjgCxMJLb4Hn
MYyIH4e1Sv5GURjPHbG9WD4PXdRf3bhHZ/hJeYS8tEpemWjvBY3wzLZpQMf039Jm
t/bxjPsR3GLx+Ep8Hacy+B8nJEGDYiwp9hSsIkZEfSmmGYfybnUHsNOCzlF5whki
M1qB8InikByR93x7ma3gdRmlkY1y/+Ndd6BAuJT48s1d8n9lT0k=
=iD0t
-----END PGP SIGNATURE-----
--=-=-=--

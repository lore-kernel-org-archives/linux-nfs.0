Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:34580 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752475AbdFHFRE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 8 Jun 2017 01:17:04 -0400
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@RedHat.com>,
        Lennart Poettering <mzxreary@0pointer.de>
Date: Thu, 08 Jun 2017 15:16:52 +1000
Cc: systemd-devel@freedesktop.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs.man: document incompatibility between "bg" option and systemd.
In-Reply-To: <ce5c37b4-a81b-4eaf-c1ac-7f36488bdaa9@RedHat.com>
References: <87lgpkgwrw.fsf@notabene.neil.brown.name> <20170529133814.GC17967@gardel-login> <87tw43fgrf.fsf@notabene.neil.brown.name> <89415cad-331e-bac6-7fd1-dffa058726de@RedHat.com> <87lgp4dbx7.fsf@notabene.neil.brown.name> <2a7fd6d4-a965-02e0-3b7b-97c5743d7083@RedHat.com> <20170607120221.GJ27006@gardel-login> <ce5c37b4-a81b-4eaf-c1ac-7f36488bdaa9@RedHat.com>
Message-ID: <87mv9jawjf.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Wed, Jun 07 2017, Steve Dickson wrote:

> On 06/07/2017 08:02 AM, Lennart Poettering wrote:
>> On Wed, 07.06.17 06:08, Steve Dickson (SteveD@RedHat.com) wrote:
>>=20
>>>
>>>
>>> On 06/06/2017 05:49 PM, NeilBrown wrote:
>>>> On Tue, Jun 06 2017, Steve Dickson wrote:
>>>>
>>>>> Hello,
>>>>>
>>>>> On 05/29/2017 06:19 PM, NeilBrown wrote:
>>>>>>
>>>>>> Systemd does not, and will not, support "bg" correctly.
>>>>>> It has other, better, ways to handle "background" mounting.
>>>>> The only problem with this is bg mounts still work at least
>>>>> up to 4.11 kernel...=20
>>>>
>>>> I don't think this is correct.
>>>> In the default configuration, "mount -t nfs -o bg ...."
>>>> runs for longer than 90 seconds, so systemd kill it.
>>> I must be missing something... it seems to be working for me
>>>
>>> # mount -vvv -o bg rhel7srv:/home/tmp /mnt/tmp
>>> mount.nfs: trying text-based options 'bg,vers=3D4.1,addr=3D172.31.1.60,=
clientaddr=3D172.31.1.58'
>>> mount.nfs: mount(2): Connection refused
>>> mount.nfs: trying text-based options 'bg,addr=3D172.31.1.60'
>>> mount.nfs: prog 100003, trying vers=3D3, prot=3D6
>>> mount.nfs: trying 172.31.1.60 prog 100003 vers 3 prot TCP port 2049
>>> mount.nfs: portmap query failed: RPC: Remote system error - Connection =
refused
>>> mount.nfs: backgrounding "rhel7srv:/home/tmp"
>>> mount.nfs: mount options: "rw,bg"
>>=20
>> We are talking about mounts done through /etc/fstab, i.e. the ones
>> systemd actually manages.
> I guess I was not clear... After adding a bg mount to fstab and
> reboot, mounting a server that is not up, there is a mount in
> background that looks like=20
>
> # ps ax | grep mount
>  1104 ?        Ss     0:00 /sbin/mount.nfs nfssrv:/home/tmp /mnt/tmp -o r=
w,bg
>
> Looking at the remote-fs.target status:
>
> # systemctl status remote-fs.target=20
> * remote-fs.target - Remote File Systems
>    Loaded: loaded (/usr/lib/systemd/system/remote-fs.target; enabled; ven=
dor preset: enabled)
>    Active: active since Tue 2017-06-06 12:36:51 EDT; 12min ago
>      Docs: man:systemd.special(7)
>
> Jun 06 12:36:51 f26.boston.devel.redhat.com systemd[1]: Reached target Re=
mote File Systems.
>
> It appears to be successful=20

Strange ... not for me.

I have a recent compiled-from-source upstream systemd and a very recent
upstream kernel.

I add a line to /etc/fstab

 192.168.1.111:/nowhere /mnt nfs bg 0 0

and reboot (192.168.1.111 is on a different subnet to the VM I am
testing in, but no host responds to the address).

There is a 1m30s wait while trying to mount /mnt, then boot completes
(I was wrong when I said that it didn't).

=E2=97=8F mnt.mount - /mnt
   Loaded: loaded (/etc/fstab; generated; vendor preset: enabled)
   Active: failed (Result: timeout) since Thu 2017-06-08 11:13:52 AEST; 1mi=
n 24s ago
    Where: /mnt
     What: 192.168.1.111:/nowhere
     Docs: man:fstab(5)
           man:systemd-fstab-generator(8)
  Process: 333 ExecMount=3D/bin/mount 192.168.1.111:/nowhere /mnt -t nfs -o=
 bg (code=3Dkilled, signal=3DTERM)

Jun 08 11:12:22 debian systemd[1]: Mounting /mnt...
Jun 08 11:13:52 debian systemd[1]: mnt.mount: Mounting timed out. Stopping.
Jun 08 11:13:52 debian systemd[1]: mnt.mount: Mount process exited, code=3D=
killed status=3D15
Jun 08 11:13:52 debian systemd[1]: Failed to mount /mnt.
Jun 08 11:13:52 debian systemd[1]: mnt.mount: Unit entered failed state.


The /bin/mount process has been killed (SIGTERM) after the 90 second
timeout

=E2=97=8F remote-fs.target - Remote File Systems
   Loaded: loaded (/lib/systemd/system/remote-fs.target; enabled; vendor pr=
eset: enabled)
  Drop-In: /run/systemd/generator/remote-fs.target.d
           =E2=94=94=E2=94=8050-insserv.conf.conf
   Active: inactive (dead)
     Docs: man:systemd.special(7)

Jun 08 11:13:52 debian systemd[1]: Dependency failed for Remote File System=
s.
Jun 08 11:13:52 debian systemd[1]: remote-fs.target: Job remote-fs.target/s=
tart failed with result 'dependency'.


remote-fs.target has not been reached.

Because remote-fs.target is WantedBy multi-user.target, but need
RequiredBy it, boot completes.
But if anything did Require remote-fs.target, it would fail if "bg"
mounts were not mounted within 90 seconds.


Looking back over your log messages:

>>> mount.nfs: portmap query failed: RPC: Remote system error - Connection =
refused
>>> mount.nfs: backgrounding "rhel7srv:/home/tmp"

it appears that the fg mount attempt failed quickly (ECONNREFUSED), so it
background the process immediately.  Systemd sees that as success
(despite the fact that the filesystem isn't actually mounted) and
doesn't clean up the background processes (which is arguably a bug).

If you try to mount from a server which doesn't even return ECONNREFUSED or
EHOSTUNREACH, such that the first mount attempt takes longer than 90
seconds, then you should get the same results as me.

Your results go some way to explaining why Lennart hasn't received many
complaints, but I'm convinced that the current situation is not ideal
(because SUSE has received some complaints).

I've been pondering the possibility of making "bg" work properly with
systemd and I think I've found a promising approach.  It involves having
systemd take responsibility for the "run in the background" part.

If we get systemd-fstab-generator to translate "bg" to "retry=3D10000",
then "mount.nfs" will behave like the background version of
"mount.nfs -o bg".  i.e. it will retry for one month (nearly).   If there is
already a 'retry=3D' option, we just strip the "bg".

For this to work, we would need to add
   TimeoutSec=3Dinfinity
to the .mount unit file so that systemd doesn't kill the mount.
We would also need to add (the effect of) "nofail", so that systemd
doesn't wait for the mount to complete...
Except that the current implementation of "nofail" is faulty.
It removes the default "Before=3Dremote-fs.mount", which has the unwanted
consequence of unmounting the filesystem too early at shutdown.

I have a solution for that too (which I'll submit a push request for
shortly).
My solution to "nofail" is to treat it much like "automount", but
instead of using an automount unit to trigger the mount, we use
a timer unit (with OnActiveSec=3D0).
By triggering the mount unit with a timer instead of Wanting it
directly, it gets run in a separate transaction.  This means that the
"Before=3Dremote-fs.target" doesn't have the effect of delaying
remote-fs.target.  Before/After only order jobs within the one
transaction.
When it comes time to shutdown, remote-fs.target and the foo.mount will
be in the same transaction, so the Before=3D will ensure foo.mount
isn't unmounted until after remote-fs.target has been allows to finish,
which is after any services that might be using the filesystem.

So I think I've found a solution for systemd to handle "bg" nfs mounts
correctly.   I'll submit some pull requests for consideration.

Thanks,
NeilBrown

=20=20=20

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlk43cYACgkQOeye3VZi
gbk0wxAAmKKIIi7I8dGO1UOQO1t4eslkxFbH+wiYJZ8ANNfRfj4UkaFsg+ZCZ5o7
nznY/qOiNlR8k7nCqj35lxOLsSHoaM87h5ATo20TSmOgWgWMQ0doBfhyg5H1rt1v
tq+qxeHcSF3pM/EJHpoFT0IQ2JabfRHyXeDy+MVSS37xbSCo8pCp0kmS8OfQSMN4
mGJ/FlLKTdGCh+XWU+aWfqtlMIc1mEbBHTTKRxdMrFg+HCwoFKrdKIi2tiAXjOCh
I5Q8tDwTADb6dnYp1VZBxs8QBdc6ekMj82iYb2yp1ESLHaSc58TRTNDf/2YNYJ6G
mSsJPyMxR81BOz9enXGxRYUZ6L0deiGFGc9mLi6/euLfyWXqGtDM4ondX9lqgZtM
62mp8/ZsXK6hAT3qWDaLNrXg+08N95Au19HDkRt/LvOWBGUgcAKoFoHkJ92aJjiZ
uyNITodxfRjBGumVkPY7xW4kKXj3SytOeuSpn+cNaxxUn/2Zv5Xn38/O7f6aRnvw
CGQovKTBptv6oikCIDqEhxwTbdOVkhLgJc7xBIyS0SS1dWMUHZ/OEUKnCgtSC//g
1ii7jmGICRCsUcAcdhzxp1xyby2anWLIkw6mPHh3VtqW6uQoXfS276iP+pqondi6
VJiN569S0hRrIwTuCvNVrYlBLF99whV6TPToMzcz6sxlTfDHVbc=
=nh5D
-----END PGP SIGNATURE-----
--=-=-=--

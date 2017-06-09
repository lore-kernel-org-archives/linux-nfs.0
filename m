Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.162]:31382 "EHLO
        mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751530AbdFILBp (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Jun 2017 07:01:45 -0400
Message-ID: <593A8011.4080501@5t9.de>
Date: Fri, 09 Jun 2017 13:01:37 +0200
From: Lutz Vieweg <lvml@5t9.de>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.com>, linux-nfs@vger.kernel.org
Subject: Re: PROBLEM: nfs I/O errors with sqlite applications
References: <20151012164846.GA5017@draconx.ca> <20151012192538.GG28755@fieldses.org> <20151012194647.GJ28755@fieldses.org> <20151013030136.GA7081@draconx.ca> <20151013065225.44c5581d@synchrony.poochiereds.net> <CADyTPEyUKNdYuj0LwoX-r6jJJ0tEufwyA_mEKE=OVniX9rXPog@mail.gmail.com> <CADyTPEx=h95ODeG3BixMHc=kxLmkFt+aVyS+V_bK-b=CqK4_6Q@mail.gmail.com> <1469814735.19411.1.camel@poochiereds.net> <5936DC7B.8040804@5t9.de> <87vao8bilj.fsf@notabene.neil.brown.name> <59399945.2020507@5t9.de> <871squb0bo.fsf@notabene.neil.brown.name>
In-Reply-To: <871squb0bo.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/09/2017 12:07 AM, NeilBrown wrote:
> But "soft" is generally a bad idea.  It can lead to data corruption in
> various way as it ports errors to user-space which user-space is often
> not expecting.

 From reading "man 5 nfs" I understood the one situation in which this
option makes a difference is when the NFS server becomes unavailable/unre=
achable.

With "hard" user-space applications will wait indefinitely in the hope
that the NFS service will become available again.

I see that if there was only some temporary glitch with connectivity
to the NFS server, this waiting might yield a better outcome - but that
should be covered by the timeout grace periods anyway.

But if:

- An unreachability of the service persists for a very long time,
   it is bad that it will take a very long time for any monitoring
   of the applications on the server to notice that this is no longer
   a tolerable situation, so some sort of fail-over to different applicat=
ion
   instances need to be triggered

- The unavailability/unreachability of the service is resolved by rebooti=
ng
   the NFS server, chances are that the files are then in a different sta=
te
   than before (due to reverting to the last known consistent state of
   the local filesystem on the server), and in that situation I don't
   want to fool the client into thinking that everything I/O-wise is fine=
 -
   better signal an error to make the application aware of the situation

- The unavailability/unreachability of the service is unresolvable, becau=
se
   the primary NFS server died completely, then the files will clearly be=

   in a different state once a secondary service is brought up - and a
   "kill -9" on all the processes waiting for NFS-I/O seems equally likel=
y
   to me to cause the applications trouble than returning an error on
   the pending I/O operations.

> These days, the processes in D state are (usually) killable.

If that is true for processes waiting on (hard) mounted NFS services,
that is really appreciated and good to know. It would certainly help
us next time we try a newer NFS protocol release :-)

(BTW: I recently had to reboot a machine because processes who
waited for access to a long-removed USB device persisted in D-state...
and were immune to "kill -9". So at least the USB driver subsystem
seems to still contain such pitfalls.)

> Thanks. Probably the key line is
>
> [2339904.695240] RPC: 46702 remote rpcbind: RPC program/version unavail=
able
>
> The client is trying to talk to lockd on the server, and lockd doesn't
> seem to be there.

"ps" however says there is a process of that name running on that server:=

> USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAN=
D
> root      3753  0.0  0.0      0     0 ?        S    May26   0:02  \_ [l=
ockd]

Your assumption:
> My guess is that rpcbind was restarted with the "-w" flag, so it lost
> all the state that it previosly had.
seems to be right:

> > systemctl status rpcbind
> =E2=97=8F rpcbind.service - RPC bind service
>    Loaded: loaded (/usr/lib/systemd/system/rpcbind.service; enabled; ve=
ndor preset: enabled)
>    Active: active (running) since Wed 2017-05-31 10:06:05 CEST; 1 weeks=
 2 days ago
>   Process: 14043 ExecStart=3D/sbin/rpcbind -w $RPCBIND_ARGS (code=3Dexi=
ted, status=3D0/SUCCESS)
>  Main PID: 14044 (rpcbind)
>    CGroup: /system.slice/rpcbind.service
>            =E2=94=94=E2=94=8014044 /sbin/rpcbind -w
>
> May 31 10:06:05 myserver systemd[1]: Starting RPC bind service...
> May 31 10:06:05 myserver systemd[1]: Started RPC bind service.

If that kind of invocation is known to cause trouble, I wonder why
RedHat/CentOS chose to make it wath seems to be their default...

> If you stop and restart NFS service on the server, it might start
> working again.  Otherwise just reboot the nfs server.

A "systemctl stop nfs ; systemctl start nfs" was not sufficent, only chan=
ged the symptom:
> sqlite3 x.sqlite "PRAGMA case_sensitive_like=3D1;PRAGMA synchronous=3DO=
FF;PRAGMA recursive_triggers=3DON;PRAGMA foreign_keys=3DOFF;PRAGMA lockin=
g_mode =3D NORMAL;PRAGMA journal_mode =3D TRUNCATE;"
> Error: database is locked

On the server, at the same time, the following message is emitted to the =
system log:
> Jun  9 12:53:57 myserver kernel: lockd: cannot monitor myclient

What did help, however, was running:
> systemctl stop rpc-statd ; systemctl start rpc-statd
on the server.

So thanks for your analysis! - We now know a way to remove the symptom
with relatively little disturbance of services.

Should we somehow try to get rid of that "-w" to rpcbind, in an attempt
to not re-trigger the symptom at a later time?

Regards,

Lutz Vieweg


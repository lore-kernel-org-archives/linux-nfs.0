Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:38306 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753537AbeBFXew (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 6 Feb 2018 18:34:52 -0500
From: NeilBrown <neilb@suse.com>
To: Chuck Lever <chuck.lever@oracle.com>,
        Steve Dickson <SteveD@RedHat.com>
Date: Wed, 07 Feb 2018 10:34:41 +1100
Cc: Naruto Nguyen <narutonguyen2018@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Question about random UDP port on rpcbind 0.2.3
In-Reply-To: <1165B44B-0D40-42FF-94EE-9B852AD4C8FA@oracle.com>
References: <CANpxKHE=eKuFc2HBgT0aqDb+Q5EOFWOfCzf=tmmuH7zNyn878g@mail.gmail.com> <CANpxKHH3zf_RRnxckHKfvEWL-RNCr_ZePxc0r98Ep0X_JX1BbA@mail.gmail.com> <47c040cf-d0a8-eb42-a276-9bc2e264ff6e@RedHat.com> <66B30606-7AFE-43C8-8A51-5D031F9D744B@oracle.com> <27ec9304-5763-9885-b3c9-246c395e6986@RedHat.com> <1165B44B-0D40-42FF-94EE-9B852AD4C8FA@oracle.com>
Message-ID: <87k1vpofou.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, Jan 31 2018, Chuck Lever wrote:

>> On Jan 31, 2018, at 2:57 PM, Steve Dickson <SteveD@RedHat.com> wrote:
>>=20
>>=20
>>=20
>> On 01/31/2018 02:43 PM, Chuck Lever wrote:
>>>=20
>>>=20
>>>> On Jan 31, 2018, at 2:31 PM, Steve Dickson <SteveD@RedHat.com> wrote:
>>>>=20
>>>>=20
>>>>=20
>>>> On 01/29/2018 01:44 AM, Naruto Nguyen wrote:
>>>>> Hello,
>>>>>=20
>>>>> Just would like to add for more information, when I start rpcbind
>>>>> normally, not via systemd, the random UDP is still opened
>>>>>=20
>>>>> Could you please share any ideas on this?
>>>> The bound UDP socket is used for remote calls... Where rpcbind
>>>> is asked to make a remote RPC for another caller...=20
>>>>=20
>>>> Antiquated? yes.. but harmless.
>>>=20
>>> Not quite harmless. It can occupy a privileged port that belongs
>>> to a real service.
>> fair enough...=20
>>=20
>>>=20
>>> We should change rpcbind to retain CAP_NET_BIND_SERVICE, so that
>>> it doesn't have to hold onto that port indefinitely. It should
>>> be able to bind to an outgoing privileged port whenever it needs
>>> one.
>> Or we just avoid know ports like sm-notify does.
>
> statd, you mean. It should also retain CAP_NET_BIND_SERVICE instead
> of what it does now, IMO.
>
> Note that in both of these cases, that long-lived port is never going
> to be used, going forward:=20
>
> - no one uses the rpcbind port-forward service that I know of

  ypbind --broadcast
??

I don't see a problem with adding an option to disable it.
I don't think it is harmful enough to make that option the default
(though individual distributors might choose to add the command-line
flag by default).

>
> - NLM is going out of style

"style" isn't a word that I would use with NLM :-)
but I suspect NLM will still be used for some time yet.

>
> If we can make these two cases on-demand instead, so much the better,
> I say. As Mr. Talpey pointed out recently, the only long-lived
> privileged ports we should see on Linux are well-known service
> listeners, not outgoing ports.
>
> A fix for rpcbind might be to add a cmd-line flag to enable the
> rpcbind forwarding service, and have the service default to disabled.
> I'm not sure why rpcbind would list an outgoing port in it's portmap
> menu. Are you sure that this is the forwarding reflector port?

rpcbind doesn't list the outgoing port.
The listing you say was from "netstat -uap" or similar.

NeilBrown


>
>
>> steved.
>>=20
>>>=20
>>>=20
>>>> steved.
>>>>=20
>>>>>=20
>>>>> Brs,
>>>>> Bao
>>>>>=20
>>>>> On 27 January 2018 at 19:50, Naruto Nguyen <narutonguyen2018@gmail.co=
m> wrote:
>>>>>> I would like to ask you a question regarding the new random UDP port
>>>>>> in rpcbind 0.2.3.
>>>>>>=20
>>>>>> In rpcbind 0.2.3, when I start rpcbind (version 0.2.3) through
>>>>>> rpcbind.service, then I do netstat
>>>>>>=20
>>>>>> udp        0      0 0.0.0.0:111             0.0.0.0:*
>>>>>>        10408/rpcbind
>>>>>> udp        0      0 0.0.0.0:831             0.0.0.0:*
>>>>>>        10408/rpcbind
>>>>>> udp6       0      0 :::111                  :::*
>>>>>>        10408/rpcbind
>>>>>> udp6       0      0 :::831                  :::*
>>>>>>        10408/rpcbind
>>>>>>=20
>>>>>> The rpcbind does not only listen on port 111 but also on a random udp
>>>>>> port "831" in this case, this port is changed every time the rpcbind
>>>>>> service retstarts. And it listens on 0.0.0.0 so it opens a hole on
>>>>>> security. Could you please let me know what this port is for and is
>>>>>> there any way to avoid that like force it listen on a internal
>>>>>> interface rather than on any interfaces like that? I do not see the
>>>>>> random port on rpcbind 0.2.1, not sure why? As the rpcbind is started
>>>>>> from systemd so "-h" option is invalid as the man page says:
>>>>>>=20
>>>>>>=20
>>>>>>  -h      Specify specific IP addresses to bind to for UDP requests.
>>>>>> This option may be specified multiple times and can be used to
>>>>>> restrict the interfaces rpcbind will respond to.  Note that when
>>>>>> rpcbind is controlled via sys-
>>>>>>            temd's socket activation, the -h option is ignored. In
>>>>>> this case, you need to edit the ListenStream and ListenDgram
>>>>>> definitions in /usr/lib/systemd/system/rpcbind.socket instead.
>>>>>>=20
>>>>>> Thanks a lot,
>>>>>> Brs,
>>>>>> Naruto
>>>>> --
>>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
>>>>> the body of a message to majordomo@vger.kernel.org
>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>>=20
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>=20
>>> --
>>> Chuck Lever
>
> --
> Chuck Lever
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlp6O5IACgkQOeye3VZi
gbl6HA//dcgeTx2sLKcVKxNJUb2JnZzBQk+6PKm/wmW5meKl2mMBydXAeeHuZMev
PPyFdGK7KOdlsRaKG2Mu0TWAtDS+3kW5Q9FVLWictvATWYswIFbSiMkHLbujD8r5
yo0Untq5nzzo3k0AOE3HzsIHmVVljjuviTE3YV+zBQmlm/1hoNjkBkCc18oryPCQ
SbRMLWg/gVKwEH7fNeXMZMhR+X6/YSDg5nyNyi4vgGTtXdo64MtWypXAgueeu4c3
mErJmZskxtHM8/oE5ItvNjTMIrPrwPV/YrRiF7FB+TNCicnc9ut7kI5fAinFu1o1
YQdR/7IWsxt1skMwrn8DfjBVUbgPqVuZXUlu9ILI2G0s5zE2tZAH2ywqD0qrfHQQ
1ZGknjVlku4gKrTGVGQ0hp6LcuJnKohV7RZ5kct7FeK5WTOBjAn/r9hSGsXZHFtr
Ya45roABHLHsLV13QDftS5300Fl1UcIgJ0PlLABNVOelRn7qnSoM2Afv0HdnFK08
g73Mv9GxGjM5tRBk+hHla/6K4n88flJrCNsBlKxze69hXhNHM576SZ+2+1ORUjKF
XyVwfFFT90t27yG14EuIUNWe7WDdSDX7qD4akJXHoy8F5pe/eCpD8fEW3eQ4Z/r5
9Sd//S2g2rNo/5OiKbhGhvLWG4xAcLWaWTjDpOO0R7fJE+eFpLU=
=CtIU
-----END PGP SIGNATURE-----
--=-=-=--

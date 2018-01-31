Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2130.oracle.com ([156.151.31.86]:43716 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750742AbeAaTnQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 31 Jan 2018 14:43:16 -0500
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: Question about random UDP port on rpcbind 0.2.3
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <47c040cf-d0a8-eb42-a276-9bc2e264ff6e@RedHat.com>
Date: Wed, 31 Jan 2018 14:43:11 -0500
Cc: Naruto Nguyen <narutonguyen2018@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <66B30606-7AFE-43C8-8A51-5D031F9D744B@oracle.com>
References: <CANpxKHE=eKuFc2HBgT0aqDb+Q5EOFWOfCzf=tmmuH7zNyn878g@mail.gmail.com>
 <CANpxKHH3zf_RRnxckHKfvEWL-RNCr_ZePxc0r98Ep0X_JX1BbA@mail.gmail.com>
 <47c040cf-d0a8-eb42-a276-9bc2e264ff6e@RedHat.com>
To: Steve Dickson <SteveD@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Jan 31, 2018, at 2:31 PM, Steve Dickson <SteveD@RedHat.com> wrote:
>=20
>=20
>=20
> On 01/29/2018 01:44 AM, Naruto Nguyen wrote:
>> Hello,
>>=20
>> Just would like to add for more information, when I start rpcbind
>> normally, not via systemd, the random UDP is still opened
>>=20
>> Could you please share any ideas on this?
> The bound UDP socket is used for remote calls... Where rpcbind
> is asked to make a remote RPC for another caller...=20
>=20
> Antiquated? yes.. but harmless.

Not quite harmless. It can occupy a privileged port that belongs
to a real service.

We should change rpcbind to retain CAP_NET_BIND_SERVICE, so that
it doesn't have to hold onto that port indefinitely. It should
be able to bind to an outgoing privileged port whenever it needs
one.


> steved.
>=20
>>=20
>> Brs,
>> Bao
>>=20
>> On 27 January 2018 at 19:50, Naruto Nguyen =
<narutonguyen2018@gmail.com> wrote:
>>> I would like to ask you a question regarding the new random UDP port
>>> in rpcbind 0.2.3.
>>>=20
>>> In rpcbind 0.2.3, when I start rpcbind (version 0.2.3) through
>>> rpcbind.service, then I do netstat
>>>=20
>>> udp        0      0 0.0.0.0:111             0.0.0.0:*
>>>         10408/rpcbind
>>> udp        0      0 0.0.0.0:831             0.0.0.0:*
>>>         10408/rpcbind
>>> udp6       0      0 :::111                  :::*
>>>         10408/rpcbind
>>> udp6       0      0 :::831                  :::*
>>>         10408/rpcbind
>>>=20
>>> The rpcbind does not only listen on port 111 but also on a random =
udp
>>> port "831" in this case, this port is changed every time the rpcbind
>>> service retstarts. And it listens on 0.0.0.0 so it opens a hole on
>>> security. Could you please let me know what this port is for and is
>>> there any way to avoid that like force it listen on a internal
>>> interface rather than on any interfaces like that? I do not see the
>>> random port on rpcbind 0.2.1, not sure why? As the rpcbind is =
started
>>> from systemd so "-h" option is invalid as the man page says:
>>>=20
>>>=20
>>>   -h      Specify specific IP addresses to bind to for UDP requests.
>>> This option may be specified multiple times and can be used to
>>> restrict the interfaces rpcbind will respond to.  Note that when
>>> rpcbind is controlled via sys-
>>>             temd's socket activation, the -h option is ignored. In
>>> this case, you need to edit the ListenStream and ListenDgram
>>> definitions in /usr/lib/systemd/system/rpcbind.socket instead.
>>>=20
>>> Thanks a lot,
>>> Brs,
>>> Naruto
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever




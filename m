Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-3.desy.de ([131.169.56.156]:37531 "EHLO smtp-o-3.desy.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750815AbeBGIDi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Feb 2018 03:03:38 -0500
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
        by smtp-o-3.desy.de (DESY-O-3) with ESMTP id E536228039F
        for <linux-nfs@vger.kernel.org>; Wed,  7 Feb 2018 09:03:36 +0100 (CET)
Date: Wed, 7 Feb 2018 09:03:36 +0100 (CET)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Message-ID: <1619644276.3218766.1517990616235.JavaMail.zimbra@desy.de>
In-Reply-To: <1517956185.39096.9.camel@primarydata.com>
References: <1253710805.3166627.1517955019275.JavaMail.zimbra@desy.de> <1517956185.39096.9.camel@primarydata.com>
Subject: Re: wrong latency info for flexfiles on layout return
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If I understand you correctly, then completion time is the sum of all IO re=
quests sent from a client to the server.
Then with average per-op round-trip of 2.7s I should see at lease one reque=
st which takes longer than average.
However, the longest rpc request round-trip time I see with wireshark is  1=
70ms.  Do I miss something?

Thanks,
   Tigran.

----- Original Message -----
> From: "Trond Myklebust" <trondmy@primarydata.com>
> To: "Tigran Mkrtchyan" <tigran.mkrtchyan@desy.de>, "linux-nfs" <linux-nfs=
@vger.kernel.org>
> Sent: Tuesday, February 6, 2018 11:29:48 PM
> Subject: Re: wrong latency info for flexfiles on layout return

> On Tue, 2018-02-06 at 23:10 +0100, Mkrtchyan, Tigran wrote:
>>=20
>> Hi Trond et al.
>>=20
>> by exploring data provided on layoutreturn I can see that some
>> information is wrong, in particular the IO latency completition
>> time for write:
>>=20
>> {
>>    "iostats":[
>>       {
>>          "deviceAddr":"tcp://192.168.178.40.128.2",
>>          "duration":{
>>             "seconds":5,
>>             "nseconds":285924462
>>          },
>>          "readInfo":{
>>             "bytes":0,
>>             "latency":{
>>                "completitionTime":{
>>                   "seconds":0,
>>                   "nseconds":0
>>                },
>>                "bytesRequested":0,
>>                "opsCompleted":0,
>>                "busyTime":{
>>                   "seconds":0,
>>                   "nseconds":0
>>                },
>>                "opsRequested":0,
>>                "bytesCompleted":0,
>>                "bytesNotDelivered":0
>>             },
>>             "count":0
>>          },
>>          "fh":"01caffee00000000b1f9635e000d00000800000000000000050130
>> ",
>>          "writeInfo":{
>>             "bytes":624193536,
>>             "latency":{
>>                "completitionTime":{
>>                   "seconds":25737,
>>                   "nseconds":816217921
>>                },
>>                "bytesRequested":624193536,
>>                "opsCompleted":9526,
>>                "busyTime":{
>>                   "seconds":5,
>>                   "nseconds":224017937
>>                },
>>                "opsRequested":9526,
>>                "bytesCompleted":624193536,
>>                "bytesNotDelivered":0
>>             },
>>             "count":9526
>>          },
>>          "deviceId":"00000001000000000000000000000000",
>>          "open-stateid":"5a7a259b0000000100000004"
>>       }
>>    ]
>> }
>>=20
>>=20
>> you can see this with wireshark as well.
>>=20
>=20
> Can you explain what you think is wrong? With the above aggregate
> completion time, I get an average per-op round-trip time of
> 25737.816/9526 =3D 2.7s, which looks a little high given that the
> duration is only 5 seconds, but it's not horribly unlikely if your DSes
> are processing most of these operations in parallel.
>=20
> --
> Trond Myklebust
> Linux NFS client maintainer, PrimaryData
> trond.myklebust@primarydata.com
> N=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BDr=EF=BF=BD=EF=BF=BDy=EF=BF=
=BD=EF=BF=BD=EF=BF=BDb=EF=BF=BDX=EF=BF=BD=EF=BF=BD=C7=A7v=EF=BF=BD^=EF=BF=
=BD)=DE=BA{.n=EF=BF=BD+=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD{=EF=BF=BD=EF=BF=
=BD=EF=BF=BD"=EF=BF=BD=EF=BF=BD^n=EF=BF=BDr=EF=BF=BD=EF=BF=BD=EF=BF=BDz=EF=
=BF=BD=EF=BF=BD=EF=BF=BDh=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD&=EF=BF=BD=EF=
=BF=BD=EF=BF=BDG=EF=BF=BD=EF=BF=BD=EF=BF=BDh=EF=BF=BD(=EF=BF=BD=E9=9A=8E=EF=
=BF=BD=DD=A2j"=EF=BF=BD=EF=BF=BD=EF=BF=BDm=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BDz=EF=BF=BD=DE=96=EF=BF=BD=EF=BF=BD=EF=BF=BDf=EF=BF=BD=EF=BF=BD=
=EF=BF=BDh=EF=BF=BD=EF=BF=BD=EF=BF=BD~=EF=BF=BDm=EF=BF=BD

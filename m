Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:36779 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759201AbdCVQLe (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Mar 2017 12:11:34 -0400
Received: by mail-it0-f68.google.com with SMTP id 190so5085257itm.3
        for <linux-nfs@vger.kernel.org>; Wed, 22 Mar 2017 09:11:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1657271697.3093215.1490044172396.JavaMail.zimbra@desy.de>
References: <45574919.3034342.1490025160438.JavaMail.zimbra@desy.de>
 <CAN-5tyHVmfwvEk+N+i5nFa=E7OyWW=k3eRc82Ed0Ttx=rNxdPw@mail.gmail.com>
 <362211751.3088036.1490043081358.JavaMail.zimbra@desy.de> <1657271697.3093215.1490044172396.JavaMail.zimbra@desy.de>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Wed, 22 Mar 2017 12:04:21 -0400
Message-ID: <CAN-5tyFO1SH4NDh-ResCZUK5xo0NSQgqo3-dHASiy+5bcqLW4g@mail.gmail.com>
Subject: Re: pNFS: invalid IP:port selection when talks to DS
To: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Steve Dickson <steved@redhat.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Tigran,

I still don't have the answer to your question but I'm just puzzled
why it "works" with 4.9 (session trunking). New code would check the
server owner and if they are the same, then it would add that to the
list of addresses to trunk. I'd assume you'd be seeing the same
behavior with the new code. Thus, I'm puzzled. That aside, if you
don't want the new code to trunk between your DSs on the same server,
they should return different owner.

I'm assuming device ids are different for the DSs on different ports?

On Mon, Mar 20, 2017 at 5:09 PM, Mkrtchyan, Tigran
<tigran.mkrtchyan@desy.de> wrote:
>
> Hi Olga,
>
> you did not have the answer, however you gave me an important hint!
> I believe, all our DSes on a single host generate the same server
> owner during exchange-id. I guess, this can be the reason, why
> client decides to talk to an other DS.
>
> Tigran.
>
> ----- Original Message -----
>> From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
>> To: "Olga Kornievskaia" <aglo@umich.edu>
>> Cc: "Linux NFS Mailing list" <linux-nfs@vger.kernel.org>, "Steve Dickson=
" <steved@redhat.com>
>> Sent: Monday, March 20, 2017 9:51:21 PM
>> Subject: Re: pNFS: invalid IP:port selection when talks to DS
>
>> Hi Olga,
>>
>> ----- Original Message -----
>>> From: "Olga Kornievskaia" <aglo@umich.edu>
>>> To: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
>>> Cc: "Linux NFS Mailing list" <linux-nfs@vger.kernel.org>, "Steve Dickso=
n"
>>> <steved@redhat.com>
>>> Sent: Monday, March 20, 2017 9:14:34 PM
>>> Subject: Re: pNFS: invalid IP:port selection when talks to DS
>>
>>> Hi Tigran,
>>>
>>> While I don't have an answer to your question, I'd like to point out
>>> that in 4.9 is when Andy's session trunking patches when in.
>>>
>>> I'm curious this client that's now talking to the DS at port 24006
>>> instead of 24005, did it before also earlier correctly (legally)
>>> talked to DS that was on 24006?
>>
>> Yes, earlier during testing it had legal access to DS on port 24006.
>>
>> Tigran.
>>
>>>
>>> On Mon, Mar 20, 2017 at 11:52 AM, Mkrtchyan, Tigran
>>> <tigran.mkrtchyan@desy.de> wrote:
>>>>
>>>>
>>>> Dear (p)NFS-ors,
>>>>
>>>> we observe VERY unpleasant situation with pNFS in the production.
>>>> Our hosts run multiple DSes on different ports, usually 24001-24009.
>>>> With CentOS7 (3.10.0-514.6.2.el7.x86_64) we see that client takes
>>>> a wrong port number when talks to data server:
>>>>
>>>> If client uses different DSes on the same host, then at some point it =
starts
>>>> to send data to the wrong port number:
>>>>
>>>> Client <=3D> MDS:
>>>>
>>>>
>>>>     1 0.000000000 131.169.251.53 =E2=86=92 131.169.51.35 NFS V4 Call O=
PEN DH:
>>>>     0x7cbc716b/MIL-68-onebatch-80C-30s-00057.tif.metadata
>>>>     2 0.001469799 131.169.51.35 =E2=86=92 131.169.251.53 NFS V4 Reply =
(Call In 1) OPEN
>>>>     StateID: 0xec18
>>>>     3 0.001578128 131.169.251.53 =E2=86=92 131.169.51.35 NFS V4 Call S=
ETATTR FH: 0x6ccf3dfa
>>>>     4 0.002657187 131.169.51.35 =E2=86=92 131.169.251.53 NFS V4 Reply =
(Call In 3) SETATTR
>>>>     5 0.003243819 131.169.251.53 =E2=86=92 131.169.51.35 NFS V4 Call L=
AYOUTGET
>>>>     6 0.014603386 131.169.51.35 =E2=86=92 131.169.251.53 NFS V4 Reply =
(Call In 5) LAYOUTGET
>>>>     7 0.014899121 131.169.251.53 =E2=86=92 131.169.51.35 NFS V4 Call G=
ETDEVINFO
>>>>     8 0.015014216 131.169.51.35 =E2=86=92 131.169.251.53 NFS V4 Reply =
(Call In 7) GETDEVINFO
>>>>         Opcode: GETDEVINFO (47)
>>>>             Status: NFS4_OK (0)
>>>>             layout type: LAYOUT4_NFSV4_1_FILES (1)
>>>>             device index: 0
>>>>             r_netid: tcp
>>>>                 length: 3
>>>>                 contents: tcp
>>>>                 fill bytes: opaque data
>>>>             r_addr: 131.169.51.50.93.197
>>>>                 length: 20
>>>>                 contents: 131.169.51.50.93.197
>>>>             r_netid: tcp
>>>>                 length: 3
>>>>                 contents: tcp
>>>>                 fill bytes: opaque data
>>>>             r_addr: 131.169.51.50.93.197
>>>>                 length: 20
>>>>                 contents: 131.169.51.50.93.197
>>>>             notification bitmap: 6
>>>>             notification bitmap: 0
>>>>     [Main Opcode: GETDEVINFO (47)]
>>>>
>>>>     9 0.105442455 131.169.251.53 =E2=86=92 131.169.51.35 NFS V4 Call T=
EST_STATEID
>>>>    10 0.105521354 131.169.51.35 =E2=86=92 131.169.251.53 NFS V4 Reply =
(Call In 9)
>>>>    TEST_STATEID
>>>>
>>>>
>>>>
>>>> NOTICE, that 131.169.51.50.93.197 corresponds to port 24005.
>>>>
>>>> client <=3D> DS
>>>>
>>>> $ tshark -r ds-write.pcap  -n -z conv,tcp
>>>>     1   0.000000 131.169.251.53 =E2=86=92 131.169.51.50 NFS V4 Call WR=
ITE StateID: 0xff01
>>>>     Offset: 0 Len: 3968
>>>>     2   0.000090 131.169.51.50 =E2=86=92 131.169.251.53 NFS V4 Reply (=
Call In 1) WRITE
>>>>     Status: NFS4ERR_BAD_STATEID
>>>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D
>>>> TCP Conversations
>>>> Filter:<No Filter>
>>>>                                                            |       <- =
     | |       ->      | |     Total     |    Relative    |   Duration   |
>>>>                                                            | Frames  B=
ytes | | Frames  Bytes | | Frames  Bytes |      Start     |
>>>>                                                            | |
>>>> 131.169.51.50:24006        <-> 131.169.251.53:847               1     =
 4240
>>>> 1       168       2      4408     0.000000000         0.0001
>>>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D
>>>>
>>>> NOTICE, that it talks to DS on port 24006!
>>>>
>>>> Is there know fix which is missing in CentOS7? I can't reproduce it wi=
th
>>>> 4.9 kernel (or it's harder to reproduce).
>>>>
>>>>
>>>> The packages are attached.
>>>>
>>>> Tigran.
>>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html

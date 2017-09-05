Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f178.google.com ([209.85.223.178]:35311 "EHLO
        mail-io0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752058AbdIERvI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Sep 2017 13:51:08 -0400
Received: by mail-io0-f178.google.com with SMTP id i14so104223ioe.2
        for <linux-nfs@vger.kernel.org>; Tue, 05 Sep 2017 10:51:08 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: linux>=4.10: PUTFH|GETATTR|CLOSE, GETATTR fails, CLOSE not
 re-issued
From: Weston Andros Adamson <dros@monkey.org>
In-Reply-To: <F24109A7-778E-4655-BE5F-DCF2528E3A61@monkey.org>
Date: Tue, 5 Sep 2017 13:51:05 -0400
Cc: linux-nfs list <linux-nfs@vger.kernel.org>,
        Thorvald Natvig <thorvald@medallia.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Message-Id: <4E7FE08F-D3EB-4AE2-8F8A-0688B68DA8B5@monkey.org>
References: <CAOFvWm9a6zrAc60Y388czZtUdL79Wf7AAaA=vTpAwS313Y44yg@mail.gmail.com>
 <F24109A7-778E-4655-BE5F-DCF2528E3A61@monkey.org>
To: Kjetil Joergensen <kjetil@medallia.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I chatted with Trond about this and he says it's a server bug if an =
unlinked file
keeps stateids around - the client doesn't need to issue a close in this =
case.

What version of ONTAP are you running?

-dros


> On Sep 1, 2017, at 2:44 PM, Weston Andros Adamson <dros@monkey.org> =
wrote:
>=20
> Nice analysis! I think post d8d849835eb2082ea17655538a83fa467633927f, =
we
> need to retry with a [PUTFH, CLOSE] if the GETATTR fails.
>=20
> The problem as I see it is the GETATTR is tied to the CURRENT_FH, =
which is
> stale for new operations since the file was unlinked, but the CLOSE is =
tied to the
> (CURRENT_FH, open stateid) pair and is not stale because the state id =
is still
> valid.
>=20
> Trond is out on PTO, should be back on or before next Tuesday. The =
recent change
> was his and he might have a better idea how to handle this.
>=20
> -dros
>=20
>=20
>> On Aug 31, 2017, at 1:34 PM, Kjetil Joergensen <kjetil@medallia.com> =
wrote:
>>=20
>> Hi,
>>=20
>> (Now - I do not actually know the specification(s) all that well, so
>> it may be that I've by accident cherry picked the bits that partially
>> turns this into a linux-nfs-client bug, and I'd be more than happy
>> with responses that'd be useful to yell at netapp with).
>>=20
>> after d8d849835eb2082ea17655538a83fa467633927f (NFSv4: Place the
>> GETATTR operation before the CLOSE). If GETATTR actually fails, CLOSE
>> will never be processed by the server, and it seems the linux nfs
>> client never tries to re-issue CLOSE.
>>=20
>> We have client A holding file F open,  client B goes ahead and =
unlinks
>> F, at some point client a does PUTFH,GETATTR, for which the server
>> responds NFS4ERR_STALE.
>>=20
>> Now, client A goes ahead and tries to clean up it's internal state,
>> and sends the server compound PUTFH,GETATTR,CLOSE, for which the
>> server responds with PUTFH(NFS4_OK),GETATTR(NFS4ERR_STALE).
>>=20
>> Which seems correct in the eyes of RFC7530 section 14.2., which says
>> the server should stop processing the compound when a subop fails.
>>=20
>> The server has not processed the CLOSE op, and in the case of netapp
>> it appears it keeps holding on to the stateid, waiting for the client
>> to CLOSE it.
>>=20
>> Judging from tcpdump, the client never attempts to re-issue the CLOSE
>> op that weren't processed.
>>=20
>> On the server side, the stateid sticks around until we tear down the
>> client completely (umount or re-boot). Over time, this leads the
>> netapp to bleed stateids.
>>=20
>> Compare this to pre d8d849835eb2082ea17655538a83fa467633927f, the
>> client issues PUTFH,CLOSE,GETATTR. Both PUTFH & CLOSE succeeds,
>> GETATTR as expected still gets NFS4ERR_STALE. The server did however
>> process CLOSE, and retired it's stateid.
>>=20
>> Cheers,
>>=20
>> --=20
>> Kjetil Joergensen <kjetil@medallia.com>
>> Phone: +1 (650) 739-6580
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20


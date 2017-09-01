Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:33632 "EHLO
        mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750955AbdIASoO (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Sep 2017 14:44:14 -0400
Received: by mail-io0-f170.google.com with SMTP id b2so6178311iof.0
        for <linux-nfs@vger.kernel.org>; Fri, 01 Sep 2017 11:44:14 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: linux>=4.10: PUTFH|GETATTR|CLOSE, GETATTR fails, CLOSE not
 re-issued
From: Weston Andros Adamson <dros@monkey.org>
In-Reply-To: <CAOFvWm9a6zrAc60Y388czZtUdL79Wf7AAaA=vTpAwS313Y44yg@mail.gmail.com>
Date: Fri, 1 Sep 2017 14:44:11 -0400
Cc: linux-nfs list <linux-nfs@vger.kernel.org>,
        Thorvald Natvig <thorvald@medallia.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Message-Id: <F24109A7-778E-4655-BE5F-DCF2528E3A61@monkey.org>
References: <CAOFvWm9a6zrAc60Y388czZtUdL79Wf7AAaA=vTpAwS313Y44yg@mail.gmail.com>
To: Kjetil Joergensen <kjetil@medallia.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Nice analysis! I think post d8d849835eb2082ea17655538a83fa467633927f, we
need to retry with a [PUTFH, CLOSE] if the GETATTR fails.

The problem as I see it is the GETATTR is tied to the CURRENT_FH, which =
is
stale for new operations since the file was unlinked, but the CLOSE is =
tied to the
(CURRENT_FH, open stateid) pair and is not stale because the state id is =
still
valid.

Trond is out on PTO, should be back on or before next Tuesday. The =
recent change
was his and he might have a better idea how to handle this.

-dros


> On Aug 31, 2017, at 1:34 PM, Kjetil Joergensen <kjetil@medallia.com> =
wrote:
>=20
> Hi,
>=20
> (Now - I do not actually know the specification(s) all that well, so
> it may be that I've by accident cherry picked the bits that partially
> turns this into a linux-nfs-client bug, and I'd be more than happy
> with responses that'd be useful to yell at netapp with).
>=20
> after d8d849835eb2082ea17655538a83fa467633927f (NFSv4: Place the
> GETATTR operation before the CLOSE). If GETATTR actually fails, CLOSE
> will never be processed by the server, and it seems the linux nfs
> client never tries to re-issue CLOSE.
>=20
> We have client A holding file F open,  client B goes ahead and unlinks
> F, at some point client a does PUTFH,GETATTR, for which the server
> responds NFS4ERR_STALE.
>=20
> Now, client A goes ahead and tries to clean up it's internal state,
> and sends the server compound PUTFH,GETATTR,CLOSE, for which the
> server responds with PUTFH(NFS4_OK),GETATTR(NFS4ERR_STALE).
>=20
> Which seems correct in the eyes of RFC7530 section 14.2., which says
> the server should stop processing the compound when a subop fails.
>=20
> The server has not processed the CLOSE op, and in the case of netapp
> it appears it keeps holding on to the stateid, waiting for the client
> to CLOSE it.
>=20
> Judging from tcpdump, the client never attempts to re-issue the CLOSE
> op that weren't processed.
>=20
> On the server side, the stateid sticks around until we tear down the
> client completely (umount or re-boot). Over time, this leads the
> netapp to bleed stateids.
>=20
> Compare this to pre d8d849835eb2082ea17655538a83fa467633927f, the
> client issues PUTFH,CLOSE,GETATTR. Both PUTFH & CLOSE succeeds,
> GETATTR as expected still gets NFS4ERR_STALE. The server did however
> process CLOSE, and retired it's stateid.
>=20
> Cheers,
>=20
> --=20
> Kjetil Joergensen <kjetil@medallia.com>
> Phone: +1 (650) 739-6580
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


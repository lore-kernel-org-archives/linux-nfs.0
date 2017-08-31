Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f174.google.com ([209.85.220.174]:34195 "EHLO
        mail-qk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751622AbdHaReW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 31 Aug 2017 13:34:22 -0400
Received: by mail-qk0-f174.google.com with SMTP id a77so1422698qkb.1
        for <linux-nfs@vger.kernel.org>; Thu, 31 Aug 2017 10:34:20 -0700 (PDT)
MIME-Version: 1.0
From: Kjetil Joergensen <kjetil@medallia.com>
Date: Thu, 31 Aug 2017 10:34:18 -0700
Message-ID: <CAOFvWm9a6zrAc60Y388czZtUdL79Wf7AAaA=vTpAwS313Y44yg@mail.gmail.com>
Subject: linux>=4.10: PUTFH|GETATTR|CLOSE, GETATTR fails, CLOSE not re-issued
To: linux-nfs@vger.kernel.org
Cc: Thorvald Natvig <thorvald@medallia.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

(Now - I do not actually know the specification(s) all that well, so
it may be that I've by accident cherry picked the bits that partially
turns this into a linux-nfs-client bug, and I'd be more than happy
with responses that'd be useful to yell at netapp with).

after d8d849835eb2082ea17655538a83fa467633927f (NFSv4: Place the
GETATTR operation before the CLOSE). If GETATTR actually fails, CLOSE
will never be processed by the server, and it seems the linux nfs
client never tries to re-issue CLOSE.

We have client A holding file F open,  client B goes ahead and unlinks
F, at some point client a does PUTFH,GETATTR, for which the server
responds NFS4ERR_STALE.

Now, client A goes ahead and tries to clean up it's internal state,
and sends the server compound PUTFH,GETATTR,CLOSE, for which the
server responds with PUTFH(NFS4_OK),GETATTR(NFS4ERR_STALE).

Which seems correct in the eyes of RFC7530 section 14.2., which says
the server should stop processing the compound when a subop fails.

The server has not processed the CLOSE op, and in the case of netapp
it appears it keeps holding on to the stateid, waiting for the client
to CLOSE it.

Judging from tcpdump, the client never attempts to re-issue the CLOSE
op that weren't processed.

On the server side, the stateid sticks around until we tear down the
client completely (umount or re-boot). Over time, this leads the
netapp to bleed stateids.

Compare this to pre d8d849835eb2082ea17655538a83fa467633927f, the
client issues PUTFH,CLOSE,GETATTR. Both PUTFH & CLOSE succeeds,
GETATTR as expected still gets NFS4ERR_STALE. The server did however
process CLOSE, and retired it's stateid.

Cheers,

-- 
Kjetil Joergensen <kjetil@medallia.com>
Phone: +1 (650) 739-6580

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-eopbgr670040.outbound.protection.outlook.com ([40.107.67.40]:53376
        "EHLO CAN01-TO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753708AbeEWA02 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 22 May 2018 20:26:28 -0400
From: Rick Macklem <rmacklem@uoguelph.ca>
To: Olga Kornievskaia <aglo@umich.edu>,
        "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
CC: linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: question: re-try of operations in PNFS
Date: Wed, 23 May 2018 00:26:20 +0000
Message-ID: <YTOPR0101MB0953F9A6FE17FCD371233EC1DD6B0@YTOPR0101MB0953.CANPRD01.PROD.OUTLOOK.COM>
References: <CAN-5tyH2OVzr5TTN_sCrKxEiXaDiPzh=8zykR__jq=k2ve5Vaw@mail.gmail.com>
 <955655871.7566389.1527021265316.JavaMail.zimbra@desy.de>,<CAN-5tyE4gO9=pDtSPC+vbH4HuBs69Qyt8tSPFMM6_cg32BrH9A@mail.gmail.com>
In-Reply-To: <CAN-5tyE4gO9=pDtSPC+vbH4HuBs69Qyt8tSPFMM6_cg32BrH9A@mail.gmail.com>
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Olga Kornievskaia wrote:
[good stuff snipped]
>Upstream kernel. But I'm arguing that there shouldn't be a need to
>specify a dataserver_timeo because it shouldn't timeout at all just
>like MDS operations.
If/when the server is providing mirrored DSs, I've found this timeout useful
in the FreeBSD client since it allows the client to detect a DS failure.
It can then report the failure to the MDS via LayoutReturn (or another one
on NFSv4.2 which I can't remember the name of since I haven't done 4.2;-).

For non-mirrored DSs, the only thing I can think of (I've never seen this) would
be some sort of network partitioning such that the client can't reach the DS but
can reach the MDS.

I have no idea if this is relevant to Linux, but thought I'd mention it, just in case.
[more stuff snipped]
rick

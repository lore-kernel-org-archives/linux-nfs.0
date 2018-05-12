Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-eopbgr660068.outbound.protection.outlook.com ([40.107.66.68]:4928
        "EHLO CAN01-QB1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750835AbeELWeC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 12 May 2018 18:34:02 -0400
From: Rick Macklem <rmacklem@uoguelph.ca>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: NFSv4.1 client recovery of opens after server crash/reboot
Date: Sat, 12 May 2018 22:34:00 +0000
Message-ID: <YTOPR0101MB095358258682ACC6D4F8DC02DD9E0@YTOPR0101MB0953.CANPRD01.PROD.OUTLOOK.COM>
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I just ran a little test of an NFSv4.1 server (FreeBSD) reboot while the Linux client
had two files open over an NFSv4.1 mount (linux-4.17-rc2).
It basically worked, but when I looked at the packet trace in wireshark, it wasn't what
I expected.
The operations were basically:
1 - ExchangeID
2 - CreateSession
3 - ReclaimComplete
4 - Open/Claim_FH done twice to reclaim the Opens

This seems "unsafe" to me, since I think it would be possible for another client to Open the file with OPEN_DENY_BOTH between #3 and #4, causing #4 to fail.
I was expecting something like:
1 - ExchangeID
2 - CreateSession
3 - Open/Claim_previous done twice to reclaim the Opens
4 - ReclaimComplete

If someone would like to look at the packet trace, just email me and I'll
send it to you.

Just thought I'd let you all know, rick

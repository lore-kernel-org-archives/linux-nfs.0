Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-eopbgr670041.outbound.protection.outlook.com ([40.107.67.41]:4294
        "EHLO CAN01-TO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751560AbeDYXXh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 25 Apr 2018 19:23:37 -0400
From: Rick Macklem <rmacklem@uoguelph.ca>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: patch for flex file layout client driver
Date: Wed, 25 Apr 2018 23:23:35 +0000
Message-ID: <YQBPR0101MB10428F8B68C2B6D30E96EC9CDD8F0@YQBPR0101MB1042.CANPRD01.PROD.OUTLOOK.COM>
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

When testing the Linux NFSv4.1 client against the FreeBSD pNFS service that
uses Flexible File Layout and the "tightly coupled" model, I found a couple
of issues. Basically the stateid and AUTH_SYS credentials were not being filled
in the way the "tightly coupled" model requires.
I came up with a patch that changes the driver for the "tightly coupled" model
in two ways:
1 - It uses the credentials of the request and not the synthetic credentials in the
     AUTH_SYS RPC header for the DS I/O rpcs.
2 - It uses the stateid provided in the layout for the Read/Write operations on the
     DS.
It has worked fine for me during moderate testing and I do not believe it changes
the driver semantics for the "loosely coupled" case.
This patch can be found here:
http://people.freebsd.org/~rmacklem/flexfile.patch
(against a linux-4.17-rc2 kernel)

I am hoping someone can review this and maybe upstream it for a future
Linux kernel release?
(I can test any modified patch, if that is needed.)

Btw, if anyone is interested in trying the FreeBSD pNFS service for testing this
patch (or anything else), information on it can be found here:
http://people.freebsd.org/~rmacklem/pnfs-planb-setup.txt

Have fun with it, rick

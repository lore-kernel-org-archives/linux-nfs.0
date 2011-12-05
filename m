Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bw0-f46.google.com ([209.85.214.46]:52769 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752299Ab1LEIJz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Dec 2011 03:09:55 -0500
Received: by bkbzv3 with SMTP id zv3so1468888bkb.19
        for <linux-nfs@vger.kernel.org>; Mon, 05 Dec 2011 00:09:54 -0800 (PST)
Message-ID: <4EDC7C4E.1040901@tonian.com>
Date: Mon, 05 Dec 2011 10:09:50 +0200
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/10] pnfs-block ctl
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Folks,

The following are fixes to Rick McNeal's user-space ctl daemon
for the pnfs block server.

They are available on:
git://linux-nfs.org/~bhalevy/pnfsd-block-ctl.git

The daemon is required on the server side to get the pnfs
block device EFI signature and volume signature.


[PATCH 01/10] use gcc
[PATCH 02/10] efi: fix user-land debug printouts
[PATCH 03/10] ctl: improve debug printouts
[PATCH 04/10] increase compiler warning level
[PATCH 05/10] ctl: always return a value from find_dm_name
[PATCH 06/10] add missing includes
[PATCH 07/10] ctl: fix compiler warnings
[PATCH 08/10] fix compiler warnings around get_output use of argv
[PATCH 09/10] ctl: main should return 0 on success
[PATCH 10/10] efi: fix compiler warnings

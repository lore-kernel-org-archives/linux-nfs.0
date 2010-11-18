Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:52860 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757564Ab0KRXe3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Nov 2010 18:34:29 -0500
Received: by yxf34 with SMTP id 34so2309694yxf.19
        for <linux-nfs@vger.kernel.org>; Thu, 18 Nov 2010 15:34:28 -0800 (PST)
Date: Thu, 18 Nov 2010 15:34:28 -0800
Message-ID: <AANLkTinX=Obq5LFGQzHYGgG_4s7N34faagsZZy09NwE9@mail.gmail.com>
Subject: O_DIRECT, O_SYNC, or fsync() on NFS mounts?
From: Moazam Raja <moazam@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi all,

I'm currently exporting a ZFS filesystem on Solaris 11 Express as NFS.
I have a Linux client mounting that NFS v3 filesystem with the
proto=tcp option.

My question is, what's the safest and most reliable way to write data
to this NFS mount on a Linux client? Should my application code use
O_DIRECT, or O_SYNC? Or should I be doing a write() and a fsync()? I
want to make sure that data is not lost and is truly committed, while
keeping decent performance (of course).


-Moazam

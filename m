From: jin zhencheng <zhenchengjin@gmail.com>
Subject: NFS error RPC: multiple fragments per record not supported
Date: Wed, 20 Jan 2010 21:38:15 +0800
Message-ID: <de04351e1001200538l14359abfn4a11af08c43e9af7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-px0-f182.google.com ([209.85.216.182]:47264 "EHLO
	mail-px0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752088Ab0ATNiQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Jan 2010 08:38:16 -0500
Received: by pxi12 with SMTP id 12so5595411pxi.33
        for <linux-nfs@vger.kernel.org>; Wed, 20 Jan 2010 05:38:15 -0800 (PST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I use kernel 2.6.26.2

I use  many clients,

every client mount parameters as this:
mount -t nfs -o rw,noatime,v3,rsize=32768,wsize=32768,hard,intr,tcp,nolock

my system have many errors like these :

RPC: multiple fragments per record not supported
RPC: multiple fragments per record not supported
RPC: fragment too large: 0x318c87ee
RPC: multiple fragments per record not supported
RPC: fragment too large: 0x78bdeedb
RPC: multiple fragments per record not supported
RPC: fragment too large: 0x75cf8a33
RPC: fragment too large: 0x44764ada
RPC: multiple fragments per record not supported
RPC: fragment too large: 0x0a08e7c0
RPC: multiple fragments per record not supported
RPC: multiple fragments per record not supported
RPC: fragment too large: 0x5b4e13a1
RPC: fragment too large: 0x08351a9f

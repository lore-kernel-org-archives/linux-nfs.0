Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:40327 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752068Ab0L0XkT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Dec 2010 18:40:19 -0500
Received: by gyb11 with SMTP id 11so3612926gyb.19
        for <linux-nfs@vger.kernel.org>; Mon, 27 Dec 2010 15:40:18 -0800 (PST)
Date: Mon, 27 Dec 2010 18:32:20 -0500
Message-ID: <AANLkTi=67a4C7Wx1zhoB-gAV_uXyzizenLmaEnbruy9i@mail.gmail.com>
Subject: NFS and firewalls
From: Jeff Hanson <jhansonxi@gmail.com>
To: Linux NFS <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The random port usage of NFS makes it difficult to use with NAT/firewalls.

The common workaround is to configure statd, mountd, lockd, and quotad
to static ports. Since there isn't any standard (IANA registered) port
assignments this breaks on many networks that use dynamic or different
static ports.

This makes it difficult to use the "standard" network file sharing
protocol with mobile devices which often use firewalls.

Saned, Samba (netbios), and FTP all have conntrack modules to handle
dynamic port usage.  Has there been any attempt to write one for NFS?

I filed a bug with Ubuntu about it (#688446), mostly for psychological
benefit as it's probably something they're not going to get involved
with.

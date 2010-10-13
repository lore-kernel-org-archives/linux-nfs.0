Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from filter.openoffice.nl ([217.170.2.175]:44522 "EHLO
	filter.openoffice.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752277Ab0JMK5N (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Oct 2010 06:57:13 -0400
Received: from localhost (localhost [127.0.0.1])
	by filter.openoffice.nl (Postfix) with ESMTP id 1CEC72439F2
	for <linux-nfs@vger.kernel.org>; Wed, 13 Oct 2010 12:57:13 +0200 (CEST)
Received: from filter.openoffice.nl ([127.0.0.1])
	by localhost (post-it.openoffice.nl [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id XMx-fLdN0on1 for <linux-nfs@vger.kernel.org>;
	Wed, 13 Oct 2010 12:57:11 +0200 (CEST)
Received: from blub.net (095-097-076-243.static.chello.nl [95.97.76.243])
	by filter.openoffice.nl (Postfix) with ESMTP id 3E8862439E5
	for <linux-nfs@vger.kernel.org>; Wed, 13 Oct 2010 12:57:11 +0200 (CEST)
Received: from stout.kantoor.openoffice.nl (stout.kantoor.openoffice.nl [192.168.112.50])
	by blub.net (Postfix) with ESMTP id 15E83300050
	for <linux-nfs@vger.kernel.org>; Wed, 13 Oct 2010 12:57:11 +0200 (CEST)
Message-ID: <4CB59086.9080108@blub.net>
Date: Wed, 13 Oct 2010 12:57:10 +0200
From: Valentijn Sessink <valentyn@blub.net>
To: linux-nfs@vger.kernel.org
Subject: ipv6 + krb5, server status?
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello list,

I found a lot of information on the subject NFS server, ipv6 + krb5, but
not anything conclusive. So I tried it out; I got IPv6 +
NFS4 to work, but only with sec=sys.

When using sec=krb5, there seemed to be errors in gssd communication.
(Ubuntu 10.04 with rpcbind instead of portmap; with nfs-utils-1.2.3 from
nfs.sf.net, and with a 2.6.35-020635rc1-generic kernel package).

Is this correct, i.e. svcgssd still needs to be adapted to IPv6? Or
should NFS-server/IPv6/Kerberos on Linux just work, i.e. should I
re-check my configuration?

Best regards,

Valentijn Sessink

(I hope you don't mind the repost; I did not get any answers on my
previous posting. If you do mind, please say so off-list).

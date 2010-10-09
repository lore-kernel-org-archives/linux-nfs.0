From: Valentijn Sessink <valentyn-FXuWeBwviIQ@public.gmane.org>
Subject: ipv6 + krb5, server status?
Date: Sat, 09 Oct 2010 16:19:20 +0200
Message-ID: <4CB079E8.7040606@blub.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from filter.openoffice.nl ([217.170.2.175]:34837 "EHLO
	filter.openoffice.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754994Ab0JIO2I (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 9 Oct 2010 10:28:08 -0400
Received: from localhost (localhost [127.0.0.1])
	by filter.openoffice.nl (Postfix) with ESMTP id 811202439D9
	for <linux-nfs@vger.kernel.org>; Sat,  9 Oct 2010 16:19:24 +0200 (CEST)
Received: from filter.openoffice.nl ([127.0.0.1])
	by localhost (post-it.openoffice.nl [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id JNiUPuJT5Nfe for <linux-nfs@vger.kernel.org>;
	Sat,  9 Oct 2010 16:19:22 +0200 (CEST)
Received: from blub.net (095-097-076-243.static.chello.nl [95.97.76.243])
	by filter.openoffice.nl (Postfix) with ESMTP id B4C912439CD
	for <linux-nfs@vger.kernel.org>; Sat,  9 Oct 2010 16:19:22 +0200 (CEST)
Received: from [192.168.1.2] (dhcp-095-096-074-210.chello.nl [95.96.74.210])
	by blub.net (Postfix) with ESMTPSA id 7E1513002CA
	for <linux-nfs@vger.kernel.org>; Sat,  9 Oct 2010 16:19:22 +0200 (CEST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello list,

I found a lot of information on the subject (ipv6 + krb5, server 
status), but not anything conclusive. So I tried it out; I got IPv6 + 
NFS4 to work, but only with sec=sys. When using sec=krb5, there seemed 
to be errors in gssd communication. (Ubuntu 10.04 with rpcbind instead 
of portmap; with nfs-utils-1.2.3 from nfs.sf.net, and with a
2.6.35-020635rc1-generic kernel package (read: 2.6.35-something)).

Is this correct, i.e. svcgssd still needs to be adapted to IPv6? Or are 
there configuration options that should make the above work?

Best regards,

Valentijn Sessink

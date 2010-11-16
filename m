Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from filter.openoffice.nl ([217.170.2.175]:34157 "EHLO
	filter.openoffice.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933144Ab0KPO1u (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Nov 2010 09:27:50 -0500
Received: from localhost (localhost [127.0.0.1])
	by filter.openoffice.nl (Postfix) with ESMTP id 11BD22439FB
	for <linux-nfs@vger.kernel.org>; Tue, 16 Nov 2010 15:27:47 +0100 (CET)
Received: from filter.openoffice.nl ([127.0.0.1])
	by localhost (post-it.openoffice.nl [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id s1pjOyehq6HC for <linux-nfs@vger.kernel.org>;
	Tue, 16 Nov 2010 15:27:42 +0100 (CET)
Received: from blub.net (mail.blub.net [95.97.76.243])
	by filter.openoffice.nl (Postfix) with ESMTP id 281352437F3
	for <linux-nfs@vger.kernel.org>; Tue, 16 Nov 2010 15:27:42 +0100 (CET)
Received: from stout.kantoor.openoffice.nl (unknown [IPv6:2001:7b8:1529::1234:5678])
	by blub.net (Postfix) with ESMTP id 0FA813003C5
	for <linux-nfs@vger.kernel.org>; Tue, 16 Nov 2010 15:27:42 +0100 (CET)
Message-ID: <4CE294DD.6010508@blub.net>
Date: Tue, 16 Nov 2010 15:27:41 +0100
From: Valentijn Sessink <valentyn@blub.net>
To: linux-nfs@vger.kernel.org
Subject: no_root_squash (and valid KRB root-ticket)
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello list,

I found that having "no_root_squash" on the server, having a valid
Kerberos ticket for root@DOMAIN, does still not give you root rights on
a share. Looking further, I found
http://www.unix-info.org/nfsV4_howto_.txt that says that there is "no
proper mapping between root and the GSSAuthName"; but I could not find
the status of this document.

Could any of you comment on this? Is this still the case (I suppose so)?

Best regards,

Valentijn

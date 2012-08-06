Return-Path: linux-nfs-owner@vger.kernel.org
Received: from minas.ics.muni.cz ([147.251.4.40]:54210 "EHLO minas.ics.muni.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754867Ab2HFNzV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 Aug 2012 09:55:21 -0400
Received: from anubis.ics.muni.cz (anubis.ics.muni.cz [147.251.17.147])
	(authenticated user=xhejtman@IS.MUNI.CZ bits=0)
	by minas.ics.muni.cz (8.13.8/8.13.8/SuSE Linux 0.8) with ESMTP id q76DtHjb025451
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES128-SHA bits=128 verify=NO)
	for <linux-nfs@vger.kernel.org>; Mon, 6 Aug 2012 15:55:19 +0200
Received: from xhejtman by anubis.ics.muni.cz with local (Exim 4.80)
	(envelope-from <xhejtman@ics.muni.cz>)
	id 1SyNm9-0007rk-Oo
	for linux-nfs@vger.kernel.org; Mon, 06 Aug 2012 15:55:17 +0200
Date: Mon, 6 Aug 2012 15:55:17 +0200
From: Lukas Hejtmanek <xhejtman@ics.muni.cz>
To: linux-nfs@vger.kernel.org
Subject: NFSv4 backchannel authentication
Message-ID: <20120806135517.GS25979@ics.muni.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

it seems that RHEL NFSv4 servers use GSS authentication for backchannels as
well (if mount it with GSS). That would be OK, but it requires that server is
running rpc.gssd and the client is running rpc.svcgssd, which is not usual.

Is there a way how to mount clients with sec=krb5/i/p and use backchannels just
with UNIX auth?

-- 
Luká¹ Hejtmánek

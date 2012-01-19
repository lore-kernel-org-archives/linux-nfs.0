Return-Path: linux-nfs-owner@vger.kernel.org
Received: from minas.ics.muni.cz ([147.251.4.40]:54920 "EHLO minas.ics.muni.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751567Ab2ASN5Z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Jan 2012 08:57:25 -0500
Received: from anubis.ics.muni.cz (anubis.ics.muni.cz [147.251.17.147])
	(authenticated user=xhejtman@IS.MUNI.CZ bits=0)
	by minas.ics.muni.cz (8.13.8/8.13.8/SuSE Linux 0.8) with ESMTP id q0JDots6011407
	(version=TLSv1/SSLv3 cipher=AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Thu, 19 Jan 2012 14:50:56 +0100
Received: from xhejtman by anubis.ics.muni.cz with local (Exim 4.76)
	(envelope-from <xhejtman@anubis.ics.muni.cz>)
	id 1RnsO4-00050a-8O
	for linux-nfs@vger.kernel.org; Thu, 19 Jan 2012 14:50:44 +0100
Date: Thu, 19 Jan 2012 14:50:44 +0100
From: Lukas Hejtmanek <xhejtman@ics.muni.cz>
To: linux-nfs@vger.kernel.org
Subject: NFSv4 and high-availability
Message-ID: <20120119135044.GS10362@ics.muni.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

are there currently any options for HA setups with NFSv4? Is it possible to
migrate an NFSv4 klient from one server to another one on the fly? (Without
remount, closing all apps, and so on, in the case that all NFSv4 servers share
the same storage).

I know it could be possible to migrate IP address from a crashed NFSv4 server
to another one, but this solution seems to be a last resort for us. Are there
any options client based?

-- 
Luká¹ Hejtmánek

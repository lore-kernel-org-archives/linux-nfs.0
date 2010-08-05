Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from minas.ics.muni.cz ([147.251.4.40]:53735 "EHLO minas.ics.muni.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759214Ab0HEMww (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Aug 2010 08:52:52 -0400
Received: from anubis.ics.muni.cz (anubis.ics.muni.cz [147.251.3.109])
	(authenticated user=xhejtman@IS.MUNI.CZ bits=0)
	by minas.ics.muni.cz (8.13.8/8.13.8/SuSE Linux 0.8) with ESMTP id o75ClDeH015225
	(version=TLSv1/SSLv3 cipher=AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Thu, 5 Aug 2010 14:47:14 +0200
Received: from xhejtman by anubis.ics.muni.cz with local (Exim 4.72)
	(envelope-from <xhejtman@anubis.ics.muni.cz>)
	id 1Ogzr7-0004gD-1w
	for linux-nfs@vger.kernel.org; Thu, 05 Aug 2010 14:47:29 +0200
Date: Thu, 5 Aug 2010 14:47:29 +0200
From: Lukas Hejtmanek <xhejtman@ics.muni.cz>
To: linux-nfs@vger.kernel.org
Subject: ACLs
Message-ID: <20100805124729.GD31049@ics.muni.cz>
Content-Type: text/plain; charset=iso-8859-2
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello,

I use nfs4-acl-tools-0.3.3 and I get some oddities when setting the ACL:

$ nfs4_getfacl test
A::OWNER@:rwatTcCy
A::xhejtman@META:rtcy
A::GROUP@:tcy
A::EVERYONE@:tcy
$ nfs4_setfacl -s "A::ludek@META:R" test
$ nfs4_getfacl test
D::OWNER@:r
A::OWNER@:tTcCy
A::ludek@META:rtcy
A::GROUP@:tcy
A::EVERYONE@:tcy

is this something expected or buggy acl-tools?

-- 
Luká¹ Hejtmánek

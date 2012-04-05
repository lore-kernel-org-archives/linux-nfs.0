Return-Path: linux-nfs-owner@vger.kernel.org
Received: from minas.ics.muni.cz ([147.251.4.40]:37470 "EHLO minas.ics.muni.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753976Ab2DEKwF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Apr 2012 06:52:05 -0400
Received: from anubis.ics.muni.cz (igw1.zrnko.net [94.112.253.31])
	(authenticated user=xhejtman@IS.MUNI.CZ bits=0)
	by minas.ics.muni.cz (8.13.8/8.13.8/SuSE Linux 0.8) with ESMTP id q35AVjEq016569
	(version=TLSv1/SSLv3 cipher=AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Thu, 5 Apr 2012 12:31:46 +0200
Received: from xhejtman by anubis.ics.muni.cz with local (Exim 4.76)
	(envelope-from <xhejtman@ics.muni.cz>)
	id 1SFjyO-0005Li-0j
	for linux-nfs@vger.kernel.org; Thu, 05 Apr 2012 12:31:24 +0200
Date: Thu, 5 Apr 2012 12:31:24 +0200
From: Lukas Hejtmanek <xhejtman@ics.muni.cz>
To: linux-nfs@vger.kernel.org
Subject: NFSv4 high availability setups
Message-ID: <20120405103124.GV4752@ics.muni.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

we got several front-ends for a shared storage. We want to build HA setup so
that failed front-end fails over to another front-end (that is serving NFSv4
already). 

As I understand, NFS4 uses state dir somewhere in /var/lib/nfs/rpc_pipefs.

Can we put this state dir on a shared volume so that this state dir is common
for all the front-ends serving the same content? Is is supposed to work and
NFSv4 can merge its state with existing state on a shared disk?

-- 
Luká¹ Hejtmánek

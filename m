Return-Path: linux-nfs-owner@vger.kernel.org
Received: from tirith.ics.muni.cz ([147.251.4.36]:40709 "EHLO
	tirith.ics.muni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750953Ab2JOQwI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Oct 2012 12:52:08 -0400
Received: from anubis.ics.muni.cz (igw1.zrnko.net [94.112.253.31])
	(authenticated user=xhejtman@META bits=0)
	by tirith.ics.muni.cz (8.13.8/8.13.8/SuSE Linux 0.8) with ESMTP id q9FGcvu3007460
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES128-SHA bits=128 verify=NO)
	for <linux-nfs@vger.kernel.org>; Mon, 15 Oct 2012 18:38:59 +0200
Received: from xhejtman by anubis.ics.muni.cz with local (Exim 4.80)
	(envelope-from <xhejtman@ics.muni.cz>)
	id 1TNngp-0000Mk-Qp
	for linux-nfs@vger.kernel.org; Mon, 15 Oct 2012 18:38:51 +0200
Date: Mon, 15 Oct 2012 18:38:51 +0200
From: Lukas Hejtmanek <xhejtman@ics.muni.cz>
To: linux-nfs@vger.kernel.org
Subject: nfsv4 monitoring tool
Message-ID: <20121015163851.GO5412@ics.muni.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

is there any NFSv4 monitoring tool, that can be run on NFSv4 server (running
NFSv4.0 + GSS) and that reports statistics per connected client? I would like
to see amount of transfered data for each client, latency of RPC calls, rate
of requests.

nfsstat on server does not distinguish individual clients. 
nfswatch does not support NFSv4

I didn't find anything else. Do I need to create the tool by myself or is
there free of paid tool thad does the job?

-- 
Luká¹ Hejtmánek

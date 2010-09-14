Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-out-105.synserver.de ([212.40.180.105]:1072 "HELO
	smtp-out-099.synserver.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with SMTP id S1752113Ab0INJrF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Sep 2010 05:47:05 -0400
Received: from www-data by saphir-ld-031.synserver.de with local (Exim 4.63)
	(envelope-from <fanpost@uninverse.de>)
	id 1OvRdx-0008Pj-AQ
	for linux-nfs@vger.kernel.org; Tue, 14 Sep 2010 11:17:37 +0200
To: linux-nfs@vger.kernel.org
Subject: NFS strange sync issues - different versions of same file using multiple clients 
From: "fanpost@uninverse.de" <fanpost@uninverse.de>
Content-Type: text/plain;
	charset="iso-8859-1"
Message-Id: <E1OvRdx-0008Pj-AQ@saphir-ld-031.synserver.de>
Date: Tue, 14 Sep 2010 11:17:37 +0200
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello Group,

I already send this post to the opensuse forum without response,
maybe you can help:

we recognized very strange behaviour of nfs:

Use case:

Users access their files on different host through nfs4 (plain sys auth no kerberos sec).
They modify a c++ program and change parameters,
recompile it and execute it on different hosts for simulation.

We now observed that sometimes even after modifying and recompiling
the binary, an o l d version of the same binary is executed
The Binary resides on a nfs share.

1) Write changes X to the Program and compile + execute it on PC A
2) Write changes Y to the Program and compile + execute it on PC B

Instead of executing Program Y on PC B results and logging shows that actually the old version
(X) is executed on PC B.

Neither the problem nor the working execution is 100% reproducible.
Seems to have something to do with caching.

Ciao,

Josh



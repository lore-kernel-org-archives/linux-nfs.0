Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.logilab.fr ([213.215.7.51]:38552 "EHLO tucana.logilab.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752342AbbAMQoA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Jan 2015 11:44:00 -0500
Date: Tue, 13 Jan 2015 17:36:19 +0100
From: Julien Cristau <julien.cristau@logilab.fr>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org
Cc: David Douard <david.douard@logilab.fr>
Subject: nfs client stat() performance degradation
Message-ID: <20150113163618.GA17059@sh76.dev.logilab.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

we're experiencing some troubling performance issues with our nfs clients.  One
of the symptoms is degraded performance of directory walks with hot caches and
expired attribute caches: "find -ls" in the kernel tree goes from about 4s
(cold caches) to 1.5s (hot vm caches) and then to 18s after actimeo.  Network
traffic increases by about the same amount.  "echo 3 >
/proc/sys/vm/drop_caches" brings back the initial performance (~4s), but so do
writing 1 or 2.

This was reported almost two years ago in https://bugs.debian.org/702477 but I
don't know if this is a known issue upstream.  Seen on various kernel versions,
up to 3.18.

Is there anything we can do to track this down, or are there known workarounds
for this?

Thanks,
Julien
-- 
Julien Cristau          <julien.cristau@logilab.fr>
Logilab		        http://www.logilab.fr/
Informatique scientifique & gestion de connaissances

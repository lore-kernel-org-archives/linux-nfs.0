Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ironport02-1.csupomona.edu ([134.71.187.45]:36617 "EHLO
	ironport02-1.csupomona.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759509Ab3GSAmE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Jul 2013 20:42:04 -0400
Received: from localhost (localhost [127.0.0.1])
	by tweak.unx.csupomona.edu (Postfix) with ESMTP id 37BB4134034
	for <linux-nfs@vger.kernel.org>; Thu, 18 Jul 2013 17:41:57 -0700 (PDT)
Received: from tweak.unx.csupomona.edu ([127.0.0.1])
	by localhost (tweak.unx.csupomona.edu [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id dKpgQN0nQSuL for <linux-nfs@vger.kernel.org>;
	Thu, 18 Jul 2013 17:41:57 -0700 (PDT)
Received: from localhost.localdomain (woof.iitsystems.csupomona.edu [134.71.248.29])
	(using SSLv3 with cipher ECDHE-RSA-AES128-SHA (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: bldewolf)
	by tweak.unx.csupomona.edu (Postfix) with ESMTPSA id 0CA5F134070
	for <linux-nfs@vger.kernel.org>; Thu, 18 Jul 2013 17:41:57 -0700 (PDT)
Date: Thu, 18 Jul 2013 17:41:55 -0700
From: Brian De Wolf <bldewolf@csupomona.edu>
To: Linux NFS list <linux-nfs@vger.kernel.org>
Subject: NFS uses wrong domain in SETATTR
Message-ID: <20130718174155.0f189280@csupomona.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

Found another problem related to idmapping, I think.  One of our users
reported chgrp had stopped working (under 3.4.44, coming from 3.2.11).
I reproduced it under krb5i (I can send the cap if necessary).  The
SETATTR call is failing because it is not using the domain as set in
idmapd.conf, but the domain of the host instead.

So, for example, our domain is csupomona.edu.  Trying to run "chgrp
csupomona testfile" should set the group to csupomona@csupomona.edu,
but the NFS layer is sending csupomona@unx.csupomona.edu (the subdomain
of the host).

The idmapper seems to know what's going on, as the -vvv output produces:

nfsidmap[3598]: key: 0x3df841e type: group value: 17730 timeout 600
nfsidmap[3598]: libnfsidmap: using domain: csupomona.edu
nfsidmap[3598]: libnfsidmap: loaded plugin /usr/lib64/libnfsidmap/nsswitch.so for method nsswitch

Am I missing some simple host configuration or is this a deeper issue?

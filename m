Return-Path: linux-nfs-owner@vger.kernel.org
Received: from s22.webhostingserver.nl ([195.211.72.238]:64595 "EHLO
	s22.webhostingserver.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752748Ab3FHVAH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 8 Jun 2013 17:00:07 -0400
Received: from localhost ([::1] helo=vdtoorn.nl)
	by s22.webhostingserver.nl with esmtpa (Exim 4.80.1)
	(envelope-from <richard@vdtoorn.nl>)
	id 1UlPYI-000Aez-KO
	for linux-nfs@vger.kernel.org; Sat, 08 Jun 2013 22:15:54 +0200
Message-ID: <3e068504c6a4b683359bad7610d84bc5.squirrel@vdtoorn.nl>
Date: Sat, 8 Jun 2013 22:15:54 +0200
Subject: Kerberized NFS failure with 3.9.0-rc1 (and later)
From: richard@vdtoorn.nl
To: linux-nfs@vger.kernel.org
Reply-To: richard@vdtoorn.nl
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi All,

I'm succesfully running a kerberized NFS system on a machine with linux
kernel 3.8.0 and 3.8.13. However when upgrading to 3.9, it's either giving
an access denied upon mount, or completely locking up.

Some details:

Client: debian unstable "Sid", kernel 3.9.0 (nfs-common=1.2.8-4)
Server: debian 7.0 "Wheezy", nfs-common=1.2.6-3

When upgrading the server to 3.9.0-rc1, it's giving access denied
When upgrading the server to 3.9.0 or 3.9.5, it's locking

There is no error on the server, but the logfile on the client mentions
the following:

rpc.gssd[1930]: ERROR: GSS-API: error in gss_free_lucid_sec_context():
GSS_S_NO_CONTEXT (No context has been established) - Unknown error
Jun  8 21:22:42 dell rpc.gssd[1930]: WARN: failed to free lucid sec context

Can anyone help out with this? Is there anything that needed to be
configured in the newer kernels? All crypto stuff and kerberos
configuration files are unchanged.

Thanks alot,

Richard van den Toorn
(The Netherlands)






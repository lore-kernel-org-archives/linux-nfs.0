Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.mcs.de ([212.1.60.21]:46141 "EHLO smtp.mcs.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753772Ab0FKVl6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Jun 2010 17:41:58 -0400
Received: from p4fe415b6.dip0.t-ipconnect.de ([79.228.21.182]:61470 helo=[192.168.64.24])
	by smtp.mcs.de with esmtpa (Exim 4.71)
	(envelope-from <slink@schokola.de>)
	id 1ONBZh-00052X-9d
	for linux-nfs@vger.kernel.org; Fri, 11 Jun 2010 23:15:38 +0200
Message-ID: <4C12A779.6010005@schokola.de>
Date: Fri, 11 Jun 2010 23:15:37 +0200
From: Nils Goroll <slink@schokola.de>
To: linux-nfs@vger.kernel.org
Subject: nfs4 locks: What happens when a lease can't get renewed?
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

I wonder what happens if a lock on nfs4 has been acquired by an application (for
instance, using fcntl(fd, F_SETLK, F_WRLCK)) and the lock can't be RENEWed, for
instance due to a network outage preventing communication between the client and
the server.

I would have thought that some notification mechanism was useful, for instance
my means of delivery of a signal as set using F_SETOWN / F_SETSIG for leases.

I would highly appreciate helpful pointers should this question have already
been discussed of if there exists any other helpful documentation on it.

Thank you,

Nils

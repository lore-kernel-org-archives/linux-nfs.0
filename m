Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mta1.cl.cam.ac.uk ([128.232.0.15]:46249 "EHLO mta1.cl.cam.ac.uk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754744Ab0FHL7S (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Jun 2010 07:59:18 -0400
Received: from viterbi.cl.cam.ac.uk ([128.232.8.5] helo=cl.cam.ac.uk)
	by mta1.cl.cam.ac.uk with esmtp (Exim 3.092 #1)
	id 1OLx3z-0004tq-00
	for linux-nfs@vger.kernel.org; Tue, 08 Jun 2010 12:33:47 +0100
To: linux-nfs@vger.kernel.org
Subject: mount.nfs probes NFS server from non-priviledged port
Content-Type: text/plain; charset=us-ascii
Date: Tue, 08 Jun 2010 12:33:47 +0100
From: Markus Kuhn <Markus.Kuhn@cl.cam.ac.uk>
Message-Id: <E1OLx3z-0004tq-00@mta1.cl.cam.ac.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

In order to improve the security of our departmental NetApp filer, we
tried to block in our IP router access from our Linux NFSv3 clients to
tcp port 2049 of the NFS server from non-priviledged (>1023) client
ports.

However, it turns out that on some Linux distributions (e.g., CentOS
5.5, Fedora 6-9), this caused the mount command to fail. It appears that
during a new mount attempt, the client sends a NULL RPC request from a
non-priviledged TCP port. If that is blocked by a firewall, the mount
command hangs for a long time and eventually fails with a not-found
error. It also seems that not all Linux distributions do this.

Why does this happen? Is there a configuration setting that will disable
this use of un-priviledged client ports during a mount, which currently
prevents us improving the security of our NFS setup?

Thanks for any suggestions ...

Markus

-- 
Markus Kuhn, Computer Laboratory, University of Cambridge
http://www.cl.cam.ac.uk/~mgk25/ || CB3 0FD, Great Britain


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:45866 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754082Ab0H3NFG convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Aug 2010 09:05:06 -0400
From: Olaf Kirch <okir@suse.de>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 0/2] Make libtirpc work with old style portmapper
Date: Mon, 30 Aug 2010 15:03:19 +0200
Cc: nfsv4@linux-nfs.org, Steve Dickson <SteveD@redhat.com>
Content-Type: Text/Plain;
  charset="iso-8859-1"
Message-Id: <201008301503.19783.okir@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


Hi Steve et al,

We recently got a bug report from a customer trying to run nfs-utils
(which is compiled against libtirpc on SLES 11) on a system with
portmapper installed instead of rpcbind. Which failed miserably,
because none of the RPC servers was able to register with portmap.

One might argue, if it hurts don't do it, but OTOH this configuration
isn't totally outlandish. In particular, ISVs may decide they want
to compile an RPC enabled application against libtirpc, but still
want it to run on a wide range of Linux versions.

I looked into the issue and put together the following two patches,
which I'm submitting for your kindly review.

Thanks
Olaf
-- 
Neo didn't bring down the Matrix. SOA did. (soafacts.com)
--------------------------------------------
Olaf Kirch - Director Server (okir@novell.com)
SUSE LINUX Products GmbH, Maxfeldstr. 5, D-90409 Nürnberg
GF: Markus Rex, HRB 16746 (AG Nürnberg)

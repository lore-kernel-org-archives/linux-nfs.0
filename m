From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH] nfsd: make sure all sv_permsocks have lockd references
Date: Thu, 17 Jun 2010 10:17:45 -0400
Message-ID: <1276784267-28500-1-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, chris-TF6qbakwsgc2epGFuHBODCp2UmYkHbXO@public.gmane.org,
	linux-kernel@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40067 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760043Ab0FQOWH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Jun 2010 10:22:07 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patchset should apply cleanly to the other patches that I've sent
recently. They fix some (theoretical) problems with the text-based write
ports and nfsd_init_socks interfaces.

The problem is that nfsd_last_thread expects that every socket on
sv_permsocks has a corresponding lockd reference, but there a couple of
ways to get sockets onto that list without getting a lockd reference.

This patch fixes all that I could spot. I suspect that this, along with
the other patches that I proposed earlier will fix the problem that
Chris Vine reported.

I've done some basic smoke testing with them and they seem to work
as expected.

I've also put the entire patch stack in my git tree on kernel.org:

http://git.kernel.org/?p=linux/kernel/git/jlayton/linux.git;a=summary

...in the nfsd-error branch. It may be more convenient to pull them
from there.

Jeff Layton (2):
  nfsd: shut down transport in nfsd_init_socks if no lockd reference
  nfsd: have __write_ports_add/delxprt get/put lockd references for
    transports

 fs/nfsd/nfsctl.c |   59 ++++++++++++++++++++++++++++++++++++++---------------
 fs/nfsd/nfssvc.c |   21 +++++++++++++++---
 2 files changed, 59 insertions(+), 21 deletions(-)


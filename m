Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:34201 "EHLO
	mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751646AbcESPf2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 May 2016 11:35:28 -0400
Received: by mail-qk0-f196.google.com with SMTP id i7so7889056qkd.1
        for <linux-nfs@vger.kernel.org>; Thu, 19 May 2016 08:35:27 -0700 (PDT)
From: Paulo Andrade <paulo.cesar.pereira.de.andrade@gmail.com>
To: libtirpc-devel@lists.sourceforge.net
Cc: linux-nfs@vger.kernel.org, Paulo Andrade <pcpa@gnu.org>
Subject: [PATCH v2 0/3] Do not hold clnt_fd_lock mutex during connect
Date: Thu, 19 May 2016 12:35:07 -0300
Message-Id: <1463672110-10026-1-git-send-email-pcpa@gnu.org>
In-Reply-To: <1463593885-1179-1-git-send-email-pcpa@gnu.org>
References: <1463593885-1179-1-git-send-email-pcpa@gnu.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

  The original patch was  split in 3 new patches,  addressing some  concerns
brough in the first  version, about  thread safety of data accessed  without
the lock held.

  It was also added an extra  change to save the errno value before  calling
syslog.

  Original description of what the problem corrects follows:

  An user  reports  that  their  application  connects to  multiple  servers
through a rpc interface using  libtirpc. When one of  the servers misbehaves
(goes down  ungracefully or  has a  delay of  a few  seconds in  the traffic
flow), it was observed that the traffic from the  client to other servers is
decreased by  the  traffic  anomaly  of  the failing  server,  i.e.  traffic
decreases or goes to 0 in all the servers.

  When investigated further, specifically into the behavior  of the libtirpc
at the  time of  the issue,  it  was observed  that all  of the  application
threads specifically interacting with  libtirpc were locked into  one single
lock inside  the  libtirpc library.  This  was a  race  condition which  had
resulted in a deadlock and hence the resultant dip/stoppage of traffic.

  As an experiment, the user removed the libtirpc from the application build
and used the  standard glibc  library for rpc  communication. In  that case,
everything worked perfectly even  in the time  of the issue of  server nodes
misbehaving.

Paulo Andrade (3):
  Make it clear rpc_createerr is thread safe
  Record errno value before calling syslog
  Do not hold a global mutex during connect

 src/clnt_vc.c | 24 ++++++++++++++----------
 1 file changed, 14 insertions(+), 10 deletions(-)

-- 
1.8.3.1


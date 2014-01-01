Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qe0-f46.google.com ([209.85.128.46]:48920 "EHLO
	mail-qe0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753588AbaAAM2m (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Jan 2014 07:28:42 -0500
Received: by mail-qe0-f46.google.com with SMTP id a11so13085971qen.19
        for <linux-nfs@vger.kernel.org>; Wed, 01 Jan 2014 04:28:42 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: simo@redhat.com, bfields@fieldses.org, neilb@suse.de
Subject: [RFC PATCH 0/5] sunrpc: change handling of use-gss-proxy file
Date: Wed,  1 Jan 2014 07:28:29 -0500
Message-Id: <1388579314-15255-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Consider this patch a RFC at this point. This changes how the
use-gss-proxy file works, and alters the kernel upcall to delay a little
bit before giving up on it if gssproxy isn't up yet.

It's not heavily tested yet, but it seems to do the right thing...

I think the first patch isn't too controversial. The big question is
whether the initial upcall delay is desirable.

Thoughts?

Jeff Layton (5):
  sunrpc: don't wait for write before allowing reads from use-gss-proxy
    file
  sunrpc: don't hang indefinitely in wait_for_gss_proxy
  sunrpc: wait for gssproxy to start on initial upcall attempt before
    falling back to legacy upcall
  sunrpc: fix potential race between setting use_gss_proxy and the
    upcall rpc_clnt
  sunrpc: allow gssproxy to be explicitly disabled from userland

 net/sunrpc/auth_gss/svcauth_gss.c | 72 +++++++++++++++++++++------------------
 1 file changed, 39 insertions(+), 33 deletions(-)

-- 
1.8.4.2


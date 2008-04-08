From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: librpcsecgss-0.18
Date: Tue, 8 Apr 2008 18:31:47 -0400
Message-ID: <4d569c330804081531j442302e9hb49129b225a916af@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.30]:24720 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752862AbYDHWbs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Apr 2008 18:31:48 -0400
Received: by yw-out-2324.google.com with SMTP id 5so431457ywb.1
        for <linux-nfs@vger.kernel.org>; Tue, 08 Apr 2008 15:31:47 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A new version of librpcsecgss is now available from:

http://www.citi.umich.edu/projects/nfsv4/linux/librpcsecgss/librpcsecgss-0.18.tar.gz

Changes since librpcsecgss-0.17:

    * A patch from John Hendrickson <hendrickson@google.com> to fix
      clnttcp_create() so that it handles an EINTR return value from
      connect.  This fixes a problem with mounts to distant servers
      sometimes failing with:

      rpc.gssd[7157]: WARNING: can't create tcp rpc_clnt for server
      nfs.example.com for user with uid 23456: RPC: Remote system
      error - Interrupted system call

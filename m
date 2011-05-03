Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:31569 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754669Ab1ECTwZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 May 2011 15:52:25 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: jlayton@redhat.com, linux-nfs@vger.kernel.org
Subject: [RFC 0/1] SUNRPC: dynamic rpc_slot allocator for TCP 
Date: Mon,  2 May 2011 21:40:07 -0400
Message-Id: <1304386808-2733-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0


I would appreciate comments on this patch. I've done a small amount of testing
where I've set the /proc/sys/sunrpc/tcp_slot_table_entries to 2, and watched
the dynamic allocator increase it to 3. I have a 10G test system being
configured.

Thanks!

-->Andy

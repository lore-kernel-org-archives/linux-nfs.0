Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14089 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752332Ab0ARTrw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Jan 2010 14:47:52 -0500
Date: Mon, 18 Jan 2010 14:47:46 -0500
From: Jeff Layton <jlayton@redhat.com>
To: chuck.lever@oracle.com, steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: enabling IPv6
Message-ID: <20100118144746.1e05865e@tlielax.poochiereds.net>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

With the commit of the statd patches over the weekend, we're now
positioned to be able to ship IPv6-enabled nfs-utils in distros. There
is a potential snag though...

Consider this situation:

Admin has a Linux server set up. Server has both IPv4 and IPv6 addrs.
Both addresses are in DNS.

Without an IPv6-enabled nfs-utils, he mounts via IPv4 and all works
fine. Now with an IPv6 enabled nfs-utils, mount.nfs prefers the IPv6
addr and the mount fails (or hangs for a long time and then fails, if
it's using NFSv4)...

While I don't really like it, I think we may need to consider making
mount.nfs prefer IPv4 addrs when it can resolve a hostname to both v4
and v6. Otherwise, we run the risk of breaking an awful lot of working
setups...

Thoughts?

-- 
Jeff Layton <jlayton@redhat.com>

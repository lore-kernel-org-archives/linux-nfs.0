Return-Path: linux-nfs-owner@vger.kernel.org
Received: from trent.utfs.org ([94.185.90.103]:51346 "EHLO trent.utfs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751691Ab3HLISt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Aug 2013 04:18:49 -0400
Date: Mon, 12 Aug 2013 01:18:39 -0700 (PDT)
From: Christian Kujau <lists@nerdbynature.de>
To: Karl Schmidt <karl@xtronics.com>
cc: 714974@bugs.debian.org, jfs-discussion@lists.sourceforge.net,
        Jonathan McDowell <noodles@earth.li>,
        Ben Hutchings <ben@decadent.org.uk>, linux-nfs@vger.kernel.org,
        dave.kleikamp@oracle.com
Subject: Re: [Jfs-discussion] NFS 'readdir loop' error on JFS
In-Reply-To: <alpine.DEB.2.10.1308092352550.7081@trent.utfs.org>
Message-ID: <alpine.DEB.2.10.1308120113360.7081@trent.utfs.org>
References: <1373245980.3428.46.camel@deadeye.wl.decadent.org.uk> <520554A5.3060401@xtronics.com> <alpine.DEB.2.10.1308092352550.7081@trent.utfs.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

FWIW, this still happens when both client & server are running Linux 
3.11.0-rc5 (vanilla).

$ dpkg -l | grep nfs | cut -c-70
ii  libnfsidmap2:amd64                 0.25-4                    amd64
ii  nfs-common                         1:1.2.6-4                 amd64
ii  nfs-kernel-server                  1:1.2.6-4                 amd64

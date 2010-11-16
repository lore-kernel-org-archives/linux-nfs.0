Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:46812 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753445Ab0KPURz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Nov 2010 15:17:55 -0500
Date: Tue, 16 Nov 2010 15:17:53 -0500
From: Jim Rees <rees@umich.edu>
To: Valentijn Sessink <valentyn@blub.net>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Strange rpc.svcgssd behavior
Message-ID: <20101116201753.GB4482@merit.edu>
References: <1C8B051A-5DC1-4871-B9B9-96E571036A9B@oracle.com>
 <4CE2AA3B.6070302@openoffice.nl>
 <4CE2DF2D.9070603@blub.net>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4CE2DF2D.9070603@blub.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Valentijn Sessink wrote:

  Quoting myself: ...
  Op 16-11-10 16:58, Valentijn Sessink schreef:
  >We have been disabling NM for years now because of this.
  >>Now I reboot, and NetworkManager happily adds "your.host	your" back to the "::1" entry, and rpc.svcgssd fails again.
  
  ... here's the long standing bug report for Ubuntu:
  https://bugs.launchpad.net/ubuntu/+source/network-manager/+bug/8980
  
  (Been there since 2004). Nobody uses hostnames anymore, I guess ;)

It corrupts your resolv.conf too.  You should always remove Network Manager
except on mobile hosts that really need it.

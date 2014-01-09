Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.195]:58018 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750832AbaAICBB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Jan 2014 21:01:01 -0500
Date: Wed, 8 Jan 2014 21:00:58 -0500
From: Jim Rees <rees@umich.edu>
To: linux-nfs@vger.kernel.org
Subject: Re: client using portmap/rpcbind when port options are given?
Message-ID: <20140109020058.GA8351@umich.edu>
References: <20140108234258.GA11800@umich.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140108234258.GA11800@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jim Rees wrote:

  How come my nfs client is trying to contact portmap when I've given both the
  port= and mountport= options? Is it supposed to do that? Nfs3, nolock,
  kernel 3.12, nfsutils 1.2.9 on Arch.

To answer my own question... you have to specify transport protocol. I had
thought that since tcp is the default, I wouldn't need that option, but I
do.

Thanks everyone for the help.

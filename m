Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:43460 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757318AbZINWSl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Sep 2009 18:18:41 -0400
Received: from list by lo.gmane.org with local (Exim 4.50)
	id 1MnJsg-0003Z1-Q8
	for linux-nfs@vger.kernel.org; Tue, 15 Sep 2009 00:18:44 +0200
Received: from inferno.cora.nwra.com ([65.44.101.162])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2009 00:18:42 +0200
Received: from orion by inferno.cora.nwra.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2009 00:18:42 +0200
To: linux-nfs@vger.kernel.org
From: Orion Poplawski <orion@cora.nwra.com>
Subject: Re: NFS slow to respond on resumption from hibernate
Date: Mon, 14 Sep 2009 22:18:19 +0000 (UTC)
Message-ID: <loom.20090915T001738-235@post.gmane.org>
References: <loom.20090910T180831-552@post.gmane.org> <1252602040.8722.128.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Trond Myklebust <trond.myklebust@...> writes:
> Start by upgrading to the very latest Fedora kernel, which is 2.6.30
> based. There are a couple of RPC/tcp reconnection fixes there that
> didn't make it into 2.6.29.

Updated to 2.6.30.5 in F11 and that indeed seems to have fixed it.  Thanks!

- Orion


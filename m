Return-Path: linux-nfs-owner@vger.kernel.org
Received: from lxorguk.ukuu.org.uk ([81.2.110.251]:40954 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759779Ab2HJSWa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Aug 2012 14:22:30 -0400
Date: Fri, 10 Aug 2012 19:26:28 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Stanislav Kinsbursky <skinsbursky@parallels.com>,
        Trond.Myklebust@netapp.com, davem@davemloft.net,
        linux-nfs@vger.kernel.org, eric.dumazet@gmail.com, xemul@parallels.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        bfields@fieldses.org, viro@zeniv.linux.org.uk,
        tim.c.chen@linux.intel.com, devel@openvz.org
Subject: Re: [RFC PATCH 0/2] net: connect to UNIX sockets from specified
 root
Message-ID: <20120810192628.79a34d28@pyramind.ukuu.org.uk>
In-Reply-To: <50254FA6.3060806@zytor.com>
References: <20120810125701.7115.71612.stgit@localhost.localdomain>
	<50254FA6.3060806@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> On that whole subject...
> 
> Do we need a Unix domain socket equivalent to openat()?

I don't think so. The name is just a file system indexing trick, it's not
really the socket proper. It's little more than "ascii string with
permissions attached" - indeed we also support an abstract name space
which for a lot of uses is actually more convenient.

AF_UNIX between roots raises some interesting semantic questions when you
begin passing file descriptors down them as well.

Alan

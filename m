Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:33117 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751427AbbHQMmU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Aug 2015 08:42:20 -0400
Date: Mon, 17 Aug 2015 05:42:20 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: nfs-utils regression on IPv6-less kernels
Message-ID: <20150817124220.GA17877@infradead.org>
References: <20150810131358.GA19466@infradead.org>
 <55C9D2F2.1020300@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <55C9D2F2.1020300@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 11, 2015 at 06:48:18AM -0400, Steve Dickson wrote:
> hmm... What do you mean "fails to start"...  are there any error messages?

[....] Starting NFS kernel daemon: nfsdrpc.nfsd: address family AF_INET6
not supported by protocol TCP
rpc.nfsd: unable to set any sockets for nfsd
 failed!

And then any attempts to mount from this machine fail.

> If nfs-utils is compiled with the --disable_ipv6 flag, does
> the same problem happen?

No, that fixes it.

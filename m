Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:50080 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762066AbbEERcH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 May 2015 13:32:07 -0400
Date: Tue, 5 May 2015 10:32:07 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: RFC: combine xprtrdma and svcrdma
Message-ID: <20150505173207.GA14409@infradead.org>
References: <CE0356DB-12BA-4208-83B1-E51B34B25388@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CE0356DB-12BA-4208-83B1-E51B34B25388@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 04, 2015 at 03:17:25PM -0400, Chuck Lever wrote:
> This isn?t a problem for TCP because both client and server side
> TCP socket support are built into the sunrpc.ko module. The client and
> server RDMA transport support are in separate modules.

A little offtopic, but at least the code structure is a nightmare for
TCP as well where we have a file like bc_svc.c which only has a single
function (bc_send), that happens to be called from backchannel-specific code
in svc.c just to call into a function in clnt.c that is entirely
backchannel-specific as well.  Of course due to the lack of separate
modules that at least doesn't cause problems for users.

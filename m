Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:42115 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756460AbbEESPS convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 May 2015 14:15:18 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: RFC: combine xprtrdma and svcrdma
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20150505173207.GA14409@infradead.org>
Date: Tue, 5 May 2015 14:15:07 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <4A99CF87-4AA6-4F60-9678-AE4F8B45E5AF@oracle.com>
References: <CE0356DB-12BA-4208-83B1-E51B34B25388@oracle.com> <20150505173207.GA14409@infradead.org>
To: Christoph Hellwig <hch@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On May 5, 2015, at 1:32 PM, Christoph Hellwig <hch@infradead.org> wrote:

> On Mon, May 04, 2015 at 03:17:25PM -0400, Chuck Lever wrote:
>> This isn?t a problem for TCP because both client and server side
>> TCP socket support are built into the sunrpc.ko module. The client and
>> server RDMA transport support are in separate modules.
> 
> A little offtopic, but at least the code structure is a nightmare for
> TCP as well where we have a file like bc_svc.c which only has a single
> function (bc_send), that happens to be called from backchannel-specific code
> in svc.c just to call into a function in clnt.c that is entirely
> backchannel-specific as well.  Of course due to the lack of separate
> modules that at least doesn't cause problems for users.

bc_svc.c struck me as left over from a prototype.

It would be reasonable to move bc_send into xprtsock.c (or some other
convenient file) and then pass its address into the server code via
a virtual function (eg. as an rpc_xprt op).

I’ve been scratching my head wondering why we have still have
CONFIG_SUNRPC_BACKCHANNEL, which is not exposed in menuconfig. Is it
time to remove it?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Strange lockup during unmount in 2.6.22 - maybe rpciod
	deadlock?
Date: Thu, 10 Jan 2008 20:26:32 -0500
Message-ID: <1200014792.20100.11.camel@heimdal.trondhjem.org>
References: <18310.37731.29874.582772@notabene.brown>
	 <1200004896.13775.27.camel@heimdal.trondhjem.org>
	 <18310.49514.808155.132856@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:36538 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756503AbYAKB0f (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Jan 2008 20:26:35 -0500
In-Reply-To: <18310.49514.808155.132856-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Fri, 2008-01-11 at 12:07 +1100, Neil Brown wrote:

> The only fix that occurs to me is to use schedule_work to shunt the
> rpc_shutdown_client into a separate thread.

Well. Instead of rpc_shutdown_client() you could use
rpc_release_client() in order to have the last RPC caller destroy the
client when the last rpc_task exits.
The problem then is that you lose the guarantee that all RPC tasks must
complete before you free structures such as the nfs_server...

Cheers
  Trond


From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 097/100] NLM: have nlm_shutdown_hosts kill off all NLM
	RPC tasks
Date: Fri, 25 Jan 2008 20:19:47 -0500
Message-ID: <1201310387.4150.21.camel@heimdal.trondhjem.org>
References: <20080125231521.GG25141@fieldses.org>
	 <1201303040-7779-83-git-send-email-bfields@citi.umich.edu>
	 <1201303040-7779-84-git-send-email-bfields@citi.umich.edu>
	 <1201303040-7779-85-git-send-email-bfields@citi.umich.edu>
	 <1201303040-7779-86-git-send-email-bfields@citi.umich.edu>
	 <1201303040-7779-87-git-send-email-bfields@citi.umich.edu>
	 <1201303040-7779-88-git-send-email-bfields@citi.umich.edu>
	 <1201303040-7779-89-git-send-email-bfields@citi.umich.edu>
	 <1201303040-7779-90-git-send-email-bfields@citi.umich.edu>
	 <1201303040-7779-91-git-send-email-bfields@citi.umich.edu>
	 <1201303040-7779-92-git-send-email-bfields@citi.umich.edu>
	 <1201303040-7779-93-git-send-email-bfields@citi.umich.edu>
	 <1201303040-7779-94-git-send-email-bfields@citi.umich.edu>
	 <1201303040-7779-95-git-send-email-bfields@citi.umich.edu>
	 <1201303040-7779-96-git-send-email-bfields@citi.umich.edu>
	 <1201303040-7779-97-git-send-email-bfields@citi.umich.edu>
	 <20080125185548.5363f046@tleilax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>,
	linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:36224 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754459AbYAZBTx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 20:19:53 -0500
In-Reply-To: <20080125185548.5363f046-RtJpwOs3+0O+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Fri, 2008-01-25 at 18:55 -0500, Jeff Layton wrote:
> There's also another problem -- it's possible for host->h_rpcclnt to be
> NULL, and that has special meaning for rpc_killall_tasks. For now, I
> suggest that we drop this patch until I have a chance to work on it
> further.

We really ought to create _separate_ lists for the client and server
uses of struct nlm_host.

Trond


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e33.co.us.ibm.com ([32.97.110.151]:38209 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751963Ab2BOWMZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Feb 2012 17:12:25 -0500
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Wed, 15 Feb 2012 15:12:25 -0700
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id DE9EC1FF004A
	for <linux-nfs@vger.kernel.org>; Wed, 15 Feb 2012 15:12:21 -0700 (MST)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q1FMC9LY142298
	for <linux-nfs@vger.kernel.org>; Wed, 15 Feb 2012 15:12:17 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q1FMC97B016230
	for <linux-nfs@vger.kernel.org>; Wed, 15 Feb 2012 15:12:09 -0700
Received: from malahal (malahal.austin.ibm.com [9.53.40.203])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id q1FMC9IX016212
	for <linux-nfs@vger.kernel.org>; Wed, 15 Feb 2012 15:12:09 -0700
Date: Wed, 15 Feb 2012 16:12:07 -0600
From: Malahal Naineni <malahal@us.ibm.com>
To: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 08/13] SUNRPC: Add API to acquire source address
Message-ID: <20120215221207.GB24995@us.ibm.com>
References: <20120215213336.3254.98936.stgit@ellison.1015granger.net>
 <20120215213550.3254.1420.stgit@ellison.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120215213550.3254.1420.stgit@ellison.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever [chuck.lever@oracle.com] wrote:
> +	rcu_read_lock();
> +	xprt = rcu_dereference(clnt->cl_xprt);
> +	salen = xprt->addrlen;
> +	memcpy(sap, &xprt->addr, salen);
> +	net = get_net(xprt->xprt_net);
> +	rcu_read_unlock();

Did I miss a patch that made cl_xprt go away unless accessed under RCU?

Thanks, Malahal.


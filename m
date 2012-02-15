Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:28973 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751059Ab2BOWRY convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Feb 2012 17:17:24 -0500
Subject: Re: [PATCH 08/13] SUNRPC: Add API to acquire source address
Mime-Version: 1.0 (Apple Message framework v1257)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20120215221207.GB24995@us.ibm.com>
Date: Wed, 15 Feb 2012 17:17:16 -0500
Cc: linux-nfs@vger.kernel.org
Message-Id: <3074EE50-6240-463D-9FCA-21E381976277@oracle.com>
References: <20120215213336.3254.98936.stgit@ellison.1015granger.net> <20120215213550.3254.1420.stgit@ellison.1015granger.net> <20120215221207.GB24995@us.ibm.com>
To: Malahal Naineni <malahal@us.ibm.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 15, 2012, at 5:12 PM, Malahal Naineni wrote:

> Chuck Lever [chuck.lever@oracle.com] wrote:
>> +	rcu_read_lock();
>> +	xprt = rcu_dereference(clnt->cl_xprt);
>> +	salen = xprt->addrlen;
>> +	memcpy(sap, &xprt->addr, salen);
>> +	net = get_net(xprt->xprt_net);
>> +	rcu_read_unlock();
> 
> Did I miss a patch that made cl_xprt go away unless accessed under RCU?

Malahal, I re-ordered these so the series includes only clean ups.  The RCU patch is now later.

Trond, would you like me to include the cl_xprt RCU patches in this "for 3.4" series too?  If not, I can rework this hunk.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com





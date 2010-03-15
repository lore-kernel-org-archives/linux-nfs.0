From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH 10/22] Add new pipefs file indicating which Kerberos
 enctypes the kernel supports
Date: Mon, 15 Mar 2010 16:36:01 +0000
Message-ID: <20100315163601.GW30031@ZenIV.linux.org.uk>
References: <1268655627-18712-1-git-send-email-steved@redhat.com>
 <1268655627-18712-11-git-send-email-steved@redhat.com>
 <1268670503.2993.103.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:34146 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964955Ab0COQgH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Mar 2010 12:36:07 -0400
In-Reply-To: <1268670503.2993.103.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 15, 2010 at 12:28:23PM -0400, Trond Myklebust wrote:

> No. We should rather export __rpc_create() to allow this code to be
> moved to the gss_krb5 module.

Careful with that...  There's a bunch of sanitizing to do in rpc_pipe
and exporting its guts wouldn't be a good idea ATM...

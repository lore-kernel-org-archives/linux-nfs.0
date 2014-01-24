Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e37.co.us.ibm.com ([32.97.110.158]:56781 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752481AbaAXO2z convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Jan 2014 09:28:55 -0500
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Fri, 24 Jan 2014 07:28:55 -0700
Received: from b03cxnp08027.gho.boulder.ibm.com (b03cxnp08027.gho.boulder.ibm.com [9.17.130.19])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id EBB0F3E4004E
	for <linux-nfs@vger.kernel.org>; Fri, 24 Jan 2014 07:28:52 -0700 (MST)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by b03cxnp08027.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s0OEScCf10355182
	for <linux-nfs@vger.kernel.org>; Fri, 24 Jan 2014 15:28:38 +0100
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s0OESqDm029948
	for <linux-nfs@vger.kernel.org>; Fri, 24 Jan 2014 07:28:52 -0700
Date: Fri, 24 Jan 2014 08:28:51 -0600
From: Malahal Naineni <malahal@us.ibm.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linuxnfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs: handle servers that support either ALLOW or DENY
 ACE types.
Message-ID: <20140124142851.GA13421@us.ibm.com>
References: <1390535453-15585-1-git-send-email-malahal@us.ibm.com>
 <979899AD-3AD6-4D89-B53F-1E30D4AB078B@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <979899AD-3AD6-4D89-B53F-1E30D4AB078B@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust [trond.myklebust@primarydata.com] wrote:
> 
> On Jan 23, 2014, at 20:50, Malahal Naineni <malahal@us.ibm.com> wrote:
> 
> > Currently we support ACLs if the NFS server file system supports
> > ALLOW and DENY ACE types. This patch makes the Linux client work with
> > ACLs if the server supports either ALLOW or DENY ACE types.
> 
> According to RFC5661, the behaviour if you don’t have ALLOW aces is to deny all access. How does it make sense to accept that?

I have a server that only returned 'ALLOW' type support probably due to
a bug!  There is nothing in the spec that said a server 'MUST' support
'ALLOW' and 'DENY' ACE types (RFC5661 does say 'SHOULD' though!). That
was my reasoning to fix the client to be more liberal/lenient.

Can a server implicitly construct 'ALLOW' ACEs based on mode and not
support explicitly setting such ACEs by a client? I am not too familiar
with ACLs, if you think we should only check for 'ALLOW' support flag, I
can re-spin the patch but I think it is better to be more lenient
specially if it is not incorrect by being more lenient!

Please let me know either way.

Regards, Malahal.


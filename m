Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e9.ny.us.ibm.com ([32.97.182.139]:50914 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751534AbaAXRRF convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Jan 2014 12:17:05 -0500
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Fri, 24 Jan 2014 12:17:05 -0500
Received: from b01cxnp22033.gho.pok.ibm.com (b01cxnp22033.gho.pok.ibm.com [9.57.198.23])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id A1D336E804C
	for <linux-nfs@vger.kernel.org>; Fri, 24 Jan 2014 12:16:58 -0500 (EST)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by b01cxnp22033.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s0OHH2ed7471390
	for <linux-nfs@vger.kernel.org>; Fri, 24 Jan 2014 17:17:02 GMT
Received: from d01av03.pok.ibm.com (localhost [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s0OHH2bD013859
	for <linux-nfs@vger.kernel.org>; Fri, 24 Jan 2014 12:17:02 -0500
Date: Fri, 24 Jan 2014 11:17:00 -0600
From: Malahal Naineni <malahal@us.ibm.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linuxnfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs: handle servers that support either ALLOW or DENY
 ACE types.
Message-ID: <20140124171700.GA8478@us.ibm.com>
References: <1390535453-15585-1-git-send-email-malahal@us.ibm.com>
 <979899AD-3AD6-4D89-B53F-1E30D4AB078B@primarydata.com>
 <20140124142851.GA13421@us.ibm.com>
 <EDB5CCCD-0940-46F2-B102-7094AE029170@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <EDB5CCCD-0940-46F2-B102-7094AE029170@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust [trond.myklebust@primarydata.com] wrote:
> 
> On Jan 24, 2014, at 7:28, Malahal Naineni <malahal@us.ibm.com> wrote:
> 
> > Trond Myklebust [trond.myklebust@primarydata.com] wrote:
> >> 
> >> On Jan 23, 2014, at 20:50, Malahal Naineni <malahal@us.ibm.com> wrote:
> >> 
> >>> Currently we support ACLs if the NFS server file system supports
> >>> ALLOW and DENY ACE types. This patch makes the Linux client work with
> >>> ACLs if the server supports either ALLOW or DENY ACE types.
> >> 
> >> According to RFC5661, the behaviour if you don’t have ALLOW aces is to deny all access. How does it make sense to accept that?
> > 
> > I have a server that only returned 'ALLOW' type support probably due to
> > a bug!  There is nothing in the spec that said a server 'MUST' support
> > 'ALLOW' and 'DENY' ACE types (RFC5661 does say 'SHOULD' though!). That
> > was my reasoning to fix the client to be more liberal/lenient.
> > 
> > Can a server implicitly construct 'ALLOW' ACEs based on mode and not
> > support explicitly setting such ACEs by a client? I am not too familiar
> > with ACLs, if you think we should only check for 'ALLOW' support flag, I
> > can re-spin the patch but I think it is better to be more lenient
> > specially if it is not incorrect by being more lenient!
> 
> The way I read the spec, the default behaviour is to disallow access unless you have sufficient ALLOW aces for the behaviour that you want. The DENY aces are optional, and are there in order to explicitly deny a user or group a particular behaviour that they would otherwise be allowed due to some subsequent combination of ALLOW aces.
> 
> So, I accept that a server could function while only supporting ALLOW aces, but I don’t see how it could work at all with only DENY ace support.

Fair enough!


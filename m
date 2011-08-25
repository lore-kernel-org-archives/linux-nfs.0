Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy02.merit.edu ([207.75.116.194]:44044 "EHLO
	merit-proxy02.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755691Ab1HYWc5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Aug 2011 18:32:57 -0400
Date: Thu, 25 Aug 2011 18:32:53 -0400
From: Jim Rees <rees@umich.edu>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Steve Dickson <SteveD@redhat.com>, Luk Claes <luk@debian.org>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] mount.nfs: Preserve any explicit port=2049 option
Message-ID: <20110825223253.GA7607@merit.edu>
References: <1312625496-2496-1-git-send-email-luk@debian.org>
 <4E56AFCB.2020803@RedHat.com>
 <F4AA6B6E-D029-47BC-A710-23A7AE2582A8@oracle.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <F4AA6B6E-D029-47BC-A710-23A7AE2582A8@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Chuck Lever wrote:

  But we should be careful here: mount.nfs will do an rpcbind query if a
  port= was specified if there is also some doubt about whether to use TCP
  or UDP, or what NFS version is available.  The only time rpcbind queries
  should be completely squashed is when the mount parameters are specified
  completely (transport, version, and port).

Was support for SRV records ever added to either rpcbind or nfs-utils?
Wouldn't that eliminate the need for portmap at least in some cases?  I
remember Andy working on a draft for this ages ago.

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from opensource.wolfsonmicro.com ([80.75.67.52]:49710 "EHLO
	opensource2.wolfsonmicro.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752614Ab1CJQHW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Mar 2011 11:07:22 -0500
Date: Thu, 10 Mar 2011 16:07:20 +0000
From: Mark Brown <broonie@opensource.wolfsonmicro.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        patches@opensource.wolfsonmicro.com
Subject: Re: [PATCH] NFS: Fix handling of commmand line options for NFSROOT
Message-ID: <20110310160720.GC27206@opensource.wolfsonmicro.com>
References: <1299771798-29285-1-git-send-email-broonie@opensource.wolfsonmicro.com>
 <382578FF-22A9-4840-B3A7-EFEFA5453C35@oracle.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <382578FF-22A9-4840-B3A7-EFEFA5453C35@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Mar 10, 2011 at 10:59:24AM -0500, Chuck Lever wrote:
> On Mar 10, 2011, at 10:43 AM, Mark Brown wrote:

> > Commmit 972903 (NFS: NFSROOT should default to "proto=udp") added a
> > default NFS mount option using the existing in-kernel code to parse
> > mount options out of the command line. This exposed a bug in the

> Looks like a real bug.

Well, it's stopped me booting any of my systems with -next for a couple
of days :)

> We might be better off teaching root_nfs_cat() to deal with the extra
> comma as necessary right when we concatenate the options strings.
> That would simplify it's callers.

The thought did cross my mind, yes.

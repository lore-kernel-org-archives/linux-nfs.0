Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:48481 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753809Ab3A3UUS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Jan 2013 15:20:18 -0500
Date: Wed, 30 Jan 2013 15:20:17 -0500
To: "dE ." <de.techno@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Cannot see contents of files over NFS share.
Message-ID: <20130130202017.GD14256@fieldses.org>
References: <5109732C.9080306@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5109732C.9080306@gmail.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 31, 2013 at 12:53:24AM +0530, dE . wrote:
> I've shares with the following options in export --
> 
> anonuid=1000,anongid=1000,secure,no_subtree_check,ro,fsid=0,crossmnt
> 
> (Actually it doesn't matter. If I remove all the options except fsid
> (which's required for nfs4),

Actually if you're using a recent distro we recommend not using fsid=0.
Just export as you normally would for v2/v3, and v4 will work too.

--b.

> it still doesn't work.)
> 
> I mount the shares with no options and over localhost.
> 
> ls works ok, so does cding to various directories and checking it's
> contents, but that's about it.
> 
> No program can read the contents of any file; all of them hang, but
> can be stopped by an interrupt signal.
> 
> --debug --syslog with rpc.nfsd gives nothing at all, just generic
> startup messages.
> 
> On the same machine, I can mount shares from other NFSv4 servers.

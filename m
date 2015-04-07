Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:56010 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752871AbbDGVkb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Apr 2015 17:40:31 -0400
Date: Tue, 7 Apr 2015 17:40:29 -0400
To: Benjamin ESTRABAUD <be@mpstor.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: pNFS setup documentation.
Message-ID: <20150407214029.GE3363@fieldses.org>
References: <5523C695.3060805@mpstor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5523C695.3060805@mpstor.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 07, 2015 at 12:59:17PM +0100, Benjamin ESTRABAUD wrote:
> I'm trying to setup a pNFS cluster, but I'm unable to find any
> meaningful documentation about it.
> 
> I understand I have to setup a bunch of NFSv4.1 enabled systems as
> well as a Metadata service and a "layout agent" on the client nodes
> but I'm not able to find any infos about setting up the Metadata
> service or even the layout agent, nor am I able to find information
> about what version of the nfsutils I should use.
> 
> Is there a nice documentation that I could use somewhere (Any
> distribution is fine, I can adapt).
> 
> Thanks a lot in advance!

The only all-linux pNFS implementations have been out-of-tree
prototypes.  The exception is Christoph's block server, just merged.

I put some very rough instructions (and warnings) here:

	http://wiki.linux-nfs.org/wiki/index.php/PNFS_block_server_setup

--b.

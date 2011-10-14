Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-out3.tiscali.nl ([195.241.79.178]:60989 "EHLO
	smtp-out3.tiscali.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932407Ab1JNVwS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Oct 2011 17:52:18 -0400
Subject: Re: Problems with Kconfig select across directories
From: Paul Bolle <pebolle@tiscali.nl>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Michal Marek <mmarek@suse.cz>, Randy Dunlap <randy.dunlap@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        NFS list <linux-nfs@vger.kernel.org>
In-Reply-To: <4E9848C1.8040306@panasas.com>
References: <4E9848C1.8040306@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 14 Oct 2011 23:34:29 +0200
Message-ID: <1318628069.6132.125.camel@x61.thuisdomein>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2011-10-14 at 16:35 +0200, Boaz Harrosh wrote:
> This does not work. The ORE is not compiled and MODPOST complains.
> (Given EXOFS_FS is not selected since then it will work)
> 
> What am I doing wrong? Why can't I "select" in fs/nfs/Kconfig
> an option in fs/exofs/Kconfig? What can I do different?

We're not given much to go by here. So I'll just mention the first thing
that I could think of: are you sure all NFS_FS's dependencies are met
(like NETWORK_FILESYSTEMS)?


Paul Bolle


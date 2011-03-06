Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9686 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751029Ab1CFGL3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 6 Mar 2011 01:11:29 -0500
Date: Sun, 06 Mar 2011 15:11:23 +0900 (JST)
Message-Id: <20110306.151123.1031846434411534102.yamato@redhat.com>
To: rees@umich.edu
Cc: SteveD@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] Read /etc/exports.d/*.export as extra export files
From: Masatake YAMATO <yamato@redhat.com>
In-Reply-To: <20110306015106.GA23388@merit.edu>
References: <20110217.215900.388120588347145930.yamato@redhat.com>
	<4D72BD33.70208@RedHat.com>
	<20110306015106.GA23388@merit.edu>
Content-Type: Text/Plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, 5 Mar 2011 20:51:06 -0500, Jim Rees <rees@umich.edu> wrote
> Steve Dickson wrote:
> 
>   Now, I realize you added the ".export" explanation to the man page 
>   but is there a particular reason why file in that directory have 
>   to end with ".export"? Out of "easy of use" sake, should any 
>   and all files that exist in that directory be expected to 
>   be exports files?
> 
> I don't know if that's the best way to do it, but I think it would be useful
> to have a way to keep files in the directory that don't get automatically
> read.  As an analogy, I have the following files in my /etc/init:
> 
> portmap.conf           This is the real one that gets used
> portmap.conf~          This is a backup file produced by emacs
> portmap.conf-20100603  This is the file that came with my distro
> 
> Only the first one gets used, which is what I want, because it's the only
> one ending in ".conf".

Jim, thank you for explanation. He wrote what I'd like to write.

This technique is borrowed from util-linux-ng; libmount.so reads
only *.fstab under /etc/fstab.d.


In addition, ".export" suffix tells an editor which syntax highlighter
should be used when editing .export file:P

Masatake YAMATO

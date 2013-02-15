Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:58742 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756339Ab3BOSSf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 Feb 2013 13:18:35 -0500
Date: Fri, 15 Feb 2013 13:18:33 -0500
To: Sven Geggus <lists@fuchsschwanzdomain.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS4: "Value too large for defined data type" problem
Message-ID: <20130215181833.GA19923@fieldses.org>
References: <kfkvll$adm$1@ultimate100.geggus.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <kfkvll$adm$1@ultimate100.geggus.net>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 15, 2013 at 09:37:57AM +0000, Sven Geggus wrote:
> Hello,
> 
> is there something which can be done server-side to work around the "Value
> too large for defined data type" problem with huge inode Numbers?
> 
> First of all, I'm not shure if this is an NFS problem or one of the
> underlying filesystem.
> 
> Background:
> I set up a new NFS-server (NFS4) recently. The server works fine so far with
> 64 bit Linux clients.
> 
> It also mostly works with 32 bit Linux clients when either the stat system
> call is not used or "-D_FILE_OFFSET_BITS=64" has been used.
> 
> This is because on 32 bit Linux ino_t is not 64-bit otherwise.
> 
> Unfortunately at least the 32bit Version of Debian stable (6.0) seems to
> break all over the place. E.g. in gnome when stat ~/.gnome2_private/ fails
> it is assumed that the directory has to be created which will of course make
> the subsequent call to mkdir also fail and break the whole desktop
> environment afterwords.

What filesystem are you exporting?

For xfs, as an example, see the discussion of 64-bit inode numbers in
the mkfs.xfs man page.

--b.

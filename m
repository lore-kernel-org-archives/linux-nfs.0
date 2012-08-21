Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46818 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753240Ab2HUU7q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Aug 2012 16:59:46 -0400
Date: Tue, 21 Aug 2012 16:59:41 -0400
To: Jim Rees <rees@umich.edu>
Cc: Sven Geggus <lists@fuchsschwanzdomain.de>, linux-nfs@vger.kernel.org
Subject: Re: NFS4: ssh + unlink(~/.Xauthority) delays
Message-ID: <20120821205941.GA18637@fieldses.org>
References: <k0vgkt$mm0$1@ultimate100.geggus.net>
 <20120821125905.GA16550@umich.edu>
 <k10bib$1fi$1@ultimate100.geggus.net>
 <20120821170759.GA13076@umich.edu>
 <20120821180353.GB4561@us.ibm.com>
 <20120821184230.GA13357@umich.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120821184230.GA13357@umich.edu>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 21, 2012 at 02:42:30PM -0400, Jim Rees wrote:
> Malahal Naineni wrote:
> 
>   NFS3 doesn't have delegations and this file placement should not be an
>   issue in NFSv4 either if it is working correctly!
> 
> Xauthority doesn't belong in $HOME, it belongs on the local disk.  That has
> nothing to do with NFS v3/v4.  It has to do with limiting distribution and
> exposure of sensitive information.

Yah.  Unlinking a file shouldn't take a minute, though, so we do have a
bug, however it was found.  Let me know if the patch I referred to fixes
it.

--b.

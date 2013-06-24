Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:56161 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750830Ab3FXVyK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Jun 2013 17:54:10 -0400
Date: Mon, 24 Jun 2013 17:54:08 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Sven Geggus <lists@fuchsschwanzdomain.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Kerberized NFS-Server Problem still present in 3.10.0-rc2
Message-ID: <20130624215408.GD23596@fieldses.org>
References: <kpscp8$fo3$1@ultimate100.geggus.net>
 <20130619213412.GA2547@fieldses.org>
 <20130620080354.GA5591@geggus.net>
 <20130620144955.GB11728@fieldses.org>
 <20130620145209.GC11728@fieldses.org>
 <20130621083221.GA4103@geggus.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130621083221.GA4103@geggus.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 21, 2013 at 10:32:22AM +0200, Sven Geggus wrote:
> J. Bruce Fields schrieb am Donnerstag, den 20. Juni um 16:52 Uhr:
> 
> > What happens with NFSv3?
> 
> I have no Idea. I have a NFS4-only Server Setup and would need to enable v3
> explicitly.
> 
> > So it looks it did a null init_sec_context establishment and then the
> > server didn't reply to the first rpc call using the new context.  But
> > it's hard to be sure without more details--could I get the binary dump?
> 
> Attached (Server kernel was 3.10.0-rc2 with patch below).

OK, yes, thanks, the init_sec_context exchange does look acceptable but
the server never responds to the first real rpc (a SETCLIENTID) using
the new context.

Could you run

	strace -p $(pidof rpc.svcgssd) -s4096 -e trace=open,close,read,write

on the server while trying this?  That should capture the contents of
the relevant upcalls.  I wonder if there's something odd about the
context svcgssd is passing down.

> > Hm, or I wonder if 8b5309d41751b8a086d8e7a43abe37d9ff24559d "svcrpc: fix
> > failures to handle -1 uid's and gid's" (appended) would help.
> 
> No! I just patched this into a vanilla 3.10.0-rc2. Same Problem. The NFS-mount
> just hangs.

OK, thanks for checking.

--b.

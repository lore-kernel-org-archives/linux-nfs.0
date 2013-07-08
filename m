Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:59274 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751735Ab3GHNfo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Jul 2013 09:35:44 -0400
Date: Mon, 8 Jul 2013 09:35:37 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Sven Geggus <lists@fuchsschwanzdomain.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Kerberized NFS-Server Problem still present in 3.10.0-rc2
Message-ID: <20130708133537.GA29071@fieldses.org>
References: <20130620144955.GB11728@fieldses.org>
 <20130620145209.GC11728@fieldses.org>
 <20130621083221.GA4103@geggus.net>
 <20130624215408.GD23596@fieldses.org>
 <20130625094612.GA2186@geggus.net>
 <20130701205234.GF19945@fieldses.org>
 <20130702080530.GA17953@geggus.net>
 <20130705181859.GA8288@fieldses.org>
 <20130705203435.GE8288@fieldses.org>
 <20130708080803.GB29990@geggus.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130708080803.GB29990@geggus.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 08, 2013 at 10:08:05AM +0200, Sven Geggus wrote:
> Monday Monday, so good to me :)
> 
> On Friday, 5. Jul 2013 22:34, J. Bruce Fields wrote:
> 
> > Hm, might be interesting to see what mountd's doing too:
> > 
> > 	strace -p $(pidof rpc.svcgssd) -s4096 -e trace=open,close,read,write

Argh--I said "mountd", then I forgot to replace the rpc.svcgssd in the
cut-n-pasted commandline; should have been:

	strace -p $(pidof rpc.mountd) -s4096 -e trace=open,close,read,write

> 
> OK, output attached. While reading this output I recogniced, that I
> overlooked the following error-messages from rpc.svcgssd and rpc.mountd:
> 
> Jul  8 09:53:38 vnfsrv rpc.svcgssd[2914]: ERROR: GSS-API: error in gss_free_lucid_sec_context(): GSS_S_NO_CONTEXT (No context has been established) - Unknown error
> Jul  8 09:53:38 vnfsrv rpc.svcgssd[2914]: WARN: failed to free lucid sec context
> Jul  8 09:53:38 vnfsrv rpc.mountd[2927]: qword_eol: fprintf failed: errno 22 (Invalid argument)
> 
> > Hm, maybe this gid upcall?  Does the following (probably not completely
> > right) help?
> 
> Yes, we are getting there. While the strange messages from rpc.svcgssd
> persist, the mount now seems to work again after your patch has been
> applied.

Anyway.  OK, that more or less solves the mystery, though the strace
output might still be interesting.

--b.

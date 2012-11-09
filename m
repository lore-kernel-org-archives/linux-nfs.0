Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44196 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754409Ab2KIXYO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Nov 2012 18:24:14 -0500
Date: Fri, 9 Nov 2012 18:24:10 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Sven Geggus <lists@fuchsschwanzdomain.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Kernel update 3.5.7 -> 3.6.3 breaks NFS4
Message-ID: <20121109232410.GK6171@fieldses.org>
References: <20121109200730.GI6171@fieldses.org>
 <E1TWxKX-00025I-J2@diesel.geggus.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <E1TWxKX-00025I-J2@diesel.geggus.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 09, 2012 at 11:45:41PM +0100, Sven Geggus wrote:
> In article <20121109200730.GI6171@fieldses.org> you wrote:
> 
> > Is it possible that your system has very large uid's?  (Large enough
> > that they'd look like negative numbers when cast to ints?)
> 
> Shurely not. however, mounting is done as root which might get mapped to
> nobody which usually is 65534.
> 
> > Output from
> > 
> >        strace -p $(pidof rpc.mountd) -s4096 -e trace=open,close,read,write
> > 
> > (while reproducing the bug) might help confirm that.
> 
> While doing the hanging or while doing the proper mount?

Restart the server, start strace, then try the mount, let it hang a few
seconds just to make sure you got anything interesting, then kill strace
and send the output.

I guess the results in the succesful (good kernel) case might be
interesting too, but probably the bad case is enough.

--b.

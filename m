From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: nfs oops in 2.6.32-rc5-00041-g1d91624
Date: Tue, 20 Oct 2009 11:29:58 +0900
Message-ID: <1256005799.10198.2.camel@heimdal.trondhjem.org>
References: <200910191803.26845.egon.alter@gmx.net>
	 <200910200151.55016.elendil@planet.nl>
	 <1255997511.2892.8.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Egon Alter <egon.alter@gmx.net>, linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org
To: Frans Pop <elendil-EIBgga6/0yRmR6Xm/wNWPw@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:38833 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932438AbZJTC37 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Oct 2009 22:29:59 -0400
In-Reply-To: <1255997511.2892.8.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-10-20 at 09:11 +0900, Trond Myklebust wrote:

> Hmm...It looks as though the credential doesn't have a crvalidate
> method. I'll see if I can track this down...

BTW: What security flavour are you using (please see
'cat /proc/self/mountinfo' on the client and /etc/exports on the
server).

Cheers
  Trond


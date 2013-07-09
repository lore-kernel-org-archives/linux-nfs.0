Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57821 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751905Ab3GIQ52 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Jul 2013 12:57:28 -0400
Date: Tue, 9 Jul 2013 12:57:26 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Sven Geggus <lists@fuchsschwanzdomain.de>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>,
        NeilBrown <neilb@suse.de>
Subject: Re: Kerberized NFS-Server Problem still present in 3.10.0-rc2
Message-ID: <20130709165726.GD8281@fieldses.org>
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
> OK, output attached. While reading this output I recogniced, that I
> overlooked the following error-messages from rpc.svcgssd and rpc.mountd:

I don't think they're causing you any practical problem, but there was
some discussion of how to destroy contexts in gssd recently that I
didn't follow closely enough.  I seem to recall Neil and Chuck being the
ones chasing down those bugs?

> Jul  8 09:53:38 vnfsrv rpc.svcgssd[2914]: ERROR: GSS-API: error in gss_free_lucid_sec_context(): GSS_S_NO_CONTEXT (No context has been established) - Unknown error
> Jul  8 09:53:38 vnfsrv rpc.svcgssd[2914]: WARN: failed to free lucid sec context

Does rpc.svcgssd still need fixing?  (Sven, could you remind us what
nfs-utils version this is from?)

--b.

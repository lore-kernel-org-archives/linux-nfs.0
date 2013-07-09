Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:50402 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752542Ab3GIRYF convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Jul 2013 13:24:05 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.5 \(1508\))
Subject: Re: Kerberized NFS-Server Problem still present in 3.10.0-rc2
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20130709165726.GD8281@fieldses.org>
Date: Tue, 9 Jul 2013 13:23:43 -0400
Cc: Sven Geggus <lists@fuchsschwanzdomain.de>, linux-nfs@vger.kernel.org,
        NeilBrown <neilb@suse.de>
Message-Id: <2AF2EB21-48F6-4D86-8F33-C294E154A675@oracle.com>
References: <20130620144955.GB11728@fieldses.org> <20130620145209.GC11728@fieldses.org> <20130621083221.GA4103@geggus.net> <20130624215408.GD23596@fieldses.org> <20130625094612.GA2186@geggus.net> <20130701205234.GF19945@fieldses.org> <20130702080530.GA17953@geggus.net> <20130705181859.GA8288@fieldses.org> <20130705203435.GE8288@fieldses.org> <20130708080803.GB29990@geggus.net> <20130709165726.GD8281@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jul 9, 2013, at 12:57 PM, "J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Mon, Jul 08, 2013 at 10:08:05AM +0200, Sven Geggus wrote:
>> OK, output attached. While reading this output I recogniced, that I
>> overlooked the following error-messages from rpc.svcgssd and rpc.mountd:
> 
> I don't think they're causing you any practical problem, but there was
> some discussion of how to destroy contexts in gssd recently that I
> didn't follow closely enough.  I seem to recall Neil and Chuck being the
> ones chasing down those bugs?

I haven't touched rpc.svcgssd.  I thought this code was being replaced by the gss_proxy-based implementation.

>> Jul  8 09:53:38 vnfsrv rpc.svcgssd[2914]: ERROR: GSS-API: error in gss_free_lucid_sec_context(): GSS_S_NO_CONTEXT (No context has been established) - Unknown error
>> Jul  8 09:53:38 vnfsrv rpc.svcgssd[2914]: WARN: failed to free lucid sec context
> 
> Does rpc.svcgssd still need fixing?  (Sven, could you remind us what
> nfs-utils version this is from?)
> 
> --b.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com





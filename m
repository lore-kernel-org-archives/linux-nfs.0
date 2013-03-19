Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46810 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753780Ab3CSPQf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Mar 2013 11:16:35 -0400
Date: Tue, 19 Mar 2013 11:16:34 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 10/11] NFSv4.1: Enable open-by-filehandle
Message-ID: <20130319151634.GF7912@fieldses.org>
References: <1363698463-3681-6-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-7-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-8-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-9-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-10-git-send-email-Trond.Myklebust@netapp.com>
 <20130319140901.GB7912@fieldses.org>
 <1363702570.7515.6.camel@leira.trondhjem.org>
 <20130319143236.GD7912@fieldses.org>
 <1363704100.7515.12.camel@leira.trondhjem.org>
 <1363704300.7515.16.camel@leira.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1363704300.7515.16.camel@leira.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 19, 2013 at 02:45:00PM +0000, Myklebust, Trond wrote:
> On Tue, 2013-03-19 at 10:41 -0400, Trond Myklebust wrote:
> > On Tue, 2013-03-19 at 10:32 -0400, J. Bruce Fields wrote:
> > > (Sorry for the digression, I was just trying to decide whether I can get
> > > away with turning on 4.1 by default before implementing SP4_MACH_CRED or
> > > GSS on the backchannel....)
> > 
> > If you don't, could you please at least offer up a module parameter that
> > allows me to do that? The current thing is a PITA, since it isn't
> > supported by any distro scripts, and it requires you to switch off the
> > server in order to change the version pseudofile contents.
> > 
> BTW: you may recall that SPKM3 and UTF-8 support was mandatory in
> RFC3530,

Yes.

> as was RPCSEC_GSS support on the back channel.

I don't agree there--maybe the spec says it's mandatory, I don't
remember, but in practice 4.0 degrades gracefully without callbacks.  In
the 4.1 case the create_session's just going to fail with an unspecified
error.

> That didn't stop anybody from shipping clients and servers that didn't
> support them...

Yeah, I may just resign myself to erroring out in some more cases.

--b.

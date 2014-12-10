Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f45.google.com ([209.85.216.45]:50576 "EHLO
	mail-qa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756563AbaLJOeI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Dec 2014 09:34:08 -0500
Received: by mail-qa0-f45.google.com with SMTP id x12so2025069qac.4
        for <linux-nfs@vger.kernel.org>; Wed, 10 Dec 2014 06:34:07 -0800 (PST)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Wed, 10 Dec 2014 09:34:05 -0500
To: David =?UTF-8?B?SMOkcmRlbWFu?= <david@hardeman.nu>
Cc: Jeff Layton <jeff.layton@primarydata.com>, linux-nfs@vger.kernel.org,
        SteveD@redhat.com, dhowells@redhat.com
Subject: Re: [PATCH 00/19] gssd improvements
Message-ID: <20141210093405.23ffc328@tlielax.poochiereds.net>
In-Reply-To: <cdaf61315d77361a379e3eb1d4eaac1e@hardeman.nu>
References: <20141209053828.24756.89941.stgit@zeus.muc.hardeman.nu>
	<20141209080923.2708eb4f@tlielax.poochiereds.net>
	<4639bc17bcb236c23cfaf2bc57d98b67@hardeman.nu>
	<20141209095813.163ac2bb@tlielax.poochiereds.net>
	<20141209195530.GA27798@hardeman.nu>
	<20141210065240.77a23160@tlielax.poochiereds.net>
	<33fa16f69b18ed67e3fd595b95497941@hardeman.nu>
	<20141210091734.3c612514@tlielax.poochiereds.net>
	<cdaf61315d77361a379e3eb1d4eaac1e@hardeman.nu>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 10 Dec 2014 15:31:34 +0100
David Härdeman <david@hardeman.nu> wrote:

> On 2014-12-10 15:17, Jeff Layton wrote:
> > On Wed, 10 Dec 2014 15:08:40 +0100
> > David Härdeman <david@hardeman.nu> wrote:
> >> I'm not sure I follow completely...first of all, rpc.gssd is also not
> >> namespace-aware, is it? I mean, sure, it could be run in a given
> >> namespace, but there can still only be one rpc.gssd running?
> >> 
> > 
> > gssd isn't namespace aware, but it doesn't have to be since it gets
> > started in userland. In principle you could run a gssd per 
> > container[1].
> > As long as each container has its own net namespace, each gssd would
> > have its own set of rpc_pipefs pipes.
> > 
> > request-key is different. The kernel spawns a thread that execs the
> > program, but there's no support in that infrastructure for doing so
> > within a particular container.
> 
> This thread might be interesting:
> https://lkml.org/lkml/2014/11/24/885
> 

Nice. I wasn't aware that Ian was working on this. I'll take a look.

> >> Also...the nfsidmap binary (the request-key helper) isn't
> >> namespace-aware...is it?
> >> 
> > 
> > No it's not. I'd consider that a bug as well.
> 
> So basically, a request-key based gssd would be possible if that "bug" 
> in the request-key infrastructure is fixed, right?
> 

Yes, I don't see why not.

-- 
Jeff Layton <jlayton@primarydata.com>

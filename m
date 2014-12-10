Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f171.google.com ([209.85.216.171]:36519 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932623AbaLJTDP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Dec 2014 14:03:15 -0500
Received: by mail-qc0-f171.google.com with SMTP id r5so2658596qcx.16
        for <linux-nfs@vger.kernel.org>; Wed, 10 Dec 2014 11:03:14 -0800 (PST)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Wed, 10 Dec 2014 14:03:11 -0500
To: David Howells <dhowells@redhat.com>
Cc: Jeff Layton <jeff.layton@primarydata.com>, ikent@redhat.com,
        bcodding@redhat.com,
        David =?UTF-8?B?SMOkcmRlbWFu?= <david@hardeman.nu>,
        linux-nfs@vger.kernel.org, SteveD@redhat.com
Subject: Re: [PATCH 00/19] gssd improvements
Message-ID: <20141210140311.7fb7b159@tlielax.poochiereds.net>
In-Reply-To: <32108.1418227382@warthog.procyon.org.uk>
References: <20141210093405.23ffc328@tlielax.poochiereds.net>
	<20141209053828.24756.89941.stgit@zeus.muc.hardeman.nu>
	<20141209080923.2708eb4f@tlielax.poochiereds.net>
	<4639bc17bcb236c23cfaf2bc57d98b67@hardeman.nu>
	<20141209095813.163ac2bb@tlielax.poochiereds.net>
	<20141209195530.GA27798@hardeman.nu>
	<20141210065240.77a23160@tlielax.poochiereds.net>
	<33fa16f69b18ed67e3fd595b95497941@hardeman.nu>
	<20141210091734.3c612514@tlielax.poochiereds.net>
	<cdaf61315d77361a379e3eb1d4eaac1e@hardeman.nu>
	<32108.1418227382@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 10 Dec 2014 16:03:02 +0000
David Howells <dhowells@redhat.com> wrote:

> Jeff Layton <jeff.layton@primarydata.com> wrote:
> 
> > > This thread might be interesting:
> > > https://lkml.org/lkml/2014/11/24/885
> > > 
> > 
> > Nice. I wasn't aware that Ian was working on this. I'll take a look.
> 
> I'm not sure what the current state of this is.  There was some discussion
> over how best to determine which container we need to run in - and it's
> complicated by the fact that the mounter may run in a different container to
> the program that triggered the mount due to mountpoint propagation.
> 

Yes. It's quite a thorny problem.

Part of the issue is that the different namespaces (net, mount, etc...)
are completely orthogonal to one another as far as the kernel is
concerned, but they really can't be when we start talking about
userland stuff.

For example, all of the nfs and nfsd namespace code was tied to the net
namespace. But, once you start involving things like gssd, the mount
namespace matters too as it has to deal with files (libraries and
config files, in particular).

Q: What happens if you have two "containers" that have the same net
namespace but different mount namespaces along with a different krb5
configuration in each? Maybe even with a gssd running in each?

A: A horrible mess, AFAICT...

Without something that really enforces a 1:1 relationship between all
of the different sorts of namespaces, the whole container/namespace
concept quickly descends into a horrid mess. It makes my head hurt.

-- 
Jeff Layton <jlayton@primarydata.com>

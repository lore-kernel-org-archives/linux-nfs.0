Return-Path: linux-nfs-owner@vger.kernel.org
Received: from vader.hardeman.nu ([95.142.160.32]:52084 "EHLO hardeman.nu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758053AbaLJU4B (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Dec 2014 15:56:01 -0500
Date: Wed, 10 Dec 2014 21:55:52 +0100
From: David =?iso-8859-1?Q?H=E4rdeman?= <david@hardeman.nu>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: David Howells <dhowells@redhat.com>, ikent@redhat.com, bcodding@redhat.com,
        linux-nfs@vger.kernel.org, SteveD@redhat.com
Subject: Re: [PATCH 00/19] gssd improvements
Message-ID: <20141210205552.GB11396@hardeman.nu>
References: <20141209080923.2708eb4f@tlielax.poochiereds.net>
 <4639bc17bcb236c23cfaf2bc57d98b67@hardeman.nu>
 <20141209095813.163ac2bb@tlielax.poochiereds.net>
 <20141209195530.GA27798@hardeman.nu>
 <20141210065240.77a23160@tlielax.poochiereds.net>
 <33fa16f69b18ed67e3fd595b95497941@hardeman.nu>
 <20141210091734.3c612514@tlielax.poochiereds.net>
 <cdaf61315d77361a379e3eb1d4eaac1e@hardeman.nu>
 <32108.1418227382@warthog.procyon.org.uk>
 <20141210140311.7fb7b159@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <20141210140311.7fb7b159@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 10, 2014 at 02:03:11PM -0500, Jeff Layton wrote:
>On Wed, 10 Dec 2014 16:03:02 +0000
>David Howells <dhowells@redhat.com> wrote:
>> Jeff Layton <jeff.layton@primarydata.com> wrote:
>> > > This thread might be interesting:
>> > > https://lkml.org/lkml/2014/11/24/885
>> > > 
>> > 
>> > Nice. I wasn't aware that Ian was working on this. I'll take a look.
>> 
>> I'm not sure what the current state of this is.  There was some discussion
>> over how best to determine which container we need to run in - and it's
>> complicated by the fact that the mounter may run in a different container to
>> the program that triggered the mount due to mountpoint propagation.
>> 
>
>Yes. It's quite a thorny problem.
>
>Part of the issue is that the different namespaces (net, mount, etc...)
>are completely orthogonal to one another as far as the kernel is
>concerned, but they really can't be when we start talking about
>userland stuff.
>
>For example, all of the nfs and nfsd namespace code was tied to the net
>namespace. But, once you start involving things like gssd, the mount
>namespace matters too as it has to deal with files (libraries and
>config files, in particular).
>
>Q: What happens if you have two "containers" that have the same net
>namespace but different mount namespaces along with a different krb5
>configuration in each? Maybe even with a gssd running in each?
>
>A: A horrible mess, AFAICT...
>
>Without something that really enforces a 1:1 relationship between all
>of the different sorts of namespaces, the whole container/namespace
>concept quickly descends into a horrid mess. It makes my head hurt.

And crossing namespaces could theoretically be a feature as well
(meaning the 1:1 relationship isn't necessarily wanted)? Imagine
generating krb5 tickets in one container that are used in another
container...(though I might be completely mistaken here)?

Anyway....as far as I can tell...rpc.idmapd, nfsidmap and rpc.gssd all
lack namespace awareness...right? And in particular nfsidmap since it
runs in the root namespace (and the other tools run in whichever
namespace they're launched in, which may or may not be the right one)...

But...maybe that particular problem is not a good reason to hold up e.g.
experimentation with a request-key based gssd util (one that would work
for the "normal" case with no containers and namespaces....)?

-- 
David Härdeman

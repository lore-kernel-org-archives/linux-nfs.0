Return-Path: linux-nfs-owner@vger.kernel.org
Received: from vader.hardeman.nu ([95.142.160.32]:51886 "EHLO hardeman.nu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756341AbaLJObi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Dec 2014 09:31:38 -0500
To: Jeff Layton <jeff.layton@primarydata.com>
Subject: Re: [PATCH 00/19] gssd improvements
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Date: Wed, 10 Dec 2014 15:31:34 +0100
From: =?UTF-8?Q?David_H=C3=A4rdeman?= <david@hardeman.nu>
Cc: linux-nfs@vger.kernel.org, SteveD@redhat.com, dhowells@redhat.com
In-Reply-To: <20141210091734.3c612514@tlielax.poochiereds.net>
References: <20141209053828.24756.89941.stgit@zeus.muc.hardeman.nu>
 <20141209080923.2708eb4f@tlielax.poochiereds.net>
 <4639bc17bcb236c23cfaf2bc57d98b67@hardeman.nu>
 <20141209095813.163ac2bb@tlielax.poochiereds.net>
 <20141209195530.GA27798@hardeman.nu>
 <20141210065240.77a23160@tlielax.poochiereds.net>
 <33fa16f69b18ed67e3fd595b95497941@hardeman.nu>
 <20141210091734.3c612514@tlielax.poochiereds.net>
Message-ID: <cdaf61315d77361a379e3eb1d4eaac1e@hardeman.nu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2014-12-10 15:17, Jeff Layton wrote:
> On Wed, 10 Dec 2014 15:08:40 +0100
> David Härdeman <david@hardeman.nu> wrote:
>> I'm not sure I follow completely...first of all, rpc.gssd is also not
>> namespace-aware, is it? I mean, sure, it could be run in a given
>> namespace, but there can still only be one rpc.gssd running?
>> 
> 
> gssd isn't namespace aware, but it doesn't have to be since it gets
> started in userland. In principle you could run a gssd per 
> container[1].
> As long as each container has its own net namespace, each gssd would
> have its own set of rpc_pipefs pipes.
> 
> request-key is different. The kernel spawns a thread that execs the
> program, but there's no support in that infrastructure for doing so
> within a particular container.

This thread might be interesting:
https://lkml.org/lkml/2014/11/24/885

>> Also...the nfsidmap binary (the request-key helper) isn't
>> namespace-aware...is it?
>> 
> 
> No it's not. I'd consider that a bug as well.

So basically, a request-key based gssd would be possible if that "bug" 
in the request-key infrastructure is fixed, right?


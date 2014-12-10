Return-Path: linux-nfs-owner@vger.kernel.org
Received: from vader.hardeman.nu ([95.142.160.32]:51769 "EHLO hardeman.nu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756007AbaLJOIn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Dec 2014 09:08:43 -0500
To: Jeff Layton <jeff.layton@primarydata.com>
Subject: Re: [PATCH 00/19] gssd improvements
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Date: Wed, 10 Dec 2014 15:08:40 +0100
From: =?UTF-8?Q?David_H=C3=A4rdeman?= <david@hardeman.nu>
Cc: linux-nfs@vger.kernel.org, SteveD@redhat.com, dhowells@redhat.com
In-Reply-To: <20141210065240.77a23160@tlielax.poochiereds.net>
References: <20141209053828.24756.89941.stgit@zeus.muc.hardeman.nu>
 <20141209080923.2708eb4f@tlielax.poochiereds.net>
 <4639bc17bcb236c23cfaf2bc57d98b67@hardeman.nu>
 <20141209095813.163ac2bb@tlielax.poochiereds.net>
 <20141209195530.GA27798@hardeman.nu>
 <20141210065240.77a23160@tlielax.poochiereds.net>
Message-ID: <33fa16f69b18ed67e3fd595b95497941@hardeman.nu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2014-12-10 12:52, Jeff Layton wrote:
> On Tue, 9 Dec 2014 20:55:30 +0100
> David Härdeman <david@hardeman.nu> wrote:
>> Another question that comes to mind...if we're anyway forking a child
>> per gssd request...how far has the idea of changing rpc.gssd over to a
>> /sbin/request-key helper been considered? I've seen some traces of
>> historical discussions via google but nothing concrete so far...
>> 
> 
> (cc'ing David in case I'm wrong on this point)
> 
> Yes. The problem with keyrings is that while the in-kernel parts are
> namespace-aware, the upcalls are not. /sbin/request-key is spawned by a
> kernel thread that lives in the init namespaces. Any solution that
> involves a usermodehelper upcall will need to figure out how to handle
> containerized clients.
> 
> Another idea might be to scrap rpc.gssd altogether and communicate with
> gssproxy directly (but that too involves running a daemon, of course).

I'm not sure I follow completely...first of all, rpc.gssd is also not 
namespace-aware, is it? I mean, sure, it could be run in a given 
namespace, but there can still only be one rpc.gssd running?

Also...the nfsidmap binary (the request-key helper) isn't 
namespace-aware...is it?

//David


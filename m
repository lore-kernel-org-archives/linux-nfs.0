Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:18085 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1945906AbcHRC67 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Aug 2016 22:58:59 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH 3/8] mountd: remove 'dev_missing' checks
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <87bn0qj1yz.fsf@notabene.neil.brown.name>
Date: Wed, 17 Aug 2016 22:57:47 -0400
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <8F225C0B-345E-483D-8769-6E1C13269689@oracle.com>
References: <20160714021310.5874.22953.stgit@noble> <20160714022643.5874.84409.stgit@noble> <20160718200121.GC12304@fieldses.org> <878twx9ra3.fsf@notabene.neil.brown.name> <20160721172452.GC27148@fieldses.org> <87wpjokofy.fsf@notabene.neil.brown.name> <20160816152148.GC30124@fieldses.org> <87bn0qj1yz.fsf@notabene.neil.brown.name>
To: NeilBrown <neilb@suse.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Aug 17, 2016, at 9:32 PM, NeilBrown <neilb@suse.com> wrote:
> 
> On Wed, Aug 17 2016, J. Bruce Fields wrote:
>>> 
>>> 
>>> There is another issue related to this that I've been meaning to
>>> mention.  It related to the start-up ordering rather than shut down.
>>> 
>>> When you try to mount an NFS filesystem and the server isn't responding,
>>> mount.nfs retries for a little while and then - if "bg" is given - it
>>> forks and retries a bit longer.
>>> While it keeps gets failures that appear temporary, like ECONNREFUSED or
>>> ETIMEDOUT (see nfs_is_permanent_error()) it keeps retrying.
>>> 
>>> There is typically a window between when rpcbind starts responding to
>>> queries, and when nfsd has registered with it.  If mount.nfs sends an
>>> rpcbind query in this window. It gets RPC_PROGNOTREGISTERED which
>>> nfs_rewrite_pmap_mount_options maps to EOPNOTSUPP, and
>>> nfs_is_permanent_error() thinks that is a permanent error.
>> 
>> Looking at rpcbind(8)....  Shouldn't "-w" prevent this by loading some
>> registrations before it starts responding to requests?
> 
> "-w" (which isn't listed in the SYNOPSIS!) only applies to a warm-start
> where the daemons which previously registered are still running.
> The problem case is that the daemons haven't registered yet (so we don't
> necessarily know what port number they will get).
> 
> To address the issue in rpcbind, we would need a flag to say "don't
> respond to lookup requests, just accept registrations", then when all
> registrations are complete, send some message to rpcbind to say "OK,
> respond to lookups now".  That could even be done by killing and
> restarting with "-w", though that it a bit ugly.

An alternative would be to create a temporary firewall rule that
blocked port 111 to remote connections. Once local RPC services
had registered, the rule is removed.

Just a thought.


> I'm leaning towards having mount retry after RPC_PROGNOTREGISTERED for
> fg like it does with bg.

It probably should do that. If rpcbind is up, then the other
services are probably on their way.


--
Chuck Lever




Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.parallels.com ([64.131.90.16]:51267 "EHLO mx2.parallels.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753524Ab1CVNLj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Mar 2011 09:11:39 -0400
Message-ID: <4D889FFD.1010608@parallels.com>
Date: Tue, 22 Mar 2011 08:11:25 -0500
From: Rob Landley <rlandley@parallels.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Lifetime rules question.
Content-Type: text/plain; charset="ISO-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

To make NFS work more reliably in containers, I want to put a struct net
* net in nfs_client, which means I need to do
get_net(current->proxy->net_ns) in mount's process context.  But doing
that for nfs_parsed_mount_data and then again for the temporary
nfs_server object we create so we can sget() to see if we've already got
one and then free it again would be kind of a mess.

What I'd _like_ to do is have nfs_init_server() do the get_net() and
nfs_free_server() do the corresponding put(), and then the lifetime
rules take care of themselves.  But it's not 100% clear those will
always be called from mount's process context in future.

They get passed an nfs_parsed_mount_data object, and what I could do is
copy current->proxy->net_ns into that but hold off on doing the
get_net() on it until nfs_create_server().  But that would be operating
on the theory that the mount process doesn't go away until we're done
with the options data.  (And in fact doesn't return to userspace where
it might do an unshare(2) which could decrement that net_ns's reference
count to zero.)

Does "the nfs_parsed_mount_data object still exists means the mount
process hasn't returned to userspace yet" sound like a good rule?  So I
can copy the struct net * into ther but get_net() it later when I know
I'll be keeping it rather than using a cached copy?

(I'd actually _like_ to push the get_net() down to the actual nfs_client
structure initialization, but that's down through nfs_get_client() which
uses yet another marshalling-data-to-ourselves intermediate structure,
and thus hasn't got nfs_parsed_mount_data...)

Do you have any guidance on what would be good lifetime rules here?  Am
I missing a more obvious place to put this?

Thanks,

Rob

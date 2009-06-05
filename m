From: Jeff Layton <jlayton@redhat.com>
Subject: should we make --enable-tirpc the default in current nfs-utils?
Date: Fri, 5 Jun 2009 07:36:48 -0400
Message-ID: <20090605073648.5a5497b5@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:34226 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750949AbZFELgs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Jun 2009 07:36:48 -0400
Received: from int-mx2.corp.redhat.com (int-mx2.corp.redhat.com [172.16.27.26])
	by mx2.redhat.com (8.13.8/8.13.8) with ESMTP id n55BaogK000474
	for <linux-nfs@vger.kernel.org>; Fri, 5 Jun 2009 07:36:50 -0400
Received: from ns3.rdu.redhat.com (ns3.rdu.redhat.com [10.11.255.199])
	by int-mx2.corp.redhat.com (8.13.1/8.13.1) with ESMTP id n55BanJH018110
	for <linux-nfs@vger.kernel.org>; Fri, 5 Jun 2009 07:36:50 -0400
Received: from tlielax.poochiereds.net (vpn-12-229.rdu.redhat.com [10.11.12.229])
	by ns3.rdu.redhat.com (8.13.8/8.13.8) with ESMTP id n55BanVu016892
	for <linux-nfs@vger.kernel.org>; Fri, 5 Jun 2009 07:36:49 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Eventually, we most distros are going to want to build nfs-utils
against libtirpc in order to get IPv6 support. At some point, we'll
probably want to make building with IPv6 support the default. In the
meantime however, we need to get more testing exposure for the TI-RPC
codepaths. We'll probably start building Fedora's nfs-utils with TI-RPC
support in the near future.

The question that Steve D. has asked is whether we should also make
--enable-tirpc the default for the mainline nfs-utils tree?

Doing this now would add wider testing exposure for these codepaths and
help flush out bugs in TIRPC+IPV4 codepaths. OTOH, it means adding a
new library dependency for packagers, or they'll need to take the
conscious step to --disable-tirpc when they configure.

We could make it so that configure looks for libtirpc and if it's not
available, configures the build against legacy RPC interfaces. I think
this is a bad idea however. While it should "just work" either way,
there are some small behavioral differences when TIRPC support is built
in. I think it's probably better to make enabling and disabling TIRPC a
conscious step.

Thoughts?

-- 
Jeff Layton <jlayton@redhat.com>

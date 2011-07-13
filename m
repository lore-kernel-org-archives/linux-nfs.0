Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:50302 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965021Ab1GMLID (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Jul 2011 07:08:03 -0400
Date: Wed, 13 Jul 2011 07:08:00 -0400
From: Jim Rees <rees@umich.edu>
To: NeilBrown <neilb@suse.de>
Cc: Chuck Lever <chuck.lever@oracle.com>, Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: mounting via udp from legacy multi-homed servers...
Message-ID: <20110713110800.GA25370@merit.edu>
References: <20110713173426.03576562@notabene.brown>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110713173426.03576562@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

NeilBrown wrote:

  1/ We could use tcp for all rpcbind lookups if tcp was requested for either
     MOUNT or NFS.

If I requested tcp for mount and then also got tcp for rpcbind, I would find
that natural and useful.

  2/ If '-v' was given and a UDP lookup to portmap timedout, we could retry
     without connecting (and with a shorter timeout), and print an explanatory 
     message if that succeeded.

If '-v' actually changed the behavior of the mount command rather than just
increasing the verbosity I would find that surprising.

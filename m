Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:57727 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932120Ab2AKRqH convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Jan 2012 12:46:07 -0500
Message-ID: <1326303963.19024.1.camel@lade.trondhjem.org>
Subject: Re: [PATCH 0/5] NFS: create blocklayout pipe per network namesapce
 context
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Pavel Emelianov <xemul@parallels.com>, "neilb@suse.de" <neilb@suse.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        James Bottomley <jbottomley@parallels.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "devel@openvz.org" <devel@openvz.org>
Date: Wed, 11 Jan 2012 12:46:03 -0500
In-Reply-To: <4F0DC582.6030805@parallels.com>
References: <20111129090754.20730.64567.stgit@localhost6.localdomain6>
			 <1325285705.10984.4.camel@lade.trondhjem.org>
		 <1325797111.11084.22.camel@lade.trondhjem.org>
		 <4F0C35F3.7060508@parallels.com>
	 <1326299003.17212.7.camel@lade.trondhjem.org>
	 <4F0DC582.6030805@parallels.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2012-01-11 at 21:23 +0400, Stanislav Kinsbursky wrote: 
> I've sent rebased "v2" of the patch set, contains updated patch "SUNRPC: handle 
> RPC client pipefs dentries by network namespace aware routine", which, I 
> believe, fixes oops, spotted by Bryan (it was caused by excessive call of 
> rpc_put_mount() on PipeFS dentries unlink).
> So, if I'm not mistaken here, there's no need in implementing of dummy versions 
> of rpc_pipefs_notifier_(un)register() or any other dummy stuff.

OK. Fair enough. We'll give it some testing to make sure that we don't
hit it again...

> BTW, it looks like that in last 2 days I've sent all updates to the issues you 
> pointed out. If not, please, ping me once more.

I'm in the process of reviewing it right now.

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com


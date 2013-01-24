Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:48777 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755552Ab3AXTMR convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Jan 2013 14:12:17 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Ben Greear <greearb@candelatech.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Comments on the bind-to-local IP patch series I posted?
Date: Thu, 24 Jan 2013 19:12:15 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA91833788D@sacexcmbx05-prd.hq.netapp.com>
References: <51018157.9060000@candelatech.com>
In-Reply-To: <51018157.9060000@candelatech.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2013-01-24 at 10:45 -0800, Ben Greear wrote:
> I'd really like to get some feedback on whether the patches I posted
> have a chance at upstream inclusion.  If the whole idea is DOA,
> then just let me know and I promise not to ask again for a few
> years :)
> 
> Otherwise, if any improvements are needed, I'll be happy to work on
> them.

My stated goal has always been to support this kind of setup through net
namespaces and containers. Now that Stanislav has added that support (at
least for the RPC+NFS clients), why do we need a second solution?

IOW: Is there any reason why you can't just use 'virt-sandbox', for
instance, to start up an lxc session with its own network ip address and
then run your application?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [2.6.31-rc7] NFS4 client manager kthread spinning...
Date: Mon, 24 Aug 2009 19:18:27 -0400
Message-ID: <1251155907.6325.359.camel@heimdal.trondhjem.org>
References: <6278d2220908240818g3fc23311i607143b7cb6b965d@mail.gmail.com>
	 <1251134769.6325.273.camel@heimdal.trondhjem.org>
	 <6278d2220908241612g32cf4e61l3bc80c3f8c9d4037@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>
To: Daniel J Blueman <daniel.blueman@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:21764 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753381AbZHXXSl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Aug 2009 19:18:41 -0400
In-Reply-To: <6278d2220908241612g32cf4e61l3bc80c3f8c9d4037-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-08-25 at 00:12 +0100, Daniel J Blueman wrote:
> Perhaps unrelated to the manager kthread, I reproduced a
> "nfs4_reclaim_open_state: Lock reclaim failed!" message ultimately -
> expected/significant?

It is not unexpected in a situation where you lose connection with the
server. Another client is then free step in and grab the lock.

We should probably be issuing a SIGLOST to the process and clear the
page cache in this situation. Currently, we cravenly write out the data
despite the fact that we're no longer holding a lock...

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

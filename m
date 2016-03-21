Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from dragon.async.com.br ([208.70.149.241]:37510 "EHLO
	dragon.async.com.br" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754922AbcCUU4v (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Mar 2016 16:56:51 -0400
Date: Mon, 21 Mar 2016 17:56:38 -0300
From: Christian Robottom Reis <kiko@acm.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: NFS List <linux-nfs@vger.kernel.org>
Subject: Re: Finding and breaking client locks
Message-ID: <20160321205637.GB5118@async.com.br>
References: <20160321143914.GA6397@anthem.async.com.br>
 <20160321131906.05ec478b@tlielax.poochiereds.net>
 <20160321175500.GA5118@async.com.br>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160321175500.GA5118@async.com.br>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 21, 2016 at 02:55:00PM -0300, Christian Robottom Reis wrote:
> > Alternately, there is the /proc/fs/nfsd/unlock_ip interface. Supposedly
> > you can echo an address into there and it'll forcibly drop all of the
> > locks that that that client holds. I've not used that so YMMV there.
> 
> Oh! That's a very interesting, and I now see it documented here:
> 
>     http://people.redhat.com/rpeterso/Patches/NFS/NLM/004.txt

On second look, I don't think that interface is meant to take a client
IP, but rather a server IP:

  "They are intended to allow admin or user mode script to release NLM
   locks based on either a path name or a server in-bound ip address[...]"

That's why echoing the client IP makes no difference.

I'm surprised -- so far I've found no facility for lock management
server-side other than restarting the server.
-- 
Christian Robottom Reis | [+55 16] 3376 0125   | http://async.com.br/~kiko
                        | [+55 16] 991 126 430 | http://launchpad.net/~kiko

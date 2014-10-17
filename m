Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f44.google.com ([209.85.216.44]:55157 "EHLO
	mail-qa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751342AbaJQVGs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Oct 2014 17:06:48 -0400
Received: by mail-qa0-f44.google.com with SMTP id x12so1072335qac.17
        for <linux-nfs@vger.kernel.org>; Fri, 17 Oct 2014 14:06:48 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Fri, 17 Oct 2014 17:06:46 -0400
To: Colin Hudler <chudler@cs.uchicago.edu>
Cc: linux-nfs@vger.kernel.org
Subject: Re: when rpc.mountd flushes auth.unix.gid
Message-ID: <20141017170646.1700320e@tlielax.poochiereds.net>
In-Reply-To: <54412AC6.7070000@cs.uchicago.edu>
References: <54412AC6.7070000@cs.uchicago.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 17 Oct 2014 09:42:14 -0500
Colin Hudler <chudler@cs.uchicago.edu> wrote:

> We have a few hundred computers mounting an NFS server in a typical 
> LDAP-based users (nss) setup. We frequently add and remove exports and 
> use exportfs -r to update etab. Every time we do so, the clients report 
> "NFS server not responding" and start backing off their requests. After 
> a painful 3-5 minutes, they recover and life is normal again.
> 
> We discovered that when the rpc.mountd cache flushing occurs, our NIS 
> system is overwhelmed with grouplist requests and this obviously blocks 
> things. We are working on that problem separately, and I admit this to 
> be a weakness in our setup. My question is simple.
> 
> Why does it flush auth.unix.gid when the etab changed? I think it makes 
> unnecessary work for rpc.mountd because the gids are unlikely to have 
> changed, and they already have a reasonable expiration policy.
> 

Most likely because no one really cared until now.

When exports change, cache_flush() is called and that function flushes
out all of the kernel caches.

I expect that could be made to do something a bit more granular, but
you may need to do some archaeology in mountd/exportfs (and the kernel)
to ensure that you're not missing anything.

-- 
Jeff Layton <jlayton@primarydata.com>

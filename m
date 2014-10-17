Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f51.google.com ([209.85.220.51]:42064 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751158AbaJQWYR convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Oct 2014 18:24:17 -0400
Received: by mail-pa0-f51.google.com with SMTP id lj1so1596595pab.38
        for <linux-nfs@vger.kernel.org>; Fri, 17 Oct 2014 15:24:16 -0700 (PDT)
References: <54412AC6.7070000@cs.uchicago.edu> <20141017170646.1700320e@tlielax.poochiereds.net>
Mime-Version: 1.0 (1.0)
In-Reply-To: <20141017170646.1700320e@tlielax.poochiereds.net>
Content-Type: text/plain;
	charset=us-ascii
Message-Id: <689A9C05-09FC-4EDB-B607-CF59E9943FE4@primarydata.com>
Cc: Colin Hudler <chudler@cs.uchicago.edu>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
From: Tom Haynes <thomas.haynes@primarydata.com>
Subject: Re: when rpc.mountd flushes auth.unix.gid
Date: Fri, 17 Oct 2014 17:24:14 -0500
To: Jeff Layton <jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>




> On Oct 17, 2014, at 4:06 PM, Jeff Layton <jeff.layton@primarydata.com> wrote:
> 
> On Fri, 17 Oct 2014 09:42:14 -0500
> Colin Hudler <chudler@cs.uchicago.edu> wrote:
> 
>> We have a few hundred computers mounting an NFS server in a typical 
>> LDAP-based users (nss) setup. We frequently add and remove exports and 
>> use exportfs -r to update etab. Every time we do so, the clients report 
>> "NFS server not responding" and start backing off their requests. After 
>> a painful 3-5 minutes, they recover and life is normal again.
>> 
>> We discovered that when the rpc.mountd cache flushing occurs, our NIS 
>> system is overwhelmed with grouplist requests and this obviously blocks 
>> things. We are working on that problem separately, and I admit this to 
>> be a weakness in our setup. My question is simple.
>> 
>> Why does it flush auth.unix.gid when the etab changed? I think it makes 
>> unnecessary work for rpc.mountd because the gids are unlikely to have 
>> changed, and they already have a reasonable expiration policy.
> 
> Most likely because no one really cared until now.
> 
> When exports change, cache_flush() is called and that function flushes
> out all of the kernel caches.
> 
> I expect that could be made to do something a bit more granular, but
> you may need to do some archaeology in mountd/exportfs (and the kernel)
> to ensure that you're not missing anything.
> 

One thing would be to not remove the exports which are going to be added back in.

The catch here is that you have to account for new entries which need to be added.



> -- 
> Jeff Layton <jlayton@primarydata.com>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

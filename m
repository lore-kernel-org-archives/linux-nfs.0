From: Wendy Cheng <s.wendy.cheng@gmail.com>
Subject: Re: multiple instances of rpc.statd
Date: Fri, 25 Apr 2008 09:47:03 -0400
Message-ID: <4811E0D7.4070608@gmail.com>
References: <200804251531.21035.bs@q-leap.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Bernd Schubert <bs-PKu+Ek1N2UGzQB+pC5nmwQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:12922 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751869AbYDYNpa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Apr 2008 09:45:30 -0400
In-Reply-To: <200804251531.21035.bs-PKu+Ek1N2UGzQB+pC5nmwQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bernd Schubert wrote:
> Hello,
>
> on servers with heartbeat managed resources one rather often has the situation 
> one exports different directories from different resources.
>
> It now may happen all resources are running on one host, but they can also run 
> from different hosts. The situation gets even more complicated if the server 
> is also a nfs client.
>
> In principle having different nfs resources works fine, only the statd state 
> directory is a problem. Or in principle the statd concept at all. Actually we 
> would need to have several instances of statd running using different 
> directories. These then would have to be migrated from one server to the 
> other on resource movement. 
> However, as far I understand it, there does not even exist the basic concept 
> for this, doesn't it? 
>
>   
The efforts have been attempted (to remedy this issue) and a complete 
set of patches have been (kept) submitting for the past two years. The  
patch acceptance progress is very slow (I guess people just don't want 
to get bothered with cluster issues ?).

Anyway, the kernel side has the basic infrastructure to handle the 
problem (it stores the incoming clients IP address as part of its 
book-keeping record) - just a little bit tweak will do the job. However, 
the user side statd directory needs to get re-structured. I didn't 
publish the user side directory structure script during my last round of 
submission. Forking statd into multiple threads do not solve all the 
issues. Check out:
https://www.redhat.com/archives/cluster-devel/2007-April/msg00028.html

-- Wendy




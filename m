Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:31771 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932121Ab0HCPLi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Aug 2010 11:11:38 -0400
Message-ID: <4C583193.4070700@oracle.com>
Date: Tue, 03 Aug 2010 11:11:15 -0400
From: Chuck Lever <chuck.lever@oracle.com>
To: Neil Brown <neilb@suse.de>
CC: linux-nfs@vger.kernel.org
Subject: Re: Possible issue with nfs-utils patch: mountd: Replace "struct
 hostent" with "struct addrinfo"
References: <20100803172409.1961c5e1@notabene>
In-Reply-To: <20100803172409.1961c5e1@notabene>
Content-Type: text/plain; charset=US-ASCII; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 08/ 3/10 03:24 AM, Neil Brown wrote:
>
> Hi Chuck,
>   I've been reviewing some recent nfs-utils commits prior to possibly
>   including them in a suse product.
>
> I think there is part of
>
> commit fbc1b2c8e47ee9371c3565b266f1386575b46920
> Author: Chuck Lever<chuck.lever@oracle.com>
> Date:   Tue Jun 22 12:43:01 2010 -0400
>
>      mountd: Replace "struct hostent" with "struct addrinfo"
>
> which is wrong.  However I'm not sure if it actually breaks something or if
> the relevant code is effectively dead.
>
> The questionable chunk is in check_netgroup
>
>
>          /* If hname is ip address convert to FQDN */
> -       if (inet_aton(hname,&addr.sin_addr)&&
> -          (nhp = gethostbyaddr((const char *)&(addr.sin_addr),
> -           sizeof(addr.sin_addr), AF_INET))) {
> -               hname = nhp->h_name;
> +       tmp = host_pton(hname);
> +       if (tmp != NULL) {
> +               freeaddrinfo(tmp);
>                  if (innetgr(netgroup, hname, NULL, NULL))
>                          return 1;
>          }
>
>
> The new code is effectively a no-op - it conditionally calls
>                  if (innetgr(netgroup, hname, NULL, NULL))
>                          return 1;
>
> and if that succeeds, it would have already succeeded near the top of the
> function so we would not get here.
>
> The original code checked if 'hname' looked like an IP address.  If it did it
> looked up the canonical name and checked that for membership in the netgroup.
> I'm not entirely sure when check_netgroup (or client_check) would be called
> with such a string in a context where doing a lookup would make sense.  I
> hunted through the code and found some rmtab manipulations that could result
> in this, but I'm not sure.
>
> This code was originally added about 9 years ago in what is now commit
> 86ae664e66c439354cb4f959e9f289059e7760a4
> which blames it on Anne Milicia<milicia@missioncriticallinux.com>  without
> any real explanation.  I don't suppose Anne is still around ???
>
> Did you think about this at all when you made the patch?  Do you have any
> thoughts about whether that section of code is still needed?  I don't feel
> very comfortable removing it without knowing why it is there, and I don't
> really know why it is there....

I'm not really able to exercise the netgroup logic here, since I don't 
use netgroups.  I assumed that since Steve touched this code as recently 
as last year (see commit 6a72b8af), he would have some test cases to 
ensure I wasn't breaking anything badly.  He might even know of real 
customer scenarios that depend on this logic.

Anyway, from a local static analysis standpoint, it looks like removing 
the gethostbyaddr(3) call is a bug.  The code should continue to perform 
a reverse lookup there to get a new name to use with the second 
innetgr() call.

I recommend this: using the new calls I added, the thing to do is pass 
tmp->ai_addr to host_canonname(), and then call freeaddrinfo(tmp).  The 
string returned by host_canonname() can then be passed to the second 
innetgr(3) call, but needs to be freed before check_netgroup() can 
return to its caller.  That would allow somewhat more confidence that 
the semantics of this function don't change.  If you like, I can code 
something and post it.

Thanks much for the careful review.

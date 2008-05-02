From: Wendy Cheng <s.wendy.cheng@gmail.com>
Subject: Re: recent failover-by-IP changes
Date: Fri, 02 May 2008 18:00:04 -0400
Message-ID: <481B8EE4.8020409@gmail.com>
References: <1B257A25-2B59-448F-B11C-637B8688D883@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:45529 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758690AbYEBV5z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 2 May 2008 17:57:55 -0400
In-Reply-To: <1B257A25-2B59-448F-B11C-637B8688D883@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever wrote:
> Hi Wendy-
>
> Looking at your recent lockd-failover-by-IP changes... I'd like to 
> make sure I understand this logic before I merge it into my NLM IPv6 
> patch set.
>
> In fs/lockd/svcsubs.c:
> > static int
> > nlmsvc_match_ip(void *datap, struct nlm_host *host)
> > {
> > __be32 *server_addr = datap;
> >
> > return host->h_saddr.sin_addr.s_addr == *server_addr;
>
> h_saddr is the local host's source address, not the server address, 
> and is used only on multi-interface systems. Is that what you wanted 
> to compare, or did you mean ->h_addr?

Yes, it is what we want (trying not to change the mainline logic if all 
possible). Bruce did the merge and he did this *right*. Check out how 
nlm_lookup_host() fills in the h_saddr (and how nlmsvc_lookup_host 
passes in "ssin") before our changes. But I'll do the testing over the 
weekend nevertheless - will report back if I see problems.

We'll let you worry about how to make ipv6 working in this case :) .. 
(just joking .. will help if needed) ..

>
> Does it make sense to use nlm_cmp_addr() here as is done in other 
> places in lockd?

It can - but would suggest leave it as today until your ipv6 patches are 
ready (are they ready now ?).

>
> > }
> >
> > int
> > nlmsvc_unlock_all_by_ip(__be32 server_addr)
>
> Should this be "struct in_addr server_addr" ? It would be even nicer 
> if this were a "struct sockaddr *".

Yes, it would be nice. But it would be even "nicer" if we let people run 
this stuff before another round of revising.

>
> > {
> > int ret;
> > ret = nlm_traverse_files(&server_addr, nlmsvc_match_ip, NULL);
> > return ret ? -EIO : 0;
> > }
> > EXPORT_SYMBOL_GPL(nlmsvc_unlock_all_by_ip);
>
> The only call site for nlmsvc_unlock_all_by_ip() is in fs/nfsd/nfsctl.c:
I know .. It is a result from last round of code review. I don't have a 
strong opinion about it though.
>
> > /* get ipv4 address */
> > if (sscanf(fo_path, "%u.%u.%u.%u%c", &b1, &b2, &b3, &b4, &c) != 4)
> > return -EINVAL;
> > server_ip = htonl((((((b1<<8)|b2)<<8)|b3)<<8)|b4);
> >
> > return nlmsvc_unlock_all_by_ip(server_ip);
>
> Why can't you use in4_pton() to convert your IP address?
>
I think in4_pton was my original code (?) We changed it because of a 
legitimate comment from a code review (but I forgot the details from the 
top of my head at this moment). Will follow up after I check the 
archives tomorrow.

BTW, thank you for doing this ipv6 thing - not a trivial task.

-- Wendy


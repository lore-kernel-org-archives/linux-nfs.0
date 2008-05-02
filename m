From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: recent failover-by-IP changes
Date: Fri, 2 May 2008 17:26:08 -0400
Message-ID: <20080502212608.GI21918@fieldses.org>
References: <1B257A25-2B59-448F-B11C-637B8688D883@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wendy Cheng <s.wendy.cheng@gmail.com>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47450 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751083AbYEBV0L (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 2 May 2008 17:26:11 -0400
In-Reply-To: <1B257A25-2B59-448F-B11C-637B8688D883@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 02, 2008 at 04:58:58PM -0400, Chuck Lever wrote:
> Hi Wendy-
>
> Looking at your recent lockd-failover-by-IP changes... I'd like to make 
> sure I understand this logic before I merge it into my NLM IPv6 patch 
> set.
>
> In fs/lockd/svcsubs.c:
> > static int
> > nlmsvc_match_ip(void *datap, struct nlm_host *host)
> > {
> > 	__be32 *server_addr = datap;
> >
> > 	return host->h_saddr.sin_addr.s_addr == *server_addr;
>
> h_saddr is the local host's source address, not the server address, and 
> is used only on multi-interface systems.  Is that what you wanted to 
> compare, or did you mean ->h_addr?

This is server-side code--h_saddr, last I checked, isn't even filled in
on the client side.  So the current host *is* the server.

--b.

>
> Does it make sense to use nlm_cmp_addr() here as is done in other places 
> in lockd?
>
> > }
> >
> > int
> > nlmsvc_unlock_all_by_ip(__be32 server_addr)
>
> Should this be "struct in_addr server_addr" ?  It would be even nicer if 
> this were a "struct sockaddr *".
>
> > {
> > 	int ret;
> > 	ret = nlm_traverse_files(&server_addr, nlmsvc_match_ip, NULL);
> > 	return ret ? -EIO : 0;
> > }
> > EXPORT_SYMBOL_GPL(nlmsvc_unlock_all_by_ip);
>
> The only call site for nlmsvc_unlock_all_by_ip() is in fs/nfsd/nfsctl.c:
>
> > 	/* get ipv4 address */
> > 	if (sscanf(fo_path, "%u.%u.%u.%u%c", &b1, &b2, &b3, &b4, &c) != 4)
> > 		return -EINVAL;
> > 	server_ip = htonl((((((b1<<8)|b2)<<8)|b3)<<8)|b4);
> >
> > 	return nlmsvc_unlock_all_by_ip(server_ip);
>
> Why can't you use in4_pton() to convert your IP address?

From: Chuck Lever <chuck.lever@oracle.com>
Subject: recent failover-by-IP changes
Date: Fri, 2 May 2008 16:58:58 -0400
Message-ID: <1B257A25-2B59-448F-B11C-637B8688D883@oracle.com>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Wendy Cheng <s.wendy.cheng@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:45008 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757829AbYEBU7Y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 May 2008 16:59:24 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Wendy-

Looking at your recent lockd-failover-by-IP changes... I'd like to  
make sure I understand this logic before I merge it into my NLM IPv6  
patch set.

In fs/lockd/svcsubs.c:
 > static int
 > nlmsvc_match_ip(void *datap, struct nlm_host *host)
 > {
 > 	__be32 *server_addr = datap;
 >
 > 	return host->h_saddr.sin_addr.s_addr == *server_addr;

h_saddr is the local host's source address, not the server address,  
and is used only on multi-interface systems.  Is that what you wanted  
to compare, or did you mean ->h_addr?

Does it make sense to use nlm_cmp_addr() here as is done in other  
places in lockd?

 > }
 >
 > int
 > nlmsvc_unlock_all_by_ip(__be32 server_addr)

Should this be "struct in_addr server_addr" ?  It would be even nicer  
if this were a "struct sockaddr *".

 > {
 > 	int ret;
 > 	ret = nlm_traverse_files(&server_addr, nlmsvc_match_ip, NULL);
 > 	return ret ? -EIO : 0;
 > }
 > EXPORT_SYMBOL_GPL(nlmsvc_unlock_all_by_ip);

The only call site for nlmsvc_unlock_all_by_ip() is in fs/nfsd/nfsctl.c:

 > 	/* get ipv4 address */
 > 	if (sscanf(fo_path, "%u.%u.%u.%u%c", &b1, &b2, &b3, &b4, &c) != 4)
 > 		return -EINVAL;
 > 	server_ip = htonl((((((b1<<8)|b2)<<8)|b3)<<8)|b4);
 >
 > 	return nlmsvc_unlock_all_by_ip(server_ip);

Why can't you use in4_pton() to convert your IP address?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com

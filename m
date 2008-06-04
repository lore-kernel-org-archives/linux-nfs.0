From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: size of nfsv4 writes
Date: Wed, 04 Jun 2008 12:46:17 -0400
Message-ID: <1212597977.7422.4.camel@localhost>
References: <4846C586.1050000@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: Olga Kornievskaia <aglo@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:58704 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750987AbYFDQqT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Jun 2008 12:46:19 -0400
In-Reply-To: <4846C586.1050000@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2008-06-04 at 12:40 -0400, Olga Kornievskaia wrote:
> While testing NFSv4 performance over the 10GE network, we are seeing the 
> following behavior and would like to know if it is normal or a bug in 
> the client code.
> 
> The server offers the max_write of 1M. The client mounts the server with 
> the "wsize" option of 1M. Yet during the write we are seeing that the 
> write size is at most 49K. Why does client never come close to 1M limit?

I have a feeling that is due to some crap in the VM. I'm currently
investigating a situation where it appears we're sending 1 COMMIT for
every 1-5 32k WRITEs. This is not a policy that stems from the NFS
client, so it would appear that the VM is being silly about things.

I'm specially suspicious of the code in get_dirty_limits() that is
setting a limit to the number of dirty pages based on the number of
pages a given BDI has written out in the recent past. As far as I can
see, the intention is to penalise devices that are slow writers, but in
practice it doesn't do that: it penalises the devices that have the
least activity.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [NFS] [PATCH] NFS: Add support for AF_INET6 addresses in
	nfs_compare_super()
Date: Fri, 30 Nov 2007 15:09:50 -0500
Message-ID: <6ACBA668-4FA2-49B1-B967-946C8649B850@oracle.com>
References: <20071130191237.3431.12598.stgit@picasso.1015granger.net>
	<1196450263.17561.0.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IyCDj-0007km-UO
	for nfs@lists.sourceforge.net; Fri, 30 Nov 2007 12:12:20 -0800
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IyCDo-0001xx-Kt
	for nfs@lists.sourceforge.net; Fri, 30 Nov 2007 12:12:26 -0800
In-Reply-To: <1196450263.17561.0.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>


On Nov 30, 2007, at 2:17 PM, Trond Myklebust wrote:

>
> On Fri, 2007-11-30 at 14:12 -0500, Chuck Lever wrote:
>> Refactor nfs_compare_super() and add AF_INET6 support.
>>
>> Replace the generic memcmp() to document explicitly what parts of the
>> addresses must match in this check, and make the comparison  
>> independent
>> of the lengths of both addresses.
>>
>> A side benefit is both tests are more computationally efficient  
>> than a
>> memcmp().
>>
>> Note the "void *" casts are temporary.
>>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>
>>  fs/nfs/super.c |   41 ++++++++++++++++++++++++++++++++++++++---
>>  1 files changed, 38 insertions(+), 3 deletions(-)
>>
>> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
>> index 6b004d8..e5646a9 100644
>> --- a/fs/nfs/super.c
>> +++ b/fs/nfs/super.c
>> @@ -45,6 +45,8 @@
>>  #include <linux/nfs_idmap.h>
>>  #include <linux/vfs.h>
>>  #include <linux/inet.h>
>> +#include <linux/in6.h>
>> +#include <net/ipv6.h>
>>  #include <linux/nfs_xdr.h>
>>  #include <linux/magic.h>
>>  #include <linux/parser.h>
>> @@ -1302,15 +1304,48 @@ static int nfs_set_super(struct  
>> super_block *s, void *data)
>>  	return ret;
>>  }
>>
>> +static int nfs_compare_super_address(struct nfs_server *server1,
>> +				     struct nfs_server *server2)
>> +{
>> +	struct sockaddr_storage *ssp1 = (void *)&server1->nfs_client- 
>> >cl_addr;
>> +	struct sockaddr_storage *ssp2 = (void *)&server2->nfs_client- 
>> >cl_addr;
>> +
>> +	if (ssp1->ss_family != ssp2->ss_family)
>> +		return 0;
>> +
>> +	switch (ssp1->ss_family) {
>> +	case AF_INET: {
>> +		struct sockaddr_in *sin1 = (struct sockaddr_in *)ssp1;
>> +		struct sockaddr_in *sin2 = (struct sockaddr_in *)ssp2;
>> +		if (sin1->sin_addr.s_addr != sin2->sin_addr.s_addr)
>> +			return 0;
>> +		if (sin1->sin_port != sin2->sin_port)
>
> What if sin2->sin_port == 0?

The original comparison in nfs_compare_super() uses a memcmp() to  
compare sizeof(struct sockaddr_in) bytes, which would include the  
sin_port field of both addresses, right?  Thus the original  
comparison would find a match when sin2->sin_port is zero only if  
sin1->sin_port is also zero.

AFAICT, the comparisons in nfs_compare_super_address() provide  
precisely the same check as the memcmp() in the original.

>> +			return 0;
>> +		break;
>> +	}
>> +	case AF_INET6: {
>> +		struct sockaddr_in6 *sin1 = (struct sockaddr_in6 *)ssp1;
>> +		struct sockaddr_in6 *sin2 = (struct sockaddr_in6 *)ssp2;
>> +		if (!ipv6_addr_equal(&sin1->sin6_addr, &sin2->sin6_addr))
>> +			return 0;
>> +		if (sin1->sin6_port != sin2->sin6_port)
>> +			return 0;
>> +		break;
>> +	}
>> +	default:
>> +		return 0;
>> +	}
>> +
>> +	return 1;
>> +}
>> +
>>  static int nfs_compare_super(struct super_block *sb, void *data)
>>  {
>>  	struct nfs_sb_mountdata *sb_mntdata = data;
>>  	struct nfs_server *server = sb_mntdata->server, *old = NFS_SB(sb);
>>  	int mntflags = sb_mntdata->mntflags;
>>
>> -	if (memcmp(&old->nfs_client->cl_addr,
>> -				&server->nfs_client->cl_addr,
>> -				sizeof(old->nfs_client->cl_addr)) != 0)
>> +	if (!nfs_compare_super_address(old, server))
>>  		return 0;
>>  	/* Note: NFS_MOUNT_UNSHARED == NFS4_MOUNT_UNSHARED */
>>  	if (old->flags & NFS_MOUNT_UNSHARED)
>>
>

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




-------------------------------------------------------------------------
SF.Net email is sponsored by: The Future of Linux Business White Paper
from Novell.  From the desktop to the data center, Linux is going
mainstream.  Let it simplify your IT future.
http://altfarm.mediaplex.com/ad/ck/8857-50307-18918-4
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs


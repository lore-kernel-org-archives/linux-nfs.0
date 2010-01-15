From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 3/3] NFSD: Enable NFS server use of PF_INET6
Date: Fri, 15 Jan 2010 18:09:17 -0500
Message-ID: <157AD76E-D7E1-49AC-8F1A-A4EA588EE3A9@oracle.com>
References: <20100113210650.19409.38009.stgit@localhost.localdomain> <20100113211048.19409.86029.stgit@localhost.localdomain> <20100115223519.GF30624@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:38690 "EHLO
	rcsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758600Ab0AOXKQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Jan 2010 18:10:16 -0500
In-Reply-To: <20100115223519.GF30624@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 15, 2010, at 5:35 PM, J. Bruce Fields wrote:

> On Wed, Jan 13, 2010 at 04:10:48PM -0500, Chuck Lever wrote:
>> Try to use an PF_INET6 listener for NFSD if IPv6 is enabled in the
>> kernel.
>>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>
>> fs/nfsd/nfsctl.c |   36 +++++++++++++++++++++++++++++-------
>> fs/nfsd/nfssvc.c |   27 ++++++++++++++++++++++-----
>> 2 files changed, 51 insertions(+), 12 deletions(-)
>>
>> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
>> index 2604c3e..7ebb7a5 100644
>> --- a/fs/nfsd/nfsctl.c
>> +++ b/fs/nfsd/nfsctl.c
>> @@ -981,6 +981,26 @@ static ssize_t __write_ports_delfd(char *buf)
>> 	return len;
>> }
>>
>> +static ssize_t __write_ports_create_xprt(struct svc_serv *serv,
>> +					 const char *transport,
>> +					 const int family,
>> +					 const unsigned short port)
>> +{
>> +	int err;
>> +
>> +	err = svc_create_xprt(serv, transport, family, port,
>> +						SVC_SOCK_ANONYMOUS);
>> +
>> +	if (err < 0) {
>> +		/* Give a reasonable perror msg for bad transport string */
>> +		if (err == -ENOENT)
>> +			err = -EPROTONOSUPPORT;
>
> I realize you're just moving this code, not writing it, so this is a
> separate question, but: it looks like it's svc_create_xprt() itself  
> that
> chooses ENOENT for this case.  Is there any reason it shouldn't just  
> use
> EPROTONOSUPPORT from the start?

I guess this little transformation is for the benefit of rpc.nfsd?  I  
don't know of a reason offhand why you couldn't change  
svc_create_xprt().  I don't immediately see any of svc_create_xprt's  
callers that might depend on getting ENOENT, but I didn't look very  
hard.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




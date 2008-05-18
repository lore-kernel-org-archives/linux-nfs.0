From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] nfs: Fix misparsing of nfsv4 fs_locations attribute
Date: Sun, 18 May 2008 11:22:18 -0400
Message-ID: <CF603745-0163-469F-AC12-B4C5747038FC@oracle.com>
References: <20080509011918.GK12690@fieldses.org> <1210309839.8657.0.camel@localhost> <20080509152750.GA325@fieldses.org> <20080509165204.GB1907@fieldses.org> <20080509171208.GC1907@fieldses.org> <20080509235930.GM1907@fieldses.org> <C4A41609-740F-450E-BE8F-7F51A8A9327B@oracle.com> <1210440728.12927.5.camel@localhost> <5FE6354F-8E28-4697-A27D-8532FD547683@oracle.com> <1d07ca700805101807s7c034b08sc531993aa81010b2@mail.gmail.com> <20080516195326.GD14228@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: "david m. richter" <richterd@gmail.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org, Manoj Naik <manoj@almaden.ibm.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:34343 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753779AbYERPab (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 18 May 2008 11:30:31 -0400
In-Reply-To: <20080516195326.GD14228@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May 16, 2008, at 3:53 PM, J. Bruce Fields wrote:
> On Sat, May 10, 2008 at 09:07:23PM -0400, david m. richter wrote:
>> On Sat, May 10, 2008 at 7:50 PM, Chuck Lever  
>> <chuck.lever@oracle.com> wrote:
>>> On May 10, 2008, at 10:32 AM, Trond Myklebust wrote:
>>>>
>>>> On Fri, 2008-05-09 at 19:29 -0700, Chuck Lever wrote:
>>>>>
>>>>> Should you use in4_pton() instead?
>>>>
>>>> Can we rather convert this to use nfs_parse_server_address? We  
>>>> don't
>>>> need 10 different ways to parse text addresses...
>>>
>>> I'm OK with that, as long as there isn't a technical problem with  
>>> using
>>> in4_pton().
>>
>> nfs_parse_server_address() uses in4_pton(), it just also groks ipv6.
>
> This is all a bit orthogonal to the actual bug, as all those functions
> want null-terminated strings too.
>
> We could apply the below (compile-tested only) and then add ipv6  
> support
> and converting to nfs_parse_server_address() in a subsequent patch.

I'm looking at this code for other reasons, but it would be very easy  
to teach nfs_parse_server_address() to take a string length and not  
assume the passed-in address string is null-terminated.  Both in4_pton  
and in6_pton will take a string length.

> From 530b441f2239d8bcedf9456c3c570d9c179cb406 Mon Sep 17 00:00:00 2001
> From: J. Bruce Fields <bfields@citi.umich.edu>
> Date: Fri, 9 May 2008 15:10:56 -0700
> Subject: [PATCH] nfs: Fix misparsing of nfsv4 fs_locations attribute
>
> The code incorrectly assumes here that the server name (or ip address)
> is null-terminated.  This can cause referrals to fail in some cases.
>
> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> ---
> fs/nfs/nfs4namespace.c |   13 ++++++++++---
> 1 files changed, 10 insertions(+), 3 deletions(-)
>
> diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
> index 5f9ba41..40a0209 100644
> --- a/fs/nfs/nfs4namespace.c
> +++ b/fs/nfs/nfs4namespace.c
> @@ -93,14 +93,21 @@ static int nfs4_validate_fspath(const struct  
> vfsmount *mnt_parent,
> 	return 0;
> }
>
> +#define MAX_IPADDR_STRLEN 40
> /*
>  * Check if the string represents a "valid" IPv4 address
>  */
> -static inline int valid_ipaddr4(const char *buf)
> +static inline int valid_ipaddr4(const struct nfs4_string *buf)
> {
> 	int rc, count, in[4];
> +	char str[MAX_IPADDR_STRLEN];
>
> -	rc = sscanf(buf, "%d.%d.%d.%d", &in[0], &in[1], &in[2], &in[3]);
> +	if (buf->len >= MAX_IPADDR_STRLEN)
> +		return -EINVAL;
> +	memcpy(str, buf->data, buf->len);
> +	str[buf->len] = '\0';
> +
> +	rc = sscanf(str, "%d.%d.%d.%d", &in[0], &in[1], &in[2], &in[3]);
> 	if (rc != 4)
> 		return -EINVAL;
> 	for (count = 0; count < 4; count++) {
> @@ -178,7 +185,7 @@ static struct vfsmount  
> *nfs_follow_referral(const struct vfsmount *mnt_parent,
> 			};
>
> 			if (location->servers[s].len <= 0 ||
> -			    valid_ipaddr4(location->servers[s].data) < 0) {
> +			    valid_ipaddr4(&location->servers[s]) < 0) {
> 				s++;
> 				continue;
> 			}
> -- 
> 1.5.5.rc1
>

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




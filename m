From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] Fix IP address check in check_netgroup()
Date: Wed, 4 Aug 2010 10:58:50 -0400
Message-ID: <7D005326-D41F-4EA9-B6B8-C4987B534950@oracle.com>
References: <20100803191107.19326.19237.stgit@seurat.1015granger.net> <20100804102913.207c1a4d@notabene>
Mime-Version: 1.0 (Apple Message framework v1081)
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:50925 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932985Ab0HDPAB convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Aug 2010 11:00:01 -0400
In-Reply-To: <20100804102913.207c1a4d@notabene>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Aug 3, 2010, at 8:29 PM, Neil Brown wrote:

> On Tue, 03 Aug 2010 15:13:06 -0400
> Chuck Lever <chuck.lever@oracle.com> wrote:
> 
>> Neil Brown reports that recent changes to replace
>> gethostby{addr,name}(3) with get{addr,info}name(3) may have
>> inadvertently broken netgroup support.  There used to be a
>> gethostbyaddr(3) call in the third paragraph in check_netgroup().
>> 
>> See http://marc.info/?l=linux-nfs&m=128084830214653&w=2 .
>> 
>> Introduced by commit 0509d3428f523776ddd9d6e9fa318587d3ec7d84.
>> 
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> 
> Thanks Chuck - that look good, except .....
> 
> 
>> ---
>> 
>> Compile-tested only.
>> 
>> support/export/client.c |   37 ++++++++++++++++++++++++++++---------
>> 1 files changed, 28 insertions(+), 9 deletions(-)
>> 
>> diff --git a/support/export/client.c b/support/export/client.c
>> index 91b17f3..0d34a55 100644
>> --- a/support/export/client.c
>> +++ b/support/export/client.c
>> @@ -583,43 +583,62 @@ static int
>> check_netgroup(const nfs_client *clp, const struct addrinfo *ai)
>> {
>> 	const char *netgroup = clp->m_hostname + 1;
>> -	const char *hname = ai->ai_canonname;
>> 	struct addrinfo *tmp = NULL;
>> 	struct hostent *hp;
>> +	char *dot, *hname;
>> 	int i, match;
>> -	char *dot;
>> +
>> +	match = 0;
>> +
>> +	hname = strdup(ai->ai_canonname);
>> +	if (hname == NULL) {
>> +		xlog(D_GENERAL, "%s: no memory for strdup", __func__);
>> +		goto out;
>> +	}
>> 
>> 	/* First, try to match the hostname without
>> 	 * splitting off the domain */
>> -	if (innetgr(netgroup, hname, NULL, NULL))
>> -		return 1;
>> +	if (innetgr(netgroup, hname, NULL, NULL)) {
>> +		match = 1;
>> +		goto out;
>> +	}
>> 
>> 	/* See if hname aliases listed in /etc/hosts or nis[+]
>> 	 * match the requested netgroup */
>> 	hp = gethostbyname(hname);
>> 	if (hp != NULL) {
>> 		for (i = 0; hp->h_aliases[i]; i++)
>> -			if (innetgr(netgroup, hp->h_aliases[i], NULL, NULL))
>> -				return 1;
>> +			if (innetgr(netgroup, hp->h_aliases[i], NULL, NULL)) {
>> +				match = 1;
>> +				goto out;
>> +			}
>> 	}
>> 
>> 	/* If hname is ip address convert to FQDN */
>> 	tmp = host_pton(hname);
>> 	if (tmp != NULL) {
>> +		char *cname = host_canonname(tmp->ai_addr);
>> 		freeaddrinfo(tmp);
>> -		if (innetgr(netgroup, hname, NULL, NULL))
>> -			return 1;
>> +		if (cname != NULL) {
>> +			hname = cname;
> 
> You need to "free(hname)" before assigning cname to it.
> Also ...
> 
>> +			if (innetgr(netgroup, hname, NULL, NULL)) {
>> +				match = 1;
>> +				goto out;
>> +			}
>> +		}
>> 	}
>> 
>> 	/* Okay, strip off the domain (if we have one) */
>> 	dot = strchr(hname, '.');
>> 	if (dot == NULL)
>> -		return 0;
>> +		goto out;
>> 
>> 	*dot = '\0';
>> 	match = innetgr(netgroup, hname, NULL, NULL);
>> 	*dot = '.';
> 
> It is fairly pointless to re-instate the '.' when we are about to free the
> name.  Not a big issue, but I thought I would mention it.
> 
> With those provisos:
> Reviewed-By: NeilBrown <neilb@suse.de>

Agreed, to both comments.  I'll fix these and post a more final version for Steve.

> Thanks a lot!
> 
> NeilBrown
> 
>> 
>> +out:
>> +	free(hname);
>> 	return match;
>> }
>> #else	/* !HAVE_INNETGR */

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




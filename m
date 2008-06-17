From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 1/4] NFS: Use common device name parsing logic for NFSv4 and NFSv2/v3
Date: Tue, 17 Jun 2008 16:47:53 -0400
Message-ID: <796E0596-0AC5-4385-912B-C4E5C1B58FB2@oracle.com>
References: <20080617181622.3215.61295.stgit@ellison.1015granger.net> <20080617181719.3215.5824.stgit@ellison.1015granger.net> <1213734797.7288.27.camel@localhost> <1213735059.7288.29.camel@localhost>
Mime-Version: 1.0 (Apple Message framework v924)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:21450 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755409AbYFQUsP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Jun 2008 16:48:15 -0400
In-Reply-To: <1213735059.7288.29.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jun 17, 2008, at 4:37 PM, Trond Myklebust wrote:
> On Tue, 2008-06-17 at 16:33 -0400, Trond Myklebust wrote:
>> On Tue, 2008-06-17 at 14:17 -0400, Chuck Lever wrote:
>>> To support passing a raw IPv6 address as a server hostname, we  
>>> need to
>>> expand the logic that handles splitting the passed-in device name  
>>> into
>>> a server hostname and export path
>>>
>>> Start by pulling device name parsing out of the mount option  
>>> validation
>>> functions and into separate helper functions.
>>>
>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>> ---
>>>
>>> fs/nfs/super.c |  124 +++++++++++++++++++++++++++++++++++ 
>>> +--------------------
>>> 1 files changed, 79 insertions(+), 45 deletions(-)
>>>
>>>
>>> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
>>> index d884f52..5e0eefa 100644
>>> --- a/fs/nfs/super.c
>>> +++ b/fs/nfs/super.c
>>> @@ -1216,6 +1216,67 @@ static int nfs_try_mount(struct  
>>> nfs_parsed_mount_data *args,
>>> }
>>>
>>> /*
>>> + * Split "dev_name" into "hostname:export_path".
>>> + *
>>> + * Note: caller frees hostname and export path, even on error.
>>> + */
>>> +static int nfs_parse_devname(const char *dev_name,
>>> +			     char **hostname, size_t maxnamlen,
>>> +			     char **export_path, size_t maxpathlen)
>>> +{
>>> +	size_t len;
>>> +	char *colon, *comma;
>>> +
>>> +	colon = strchr(dev_name, ':');
>>> +	if (colon == NULL)
>>> +		goto out_bad_devname;
>>> +
>>> +	len = colon - dev_name;
>>> +	if (len > maxnamlen)
>>> +		goto out_hostname;
>>> +
>>> +	/* N.B. caller will free nfs_server.hostname in all cases */
>>> +	*hostname = kstrndup(dev_name, len, GFP_KERNEL);
>>> +	if (!*hostname)
>>> +		goto out_nomem;
>>> +
>>> +	/* kill possible hostname list: not supported */
>>> +	comma = strchr(*hostname, ',');
>>> +	if (comma != NULL) {
>>> +		if (comma == *hostname)
>>> +			goto out_bad_devname;
>>
>> Won't this and subsequent errors leak memory in *hostname?
>
> Sorry. I missed the fact that nfs_get_sb() and nfs4_get_sb() will do  
> it
> for us...


That's a useful mistake, actually.  I architected it this way to  
eliminate a lot of indentation and gotos.  If you think this is hard  
to read, maybe I should find a different way to organize this logic?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com

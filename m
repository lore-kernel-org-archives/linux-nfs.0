Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:48759 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758100Ab2CUQiC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Mar 2012 12:38:02 -0400
Message-ID: <4F6A03E8.10407@netapp.com>
Date: Wed, 21 Mar 2012 12:38:00 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v4 03/23] NFS: Add version registering framework
References: <1332343253-24970-1-git-send-email-bjschuma@netapp.com>  <1332343253-24970-4-git-send-email-bjschuma@netapp.com> <1332345817.5779.9.camel@lade.trondhjem.org>
In-Reply-To: <1332345817.5779.9.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/21/2012 12:03 PM, Myklebust, Trond wrote:

> On Wed, 2012-03-21 at 11:20 -0400, bjschuma@netapp.com wrote:
>>  
>> +static int find_nfs_version(struct nfs_subversion **nfs, unsigned int version)
>> +{
>> +	struct nfs_subversion *tmp;
>> +	spin_lock(&nfs_version_lock);
>> +
>> +	list_for_each_entry_safe((*nfs), tmp, &nfs_versions, list) {
>> +		if ((*nfs)->version == version) {
>> +			spin_unlock(&nfs_version_lock);
>> +			return 1;
>> +		}
>> +	};
>> +
> 
> BTW: The above function needs to call try_module_get() under the
> nfs_version_lock. Otherwise you will not be guaranteed that the module
> still exists and is live when you try to use the pointer '*nfs'.


Ah, I didn't think of that.  I'll add in the try_module_get() call and put in a put_nfs_version() function to unreference the module, too.

- Bryan

> 



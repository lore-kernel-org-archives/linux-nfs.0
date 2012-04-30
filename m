Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:31509 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753871Ab2D3SaN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Apr 2012 14:30:13 -0400
Message-ID: <4F9EDA23.6080901@netapp.com>
Date: Mon, 30 Apr 2012 14:29:55 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Isaman, Fred" <Fred.Isaman@netapp.com>
Subject: Re: [PATCH] NFS: Define dummy nfs_init_cinfo() and nfs_init_cinfo_from_inode()
References: <1335808129-6750-1-git-send-email-bjschuma@netapp.com> <1335809816.11828.2.camel@lade.trondhjem.org>
In-Reply-To: <1335809816.11828.2.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/30/2012 02:16 PM, Myklebust, Trond wrote:

> On Mon, 2012-04-30 at 13:48 -0400, bjschuma@netapp.com wrote:
>> From: Bryan Schumaker <bjschuma@netapp.com>
>>
>> These are needed when v3 and v4 are not enabled.
>>
>> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
>> ---
>>  fs/nfs/write.c |   12 ++++++++++++
>>  1 file changed, 12 insertions(+)
>>
>> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
>> index 3636191..f0045e0 100644
>> --- a/fs/nfs/write.c
>> +++ b/fs/nfs/write.c
>> @@ -567,6 +567,18 @@ int nfs_write_need_commit(struct nfs_write_data *data)
>>  }
>>  
>>  #else
>> +static void nfs_init_cinfo_from_inode(struct nfs_commit_info *cinfo,
>> +				      struct inode *inode)
>> +{
>> +}
>> +
>> +void nfs_init_cinfo(struct nfs_commit_info *cinfo,
>> +		    struct inode *inode,
>> +		    struct nfs_direct_req *dreq)
>> +{
>> +}
>> +EXPORT_SYMBOL_GPL(nfs_init_cinfo);
>> +
> 
> We shouldn't need to export this. There should be no submodules when
> we're doing NFSv2 only.
> 


Right, I saw a missing symbol error and exported it out of habit.  I'll resend without the export.

- Bryan

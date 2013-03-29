Return-Path: linux-nfs-owner@vger.kernel.org
Received: from countercultured.net ([209.51.175.25]:49487 "HELO
	countercultured.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754953Ab3C2DmL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Mar 2013 23:42:11 -0400
Message-ID: <51550C03.1000107@davequigley.com>
Date: Thu, 28 Mar 2013 23:35:31 -0400
From: Dave Quigley <dpquigl@davequigley.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Steve Dickson <SteveD@redhat.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 13/14] NFSD: Server implementation of MAC Labeling
References: <1364478845-29796-1-git-send-email-SteveD@redhat.com> <1364478845-29796-14-git-send-email-SteveD@redhat.com> <20130328161444.GF7080@fieldses.org>
In-Reply-To: <20130328161444.GF7080@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 3/28/2013 12:14 PM, J. Bruce Fields wrote:
> On Thu, Mar 28, 2013 at 09:54:04AM -0400, Steve Dickson wrote:
>> From: David Quigley <dpquigl@davequigley.com>
>>
>> This patch adds the ability to encode and decode file labels on the server for
>> the purpose of sending them to the client and also to process label change
>> requests from the client.
>>
>> Signed-off-by: Matthew N. Dodd <Matthew.Dodd@sparta.com>
>> Signed-off-by: Miguel Rodel Felipe <Rodel_FM@dsi.a-star.edu.sg>
>> Signed-off-by: Phua Eu Gene <PHUA_Eu_Gene@dsi.a-star.edu.sg>
>> Signed-off-by: Khin Mi Mi Aung <Mi_Mi_AUNG@dsi.a-star.edu.sg>
>> ---
>>   fs/nfsd/nfs4proc.c |  41 +++++++++++++++++++
>>   fs/nfsd/nfs4xdr.c  | 116 ++++++++++++++++++++++++++++++++++++++++++++++++++---
>>   fs/nfsd/nfsd.h     |   6 ++-
>>   fs/nfsd/vfs.c      |  29 ++++++++++++++
>>   fs/nfsd/vfs.h      |   2 +
>>   fs/nfsd/xdr4.h     |   3 ++
>>   6 files changed, 191 insertions(+), 6 deletions(-)
>>
>> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
>> index ae73175..bb17589 100644
>> --- a/fs/nfsd/nfs4proc.c
>> +++ b/fs/nfsd/nfs4proc.c
>> @@ -42,6 +42,36 @@
>>   #include "current_stateid.h"
>>   #include "netns.h"
>>
>> +#ifdef CONFIG_NFSD_V4_SECURITY_LABEL
>> +#include <linux/security.h>
>> +
>> +static inline void
>> +nfsd4_security_inode_setsecctx(struct svc_fh *resfh, struct nfs4_label *label, u32 *bmval)
>> +{
>> +	struct inode *inode = resfh->fh_dentry->d_inode;
>> +	int status;
>> +
>> +	mutex_lock(&inode->i_mutex);
>> +	status = security_inode_setsecctx(resfh->fh_dentry,
>> +		label->label, label->len);
>> +	mutex_unlock(&inode->i_mutex);
>> +
>> +	if (status)
>> +		/*
>> +		 * We should probably fail the whole open at this point,
>> +		 * but we've already created or opened the file, so it's
>> +		 * too late; So this seems the least of evils:
>> +		 */
>> +		bmval[2] &= ~FATTR4_WORD2_SECURITY_LABEL;
>
> Is there any way to avoid this?
>
> How does the vfs open code handle this?  It has to be able to set a
> security contexts atomically on open(O_CREAT), doesn't it?
>

I believe the way this is handled is that the inode is created and 
labeled and then only after that is it bound to the namespace. Because 
of that ordering we can fail and release the inode without it ever 
having a dentry in the namespace.


> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


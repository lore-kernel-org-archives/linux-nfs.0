Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e28smtp05.in.ibm.com ([122.248.162.5]:43691 "EHLO
	e28smtp05.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751016AbaEAPjd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 May 2014 11:39:33 -0400
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 1 May 2014 21:09:31 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: Dave Chinner <david@fromorbit.com>
Cc: agruen@kernel.org, bfields@fieldses.org, akpm@linux-foundation.org,
        viro@zeniv.linux.org.uk, dhowells@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH -V1 09/22] vfs: Make acl_permission_check() work for richacls
In-Reply-To: <20140429002013.GR15995@dastard>
References: <1398615293-22931-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1398615293-22931-10-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20140429002013.GR15995@dastard>
Date: Thu, 01 May 2014 21:09:23 +0530
Message-ID: <87fvktbj9w.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Dave Chinner <david@fromorbit.com> writes:

> On Sun, Apr 27, 2014 at 09:44:40PM +0530, Aneesh Kumar K.V wrote:
>> From: Andreas Gruenbacher <agruen@kernel.org>
>> 
>> Signed-off-by: Andreas Gruenbacher <agruen@kernel.org>
>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
>> ---
>>  fs/namei.c | 13 +++++++++++++
>>  1 file changed, 13 insertions(+)
>> 
>> diff --git a/fs/namei.c b/fs/namei.c
>> index 26b9a8212837..06474553c08d 100644
>> --- a/fs/namei.c
>> +++ b/fs/namei.c
>> @@ -284,6 +284,19 @@ static int acl_permission_check(struct inode *inode, int mask)
>>  {
>>  	unsigned int mode = inode->i_mode;
>>  
>> +	if (IS_RICHACL(inode)) {
>> +		int error = check_acl(inode, mask);
>> +		if (error != -EAGAIN)
>> +			return error;
>> +		if (mask & (MAY_DELETE_SELF | MAY_TAKE_OWNERSHIP |
>> +			    MAY_CHMOD | MAY_SET_TIMES)) {
>> +			/*
>> +			 * The file permission bit cannot grant these
>> +			 * permissions.
>> +			 */
>> +			return -EACCES;
>> +		}
>> +	}
>>  	if (likely(uid_eq(current_fsuid(), inode->i_uid)))
>>  		mode >>= 6;
>>  	else {
>
> why does this take priority over a simple uid match? Some comments
> explaining this for people unfamiliar with richacls would be nice.
> Not to mention the commit message should also explain the change...
>

Richacl can have further limitation on file owner. Will add more
comments around the function.

-aneesh


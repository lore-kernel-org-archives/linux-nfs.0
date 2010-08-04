Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33881 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932476Ab0HDMgZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Aug 2010 08:36:25 -0400
Message-ID: <4C595EC3.2040500@RedHat.com>
Date: Wed, 04 Aug 2010 08:36:19 -0400
From: Steve Dickson <SteveD@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 02/24] Remove warnings from nfsctl.c
References: <1279669057-17509-1-git-send-email-steved@redhat.com> <1279669057-17509-3-git-send-email-steved@redhat.com> <20100721170646.GA26418@fieldses.org>
In-Reply-To: <20100721170646.GA26418@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 07/21/2010 01:06 PM, J. Bruce Fields wrote:
> On Tue, Jul 20, 2010 at 07:37:15PM -0400, Steve Dickson wrote:
>> nfsctl.c: In function 'expsetup':
>> nfsctl.c:112: warning: signed and unsigned type in conditional expression
>>
>> Signed-off-by: Steve Dickson <steved@redhat.com>
>> ---
>>  support/export/nfsctl.c |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/support/export/nfsctl.c b/support/export/nfsctl.c
>> index 3b9876a..f89c644 100644
>> --- a/support/export/nfsctl.c
>> +++ b/support/export/nfsctl.c
>> @@ -109,7 +109,7 @@ expsetup(struct nfsctl_export *exparg, nfs_export *exp, int unexport)
>>  	str_tolower(exparg->ex_client);
>>  	exparg->ex_flags    = exp->m_export.e_flags;
>>  	exparg->ex_dev      = (!unexport && (exp->m_export.e_flags & NFSEXP_FSID)) ?
>> -				exp->m_export.e_fsid : stb.st_dev;
>> +			(__nfsd_dev_t)exp->m_export.e_fsid : stb.st_dev;
> 
> Any reason not to just define e_fsid as an __nfsd_dev_t to start off
> with?
Well would changing e_fsid from a int to an unsigned long (i.e. __nfsd_dev_t)
break the dump_to_cache() interface between the mound and the kernel?

steved.
> 
> --b.
> 
>>  	exparg->ex_ino      = stb.st_ino;
>>  	exparg->ex_anon_uid = exp->m_export.e_anonuid;
>>  	exparg->ex_anon_gid = exp->m_export.e_anongid;
>> -- 
>> 1.7.0.1
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:8080 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750990Ab3DJP61 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Apr 2013 11:58:27 -0400
Message-ID: <51658C23.5030805@RedHat.com>
Date: Wed, 10 Apr 2013 11:58:27 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@redhat.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 19/19] NFSDv4.2: Added NFS v4.2 support to the NFS server
References: <1364939160-20874-1-git-send-email-SteveD@redhat.com> <1364939160-20874-20-git-send-email-SteveD@redhat.com> <20130410152526.GD24404@pad.fieldses.org>
In-Reply-To: <20130410152526.GD24404@pad.fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 10/04/13 11:25, J. Bruce Fields wrote:
> On Tue, Apr 02, 2013 at 05:46:00PM -0400, Steve Dickson wrote:
>> From: Steve Dickson <steved@redhat.com>
>>
>> This enable NFSv4.2 support for the server. To enable this
>> code do the following:
>>   echo "+4.2" >/proc/fs/nfsd/versions
> 
> The patches are ordered strangely: labeled nFS support depends on 4.2
> support, so we should be adding 4.2 support first, then labeled NFS
> support on top of that.
Seriously that actually matter? So you want just commit the 4.2 and not
not the label NFS patches? 
 
> 
> Note a 4.1 client shouldn't see the server return the new attribute as
> supported unless it's using 4.2, and attempts to set it should error
> out unless it's using 4.2.
How is that handled with 4.0 vers 4.1? Just looking for a point to the code... 

steved.

> 
> --b.
> 
>>
>> after the nfsd kernel module is loaded.
>>
>> Signed-off-by: Steve Dickson <steved@redhat.com>
>> ---
>>  fs/nfsd/nfs4xdr.c | 1 +
>>  fs/nfsd/nfsd.h    | 2 +-
>>  2 files changed, 2 insertions(+), 1 deletion(-)
>>
>> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
>> index 818c1ca..d40b6ac 100644
>> --- a/fs/nfsd/nfs4xdr.c
>> +++ b/fs/nfsd/nfs4xdr.c
>> @@ -1628,6 +1628,7 @@ struct nfsd4_minorversion_ops {
>>  static struct nfsd4_minorversion_ops nfsd4_minorversion[] = {
>>  	[0] = { nfsd4_dec_ops, ARRAY_SIZE(nfsd4_dec_ops) },
>>  	[1] = { nfsd41_dec_ops, ARRAY_SIZE(nfsd41_dec_ops) },
>> +	[2] = { nfsd41_dec_ops, ARRAY_SIZE(nfsd41_dec_ops) },
>>  };
>>  
>>  static __be32
>> diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
>> index 3090561..ac518e4 100644
>> --- a/fs/nfsd/nfsd.h
>> +++ b/fs/nfsd/nfsd.h
>> @@ -24,7 +24,7 @@
>>  /*
>>   * nfsd version
>>   */
>> -#define NFSD_SUPPORTED_MINOR_VERSION	1
>> +#define NFSD_SUPPORTED_MINOR_VERSION	2
>>  /*
>>   * Maximum blocksizes supported by daemon under various circumstances.
>>   */
>> -- 
>> 1.8.1.4
>>

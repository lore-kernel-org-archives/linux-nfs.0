From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH v2 04/47] nfs41: common protocol definitions
Date: Tue, 31 Mar 2009 10:06:07 +0300
Message-ID: <49D1C0DF.8020103@panasas.com>
References: <49CDDFC2.4070402@panasas.com> <1238229061-8176-1-git-send-email-bhalevy@panasas.com> <20090330215457.GM31237@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: "J. Bruce Fields" <bfields@fieldses.org>,
	Mike Sager <sager@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:16908 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754367AbZCaHGM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Mar 2009 03:06:12 -0400
In-Reply-To: <20090330215457.GM31237@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mar. 31, 2009, 0:54 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> On Sat, Mar 28, 2009 at 11:31:01AM +0300, Benny Halevy wrote:
>> Define all NFSv4.1 common operation and error code constants.
>>
>> Note that some of the definitions are used by both the nfs41 client
>> and the server code. This patch is duplicated in the nfs41 and nfsd41
>> sessions patchset.
>>
>> Signed-off-by: Andy Adamson<andros@netapp.com>
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> [nfs41: add exchange id flags]
>> Signed-off-by: Mike Sager <sager@netapp.com>
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> [removed server-only hunk changing NFSERR_REPLAY_ME]
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> [nfs41: add SEQ4_XX to nfs41-common-protocol]
>> Signed-off-by: Andy Adamson <andros@netapp.com>
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> [nfs41: generic error code update]
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> ---
>>  include/linux/nfs4.h |  128 +++++++++++++++++++++++++++++++++++++++++++++++++-
>>  1 files changed, 127 insertions(+), 1 deletions(-)
>>
>> diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
>> index b912311..a34683e 100644
>> --- a/include/linux/nfs4.h
>> +++ b/include/linux/nfs4.h
>> @@ -21,6 +21,7 @@
>>  #define NFS4_FHSIZE		128
>>  #define NFS4_MAXPATHLEN		PATH_MAX
>>  #define NFS4_MAXNAMLEN		NAME_MAX
>> +#define NFS4_MAX_SESSIONID_LEN	16
>>  
>>  #define NFS4_ACCESS_READ        0x0001
>>  #define NFS4_ACCESS_LOOKUP      0x0002
>> @@ -38,6 +39,7 @@
>>  #define NFS4_OPEN_RESULT_CONFIRM 0x0002
>>  #define NFS4_OPEN_RESULT_LOCKTYPE_POSIX 0x0004
>>  
>> +#define NFS4_SHARE_ACCESS_MASK	0x000F
>>  #define NFS4_SHARE_ACCESS_READ	0x0001
>>  #define NFS4_SHARE_ACCESS_WRITE	0x0002
>>  #define NFS4_SHARE_ACCESS_BOTH	0x0003
>> @@ -45,6 +47,19 @@
>>  #define NFS4_SHARE_DENY_WRITE	0x0002
>>  #define NFS4_SHARE_DENY_BOTH	0x0003
>>  
>> +/* nfs41 */
>> +#define NFS4_SHARE_WANT_MASK		0xFF00
>> +#define NFS4_SHARE_WANT_NO_PREFERENCE	0x0000
>> +#define NFS4_SHARE_WANT_READ_DELEG	0x0100
>> +#define NFS4_SHARE_WANT_WRITE_DELEG	0x0200
>> +#define NFS4_SHARE_WANT_ANY_DELEG	0x0300
>> +#define NFS4_SHARE_WANT_NO_DELEG	0x0400
>> +#define NFS4_SHARE_WANT_CANCEL		0x0500
>> +
>> +#define NFS4_SHARE_WHEN_MASK		0xF0000
>> +#define NFS4_SHARE_SIGNAL_DELEG_WHEN_RESRC_AVAIL	0x10000
>> +#define NFS4_SHARE_PUSH_DELEG_WHEN_UNCONTENDED		0x20000
>> +
>>  #define NFS4_SET_TO_SERVER_TIME	0
>>  #define NFS4_SET_TO_CLIENT_TIME	1
>>  
>> @@ -88,6 +103,31 @@
>>  #define NFS4_ACE_GENERIC_EXECUTE              0x001200A0
>>  #define NFS4_ACE_MASK_ALL                     0x001F01FF
>>  
>> +#define EXCHGID4_FLAG_SUPP_MOVED_REFER		0x00000001
>> +#define EXCHGID4_FLAG_SUPP_MOVED_MIGR		0x00000002
>> +#define EXCHGID4_FLAG_USE_NON_PNFS		0x00010000
>> +#define EXCHGID4_FLAG_USE_PNFS_MDS		0x00020000
>> +#define EXCHGID4_FLAG_USE_PNFS_DS		0x00040000
>> +#define EXCHGID4_FLAG_UPD_CONFIRMED_REC_A	0x40000000
>> +#define EXCHGID4_FLAG_CONFIRMED_R		0x80000000
>> +/*
>> + * Since the validity of these bits depends on whether
>> + * they're set in the argument or response, have separate
>> + * invalid flag masks for arg (_A) and resp (_R).
>> + */
>> +#define EXCHGID4_INVAL_FLAG_MASK_A		0xBFF8FFFC
>> +#define EXCHGID4_INVAL_FLAG_MASK_R		0x7FF8FFFC
> 
> Would it be less confusing just to use !EXCHGID_FLAG_MASK_A and
> !EXCHGID_FLAG_MASK_R everywhere?

Fine with me.
Mike, this code came from you, what do you think?
Please Ack.  Thanks,

Benny

> 
> --b.
> 

From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] nfsd4: fix filehandle comment
Date: Wed, 28 Apr 2010 17:46:14 -0400
Message-ID: <20100428214614.GD23474@fieldses.org>
References: <20100428213107.GA23474@fieldses.org> <4BD8A9E8.8060608@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:47762 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751581Ab0D1VqO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Apr 2010 17:46:14 -0400
In-Reply-To: <4BD8A9E8.8060608@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 28, 2010 at 05:34:32PM -0400, Chuck Lever wrote:
> On 04/28/2010 05:31 PM, J. Bruce Fields wrote:
>> From: J. Bruce Fields<bfields@citi.umich.edu>
>>
>> Minor typos.
>>
>> Signed-off-by: J. Bruce Fields<bfields@citi.umich.edu>
>> ---
>>   include/linux/nfsd/nfsfh.h |    4 ++--
>>   1 files changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/include/linux/nfsd/nfsfh.h b/include/linux/nfsd/nfsfh.h
>> index 65e333a..45bb5a8 100644
>> --- a/include/linux/nfsd/nfsfh.h
>> +++ b/include/linux/nfsd/nfsfh.h
>> @@ -40,8 +40,8 @@ struct nfs_fhbase_old {
>>    * This is the new flexible, extensible style NFSv2/v3 file handle.
>>    * by Neil Brown<neilb-YbfuJp6tym7X/JP9YwkgDA@public.gmane.org>  - March 2000
>>    *
>> - * The file handle is seens as a list of 4byte words.
>> - * The first word contains a version number (1) and four descriptor bytes
>> + * The file handle is seens as a list of four-byte words.
>
> seens?  seen?  sent?

Tunnel-vision, I guess.  Better?:

commit 97fe4c3909cee35fa4732694c3837c35f02d7b32
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Wed Apr 28 17:45:06 2010 -0400

    nfsd: further comment typos
    
    Whoops, missed some more.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

diff --git a/include/linux/nfsd/nfsfh.h b/include/linux/nfsd/nfsfh.h
index 45bb5a8..80d55bb 100644
--- a/include/linux/nfsd/nfsfh.h
+++ b/include/linux/nfsd/nfsfh.h
@@ -40,12 +40,12 @@ struct nfs_fhbase_old {
  * This is the new flexible, extensible style NFSv2/v3 file handle.
  * by Neil Brown <neilb-YbfuJp6tym7X/JP9YwkgDA@public.gmane.org> - March 2000
  *
- * The file handle is seens as a list of four-byte words.
+ * The file handle starts with a sequence of four-byte words.
  * The first word contains a version number (1) and three descriptor bytes
  * that tell how the remaining 3 variable length fields should be handled.
  * These three bytes are auth_type, fsid_type and fileid_type.
  *
- * All 4byte values are in host-byte-order.
+ * All four-byte values are in host-byte-order.
  *
  * The auth_type field specifies how the filehandle can be authenticated
  * This might allow a file to be confirmed to be in a writable part of a

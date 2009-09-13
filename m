From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH RFC 02/13] sunrpc: ntoh -> be*_to_cpu
Date: Sun, 13 Sep 2009 19:14:00 +0300
Message-ID: <4AAD1A48.1040801@panasas.com>
References: <4A82DC7B.3090600@panasas.com> <1250090508-9572-1-git-send-email-bhalevy@panasas.com> <20090912140001.GD5858@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	linux-nfs@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from dip-colo-pa.panasas.com ([67.152.220.67]:49989 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754782AbZIMQNB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 13 Sep 2009 12:13:01 -0400
In-Reply-To: <20090912140001.GD5858@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sep. 12, 2009, 17:00 +0300, Al Viro <viro@ZenIV.linux.org.uk> wrote:
> On Wed, Aug 12, 2009 at 06:21:48PM +0300, Benny Halevy wrote:
>> ntohl is already defined as be32_to_cpu.
>> be64_to_cpu has architecture specific optimized implementations.
> 
>>  static inline __be32 *
>>  xdr_decode_hyper(__be32 *p, __u64 *valp)
>>  {
>> -	*valp  = ((__u64) ntohl(*p++)) << 32;
>> -	*valp |= ntohl(*p++);
>> -	return p;
>> +	*valp = be64_to_cpup((__be64 *)p);
>> +	return p + 2;
>>  }
> 
> Erm...  Who has promised you that p will be 64bit-aligned?

Good point.
The following should do then, right?

Benny

git diff --stat -p
 include/linux/sunrpc/xdr.h |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index 7da466b..f5cc089 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -11,6 +11,7 @@
 
 #include <linux/uio.h>
 #include <asm/byteorder.h>
+#include <asm/unaligned.h>
 #include <linux/scatterlist.h>
 
 /*
@@ -117,14 +118,14 @@ static inline __be32 *xdr_encode_array(__be32 *p, const void *s, unsigned int le
 static inline __be32 *
 xdr_encode_hyper(__be32 *p, __u64 val)
 {
-	*(__be64 *)p = cpu_to_be64(val);
+	put_unaligned_be64(val, p);
 	return p + 2;
 }
 
 static inline __be32 *
 xdr_decode_hyper(__be32 *p, __u64 *valp)
 {
-	*valp = be64_to_cpup((__be64 *)p);
+	*valp = get_unaligned_be64(p);
 	return p + 2;
 }
 

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49418 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752091Ab1GLMiZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Jul 2011 08:38:25 -0400
Date: Tue, 12 Jul 2011 21:38:17 +0900 (JST)
Message-Id: <20110712.213817.1045173784079879730.yamato@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, steved@redhat.com
Subject: [PATCH v2] closing fd associated with /proc/fs/nfsd/export_features
From: Masatake YAMATO <yamato@redhat.com>
In-Reply-To: <20110712104652.GA2162@fieldses.org>
References: <20110712.114700.814616059257545652.yamato@redhat.com>
	<20110712104652.GA2162@fieldses.org>
Content-Type: Text/Plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Sorry, my patch has a serious bug.
The value returned from read() is stored to fd.
So fd should not be passed to close().

I rearranged the code as below.

Signed-off-by: Masatake YAMATO <yamato@redhat.com>

diff --git a/support/nfs/exports.c b/support/nfs/exports.c
index c250383..744c01b 100644
--- a/support/nfs/exports.c
+++ b/support/nfs/exports.c
@@ -784,9 +784,10 @@ struct export_features *get_export_features(void)
 	fd = open(path, O_RDONLY);
 	if (fd == -1)
 		goto good;
-	fd = read(fd, buf, 50);
-	if (fd == -1)
+	c = read(fd, buf, 50);
+	if (c == -1)
 		goto err;
+	close(fd);
 	c = sscanf(buf, "%x %x", &ef.flags, &ef.secinfo_flags);
 	if (c != 2)
 		goto err;


> On Tue, Jul 12, 2011 at 11:47:00AM +0900, Masatake YAMATO wrote:
>> A fd associated with /proc/fs/nfsd/export_features opened in get_export_features is 
>> not closed.
>> 
>> 
>> Signed-off-by: Masatake YAMATO <yamato@redhat.com>
> Acked-by: J. Bruce Fields <bfields@redhat.com>
>> 
>> diff --git a/support/nfs/exports.c b/support/nfs/exports.c
>> index c250383..819a18a 100644
>> --- a/support/nfs/exports.c
>> +++ b/support/nfs/exports.c
>> @@ -787,6 +787,7 @@ struct export_features *get_export_features(void)
>>  	fd = read(fd, buf, 50);
>>  	if (fd == -1)
>>  		goto err;
>> +	close(fd);
>>  	c = sscanf(buf, "%x %x", &ef.flags, &ef.secinfo_flags);
>>  	if (c != 2)
>>  		goto err;
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

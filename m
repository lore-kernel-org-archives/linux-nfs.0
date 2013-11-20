Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:19373 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753061Ab3KTDlq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Nov 2013 22:41:46 -0500
Message-ID: <528C2FA7.7060701@redhat.com>
Date: Wed, 20 Nov 2013 09:12:31 +0530
From: Susant Sahani <ssahani@redhat.com>
MIME-Version: 1.0
To: steved@redhat.com
CC: libtirpc-devel@lists.sourceforge.net, linux-nfs@vger.kernel.org
Subject: Re: [Libtirpc-devel] Missing NULL check in  __nc_error()
References: <5286846E.2040503@redhat.com>	<ABA154D0-8846-4673-ADBF-3E701E087590@gmail.com> <52868EF3.4000405@redhat.com>
In-Reply-To: <52868EF3.4000405@redhat.com>
Content-Type: multipart/mixed;
 boundary="------------080809050607000506080304"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080809050607000506080304
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi Steve,
      In the file: getnetconfig.c __nc_error() does not check return 
value from malloc() and can pass NULL pointer to thr_setspecific() which 
can lead to crash. Attached fix.

Thanks,
Susant

On 11/16/2013 02:45 AM, Susant Sahani wrote:
> Yes was reading out the code. Could be because of out of memory also .
>
> On 11/16/2013 02:15 AM, Chuck Lever wrote:
>> Hi-
>>
>> On Nov 15, 2013, at 3:30 PM, Susant Sahani <ssahani@redhat.com> wrote:
>>
>>> Hi,
>>>
>>> __nc_error() does not check return value from malloc() can lead to crash .
>> Curious.  Did you see an actual NULL return from malloc(), or did you notice this via code inspection?  A NULL return is rare and usually indicates a deeper problem.
>>
>>>      trying get familiar with with patch submission
>> Start here for details on formatting your submission, and legal requirements:
>>
>>     https://www.kernel.org/doc/Documentation/SubmittingPatches
>>
>> Send patches to Steve Dickson <steved@redhat.com>, and cc this mailing list.
>>
>> Thanks.
>>
>> --
>> Chuck Lever
>> chucklever[at]gmail[dot]com
>>
>>
>>
> Thanks,
> Susant
>
> ------------------------------------------------------------------------------
> DreamFactory - Open Source REST & JSON Services for HTML5 & Native Apps
> OAuth, Users, Roles, SQL, NoSQL, BLOB Storage and External API Access
> Free app hosting. Or install the open source package on any LAMP server.
> Sign up and see examples for AngularJS, jQuery, Sencha Touch and Native!
> http://pubads.g.doubleclick.net/gampad/clk?id=63469471&iu=/4140/ostg.clktrk
> _______________________________________________
> Libtirpc-devel mailing list
> Libtirpc-devel@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/libtirpc-devel


--------------080809050607000506080304
Content-Type: text/x-patch;
 name="0001-__nc_error-does-not-check-return-value-from-malloc.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-__nc_error-does-not-check-return-value-from-malloc.patc";
 filename*1="h"

>From 72d43756f09599da9d0907c9f62c6a8e1e0cb261 Mon Sep 17 00:00:00 2001
From: Susant Sahani <ssahani@redhat.com>
Date: Tue, 19 Nov 2013 08:40:00 +0530
Subject: [PATCH] __nc_error() does not check return value from malloc

Signed-off-by: Susant Sahani <ssahani@redhat.com>
---
 src/getnetconfig.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/src/getnetconfig.c b/src/getnetconfig.c
index af4a484..2460a6e 100644
--- a/src/getnetconfig.c
+++ b/src/getnetconfig.c
@@ -146,7 +146,8 @@ __nc_error()
 			return (&nc_error);
 	}
 	if ((nc_addr = (int *)thr_getspecific(nc_key)) == NULL) {
-		nc_addr = (int *)malloc(sizeof (int));
+		if((nc_addr = (int *)malloc(sizeof (int))) == NULL)
+			return (&nc_error);
 		if (thr_setspecific(nc_key, (void *) nc_addr) != 0) {
 			if (nc_addr)
 				free(nc_addr);
-- 
1.8.4.2


--------------080809050607000506080304--

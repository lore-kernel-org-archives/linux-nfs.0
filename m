Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e23smtp08.au.ibm.com ([202.81.31.141]:34932 "EHLO
	e23smtp08.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751057Ab1F3Ndq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jun 2011 09:33:46 -0400
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp08.au.ibm.com (8.14.4/8.13.1) with ESMTP id p5UDSTWW018042
	for <linux-nfs@vger.kernel.org>; Thu, 30 Jun 2011 23:28:29 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p5UDWH12704638
	for <linux-nfs@vger.kernel.org>; Thu, 30 Jun 2011 23:32:17 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p5UDXace026456
	for <linux-nfs@vger.kernel.org>; Thu, 30 Jun 2011 23:33:37 +1000
Message-ID: <4E0C7B26.9030807@linux.vnet.ibm.com>
Date: Thu, 30 Jun 2011 19:03:26 +0530
From: faizan husain <faizanh@linux.vnet.ibm.com>
To: Jim Rees <rees@umich.edu>
CC: linux-nfs@vger.kernel.org, Frank S Filz <ffilz@us.ibm.com>,
        jvrao@linux.vnet.ibm.com
Subject: Re: [PATCH] nfs4-acl-tools : nfs4_setfacl' failed with unexpected
 messages if the format of the input file is incorrect.
References: <4E0AD278.3000503@linux.vnet.ibm.com> <20110629121854.GA5105@merit.edu> <4E0C1285.1060601@linux.vnet.ibm.com> <20110630115156.GA2347@merit.edu>
In-Reply-To: <20110630115156.GA2347@merit.edu>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thursday 30 June 2011 05:21 PM, Jim Rees wrote:
> faizan husain wrote:
>
>    problem was this part of code in parse_alloc_fields() function:
>    if (count != 3)
>             goto out_free;
>    at this point memory is not allocated for fields leading to double
>    free of memory once inside parse_alloc_fields() and again inside
>    nfs4_ace_from_string().
>
>    instead we can change the  code:
>    if (count != 3)
>        return -EINVAL; /*Invalid argument*/
>
>    This look to me as more foolproof solution.
>    what do you say?
>
> That looks correct.  It should return EINVAL here, and there is no need to
> free.  But I don't see why it fixes your segfault.  fields[] should be all
> NULL at this point, so free_fields shouldn't do anything.
>
> The test in free_fields() is redundant, since free(NULL) doesn't do
> anything.  But it could be made more foolproof by zeroing the array so you
> can't get a double free:
>
> void
> free_fields(char *fields[NUMFIELDS])
> {
> 	int i;
>
> 	for (i = 0; i<  NUMFIELDS; i++) {
> 		free(fields[i]);
> 		fields[i] = NULL;
> 	}
> }
yeah that could be done to make it more foolproof.
here is the final patch:

 From 6cd5263027e3fa5cf18756aa9db108dcdb2367d5 Mon Sep 17 00:00:00 2001
From: faizan <faizan.husain@in.ibm.com>
Date: Thu, 30 Jun 2011 18:55:28 +0530
Subject: [PATCH][BUILD]] FIX - 'nfs4_setfacl' failed with unexpected 
messages if
the format of the input file is incorrect.


Signed-off-by: faizan <faizan.husain@in.ibm.com>
---
  libnfs4acl/nfs4_ace_from_string.c |    9 +++++----
  1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/libnfs4acl/nfs4_ace_from_string.c 
b/libnfs4acl/nfs4_ace_from_string.c
index 9d877fb..b74b1a9 100644
--- a/libnfs4acl/nfs4_ace_from_string.c
+++ b/libnfs4acl/nfs4_ace_from_string.c
@@ -86,9 +86,10 @@ free_fields(char *fields[NUMFIELDS])
  {
         int i;

-       for (i = 0; i < NUMFIELDS; i++)
-               if (fields[i] != NULL)
-                       free(fields[i]);
+       for (i = 0; i < NUMFIELDS; i++) {
+               free(fields[i]);
+               fields[i] = NULL;
+       }
  }

  int
@@ -107,7 +108,7 @@ parse_alloc_fields(char *buf, char *fields[NUMFIELDS])
                         count++;
         }
         if (count != 3)
-               goto out_free;
+               return -EINVAL;

         for (i = 0; i < NUMFIELDS; i++) {
                 field = strsep(&buf, ":");
--
1.7.1

Thanks
Faizan

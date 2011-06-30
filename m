Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e23smtp08.au.ibm.com ([202.81.31.141]:48729 "EHLO
	e23smtp08.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752586Ab1F3GHO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jun 2011 02:07:14 -0400
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp08.au.ibm.com (8.14.4/8.13.1) with ESMTP id p5U61wjc016250
	for <linux-nfs@vger.kernel.org>; Thu, 30 Jun 2011 16:01:58 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p5U65tOZ1019922
	for <linux-nfs@vger.kernel.org>; Thu, 30 Jun 2011 16:05:55 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p5U675Oh017792
	for <linux-nfs@vger.kernel.org>; Thu, 30 Jun 2011 16:07:06 +1000
Message-ID: <4E0C1285.1060601@linux.vnet.ibm.com>
Date: Thu, 30 Jun 2011 11:37:01 +0530
From: faizan husain <faizanh@linux.vnet.ibm.com>
To: Jim Rees <rees@umich.edu>
CC: linux-nfs@vger.kernel.org, Frank S Filz <ffilz@us.ibm.com>,
        jvrao@linux.vnet.ibm.com
Subject: Re: [PATCH] nfs4-acl-tools : nfs4_setfacl' failed with unexpected
 messages if the format of the input file is incorrect.
References: <4E0AD278.3000503@linux.vnet.ibm.com> <20110629121854.GA5105@merit.edu>
In-Reply-To: <20110629121854.GA5105@merit.edu>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wednesday 29 June 2011 05:48 PM, Jim Rees wrote:
> faizan husain wrote:
>
>    On RHEL5.5 and above releases,
>    read ACL entries to set from file leads to a segmentation fault on pp64,
>    more over the same problem does not show up for x86_64 architecture.
>
> ...
>
>    diff --git a/libnfs4acl/nfs4_ace_from_string.c
>    b/libnfs4acl/nfs4_ace_from_string.c
>    index 9d877fb..1cc220e 100644
>    --- a/libnfs4acl/nfs4_ace_from_string.c
>    +++ b/libnfs4acl/nfs4_ace_from_string.c
>    @@ -125,7 +125,6 @@ parse_alloc_fields(char *buf, char *fields[NUMFIELDS])
>
>            return 0;
>     out_free:
>    -       free_fields(fields);
>            return -ENOMEM;
>     }
>
> If this fix is correct, shouldn't the name of the label be changed?  Better
> yet eliminate the gotos and label.
>
> However, I don't think the fix is correct.  I suspect you need a test for
> strsep() returning NULL.
I have tried strsep() returning NULL but without any success,
have figured out why double free error was coming leading to 
segmentation fault.

problem was this part of code in parse_alloc_fields() function:
if (count != 3)
          goto out_free;
at this point memory is not allocated for fields leading to double free 
of memory once inside parse_alloc_fields() and again inside 
nfs4_ace_from_string().

instead we can change the  code:
if (count != 3)
     return -EINVAL; /*Invalid argument*/

This look to me as more foolproof solution.
what do you say?

Signed-off-by: faizan <faizan.husain@.in.ibm.com>
---
  libnfs4acl/nfs4_ace_from_string.c |    2 +-
  1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libnfs4acl/nfs4_ace_from_string.c 
b/libnfs4acl/nfs4_ace_from_string.c
index 9d877fb..6f1e200 100644
--- a/libnfs4acl/nfs4_ace_from_string.c
+++ b/libnfs4acl/nfs4_ace_from_string.c
@@ -107,7 +107,7 @@ parse_alloc_fields(char *buf, char *fields[NUMFIELDS])
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



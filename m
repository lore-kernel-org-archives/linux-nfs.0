Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:42475 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751373Ab1GZR6n (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Jul 2011 13:58:43 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p6QHbPGT020334
	for <linux-nfs@vger.kernel.org>; Tue, 26 Jul 2011 13:37:25 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p6QHwgXJ134282
	for <linux-nfs@vger.kernel.org>; Tue, 26 Jul 2011 13:58:42 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p6QHwge7003619
	for <linux-nfs@vger.kernel.org>; Tue, 26 Jul 2011 13:58:42 -0400
Received: from malahal (malahal.beaverton.ibm.com [9.47.25.235])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id p6QHwfjX003381
	for <linux-nfs@vger.kernel.org>; Tue, 26 Jul 2011 13:58:41 -0400
Date: Tue, 26 Jul 2011 10:58:38 -0700
From: Malahal Naineni <malahal@us.ibm.com>
To: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] nfs4-acl-tools: Fix segfault if format of the
 input file is incorrect
Message-ID: <20110726175838.GA13663@us.ibm.com>
References: <1311280507-28957-1-git-send-email-malahal@us.ibm.com>
 <4E2E64AA.1090408@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E2E64AA.1090408@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Venkateswararao Jujjuri [jvrao@linux.vnet.ibm.com] wrote:
> 
> On 07/21/2011 01:35 PM, Malahal Naineni wrote:
> >The sizeof operator, when applied to a parameter declared to have array,
> >yields the size of the adjusted (pointer) type, even if the parameter
> >declaration specifies a length.
> >
> >---
> >  libnfs4acl/nfs4_ace_from_string.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> >
> >diff --git a/libnfs4acl/nfs4_ace_from_string.c b/libnfs4acl/nfs4_ace_from_string.c
> >index 9d877fb..462fcc0 100644
> >--- a/libnfs4acl/nfs4_ace_from_string.c
> >+++ b/libnfs4acl/nfs4_ace_from_string.c
> >@@ -100,7 +100,7 @@ parse_alloc_fields(char *buf, char *fields[NUMFIELDS])
> >  	if (!buf)
> >  		return -EINVAL;
> >
> >-	memset(fields, 0, sizeof(fields));
> >+	memset(fields, 0, sizeof(char *) * NUMFIELDS);
> >
> >  	for (i = 0; buf[i] != '\0'; i++) {
> >  		if (buf[i] == ':')
> 
> Could it be compiler specific? It is working fine for me
> 
> 
> Test]$ cat sizeof.c
> ===========
> #include <stdio.h>
> #define NUMFIELDS 10
> main()
> {
> 	char *fields1[NUMFIELDS];
> 	char fields2[NUMFIELDS];
> 
> 	printf("sizeof(fields1):%d sizeof(char *)*NUMFIELDS:%d\n",
> sizeof(fields1), sizeof(char *)*NUMFIELDS);
> 	printf("sizeof(fields2):%d sizeof(char)*NUMFIELDS:%d\n",
> sizeof(fields2), sizeof(char)*NUMFIELDS);
> }

It works as expected in the definition scope. It doesn't work "when
applied to a parameter declared to have array". It looks like, this is
part of the C99 spec, so can't be compiler specific. Try this:

static void fun(char *a[10])
{
 	printf("sizeof returned: %d\n", sizeof(a));
}

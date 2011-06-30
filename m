Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy02.merit.edu ([207.75.116.194]:44308 "EHLO
	merit-proxy02.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751587Ab1F3Lv7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jun 2011 07:51:59 -0400
Date: Thu, 30 Jun 2011 07:51:56 -0400
From: Jim Rees <rees@umich.edu>
To: faizan husain <faizanh@linux.vnet.ibm.com>
Cc: linux-nfs@vger.kernel.org, Frank S Filz <ffilz@us.ibm.com>,
        jvrao@linux.vnet.ibm.com
Subject: Re: [PATCH] nfs4-acl-tools : nfs4_setfacl' failed with unexpected
 messages if the format of the input file is incorrect.
Message-ID: <20110630115156.GA2347@merit.edu>
References: <4E0AD278.3000503@linux.vnet.ibm.com>
 <20110629121854.GA5105@merit.edu>
 <4E0C1285.1060601@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E0C1285.1060601@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

faizan husain wrote:

  problem was this part of code in parse_alloc_fields() function:
  if (count != 3)
           goto out_free;
  at this point memory is not allocated for fields leading to double
  free of memory once inside parse_alloc_fields() and again inside
  nfs4_ace_from_string().
  
  instead we can change the  code:
  if (count != 3)
      return -EINVAL; /*Invalid argument*/
  
  This look to me as more foolproof solution.
  what do you say?

That looks correct.  It should return EINVAL here, and there is no need to
free.  But I don't see why it fixes your segfault.  fields[] should be all
NULL at this point, so free_fields shouldn't do anything.

The test in free_fields() is redundant, since free(NULL) doesn't do
anything.  But it could be made more foolproof by zeroing the array so you
can't get a double free:

void
free_fields(char *fields[NUMFIELDS])
{
	int i;

	for (i = 0; i < NUMFIELDS; i++) {
		free(fields[i]);
		fields[i] = NULL;
	}
}

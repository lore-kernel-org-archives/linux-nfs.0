Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:59383 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751123Ab1F2MS6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Jun 2011 08:18:58 -0400
Date: Wed, 29 Jun 2011 08:18:54 -0400
From: Jim Rees <rees@umich.edu>
To: faizan husain <faizanh@linux.vnet.ibm.com>
Cc: linux-nfs@vger.kernel.org, Frank S Filz <ffilz@us.ibm.com>,
        jvrao@linux.vnet.ibm.com
Subject: Re: [PATCH] nfs4-acl-tools : nfs4_setfacl' failed with unexpected
 messages if the format of the input file is incorrect.
Message-ID: <20110629121854.GA5105@merit.edu>
References: <4E0AD278.3000503@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E0AD278.3000503@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

faizan husain wrote:

  On RHEL5.5 and above releases,
  read ACL entries to set from file leads to a segmentation fault on pp64,
  more over the same problem does not show up for x86_64 architecture.

...

  diff --git a/libnfs4acl/nfs4_ace_from_string.c
  b/libnfs4acl/nfs4_ace_from_string.c
  index 9d877fb..1cc220e 100644
  --- a/libnfs4acl/nfs4_ace_from_string.c
  +++ b/libnfs4acl/nfs4_ace_from_string.c
  @@ -125,7 +125,6 @@ parse_alloc_fields(char *buf, char *fields[NUMFIELDS])
  
          return 0;
   out_free:
  -       free_fields(fields);
          return -ENOMEM;
   }

If this fix is correct, shouldn't the name of the label be changed?  Better
yet eliminate the gotos and label.

However, I don't think the fix is correct.  I suspect you need a test for
strsep() returning NULL.

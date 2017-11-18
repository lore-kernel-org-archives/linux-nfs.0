Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:34377 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1423317AbdKRScS (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 18 Nov 2017 13:32:18 -0500
Subject: Re: Commit fcd8843c40 breaks old compilers
To: Trond Myklebust <trondmy@primarydata.com>,
        "Anna.Schumaker@Netapp.com" <Anna.Schumaker@Netapp.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
References: <09a3d9ca-d191-5899-613d-8d0dbe0b68ea@oracle.com>
 <1511026783.10238.2.camel@primarydata.com>
 <49fec52f-229a-4657-a80d-d1a40a9d38e4@oracle.com>
 <1511028750.14386.1.camel@primarydata.com>
From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Message-ID: <cce6f1be-0481-4ecc-85e2-a626cf381ce3@oracle.com>
Date: Sat, 18 Nov 2017 13:32:09 -0500
MIME-Version: 1.0
In-Reply-To: <1511028750.14386.1.camel@primarydata.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/18/2017 01:12 PM, Trond Myklebust wrote:

> 
> Sigh.... OK, how about something like the following then:
> 
> { .data = { 0xff, 0xff, 0xff, 0xff, 0 }, }
> 


Yes, this does build.


diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 54fd56d..daa6085 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -71,8 +71,7 @@
  };
  const nfs4_stateid invalid_stateid = {
         {
-               .seqid = cpu_to_be32(0xffffffffU),
-               .other = { 0 },
+               .data = { 0xff, 0xff, 0xff, 0xff, 0 },
         },
         .type = NFS4_INVALID_STATEID_TYPE,
  };


-boris

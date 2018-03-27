Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-db5eur01on0101.outbound.protection.outlook.com ([104.47.2.101]:11292
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751070AbeC0WG0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 27 Mar 2018 18:06:26 -0400
Date: Tue, 27 Mar 2018 23:06:14 +0100 (BST)
From: Michael Young <m.a.young@durham.ac.uk>
To: Eric Biggers <ebiggers@google.com>,
        Herbert Xu <herbert@gondor.apana.org.au>
cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: NFS mounts failing when keytab present on client
Message-ID: <alpine.LFD.2.21.1803272126070.3013@austen3.home>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFS mounts stopped working on one of my computers after a kernel update 
from 4.15.3 to 4.15.4. I traced the problem to the commit
[46e8d06e423c4f35eac7a8b677b713b3ec9b0684] crypto: hash - prevent using 
keyed hashes without setting key
and a later kernel with this patch reverted works normally.

The problem seems to be related to kerberos as the mount fails when the 
keytab is present, but works if I rename the keytab file. This is true 
even though the mount is with sec=sys . The mount should also work with 
sec=krb5 but that also fails in the same way. When the mount fails there 
are errors in dmesg like
[ 1232.522816] gss_marshal: gss_get_mic FAILED (851968)
[ 1232.522819] RPC: couldn't encode RPC header, exit EIO
[ 1232.522856] gss_marshal: gss_get_mic FAILED (851968)
[ 1232.522857] RPC: couldn't encode RPC header, exit EIO
[ 1232.522863] NFS: nfs4_discover_server_trunking unhandled error -5. 
Exiting with error EIO
[ 1232.525039] gss_marshal: gss_get_mic FAILED (851968)
[ 1232.525042] RPC: couldn't encode RPC header, exit EIO

 	Michael Young

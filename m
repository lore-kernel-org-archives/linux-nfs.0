Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:31463 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750969AbcHXSLN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Aug 2016 14:11:13 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=us-ascii
Subject: READ during state recovery uses zero stateid
Date: Wed, 24 Aug 2016 14:10:30 -0400
Message-Id: <AB29A5B8-1564-4C31-A843-F0C5CC4C91F1@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Trond Myklebust <trondmy@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi-

I have a wire capture that shows this race while a simple I/O workload is
running:

0. The client reconnects after a network partition
1. The client sends a couple of READ requests
2. The client independently discovers its lease has expired
3. The client establishes a fresh lease
4. The client destroys open, lock, and delegation stateids for the file
that was open under the previous lease
5. The client issues a new OPEN to recover state for that file
6. The server replies to the READs in step 1. with NFS4ERR_EXPIRED
7. The client turns the READs around immediately using the current open
stateid for that file, which is the zero stateid
8. The server replies NFS4_OK to the OPEN from step 5

If I understand the code correctly, if the server happened to send those
READ replies after its OPEN reply (rather than before), the client would
have used the recovered open stateid instead of the zero stateid when
resending the READ requests.

Would it be better if the client recognized there is state recovery in
progress, and then waited for recovery to complete, before retrying the
READs?


--
Chuck Lever




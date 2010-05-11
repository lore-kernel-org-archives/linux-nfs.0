From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: [Fwd: newpynfs: compound test 6 fails]
Date: Tue, 11 May 2010 13:43:42 -0400
Message-ID: <1273599822.2810.6.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Vikas Chhabra <Vikas.Chhabra-IdkZ5yI5K0tWk0Htik3J/w@public.gmane.org>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:36195 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752347Ab0EKRnr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 May 2010 13:43:47 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Forwarding to the NFS mailing list...

-------- Forwarded Message --------
From: Vikas Chhabra <Vikas.Chhabra-IdkZ5yI5K0tWk0Htik3J/w@public.gmane.org>
To: mailman-owner@linux-nfs.org
Subject: newpynfs: compound test 6 fails
Date: Tue, 11 May 2010 10:48:31 +0530

On Linux nfsv4 while executing newpynfs test suite COMP6 (testLongCompound) fails with following error:
COMP6   st_compound.testLongCompound                             : FAILURE
        COMPOUND with len=150 argarry got RPCError:
        MSG_ACCEPTED: GARBAGE_ARGS, expected NFS4ERR_RESOURCE
 
 

Could you please advice whether this could be a bug with Linux nfsv4
implementation or does it look to be an issue with newpynfs test suite
itself?

 

Thanks in advance!!! Anticipating a quick help in this regard.

 

-Vikas Chhabra

 





Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:34227 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751710Ab2KPLZ4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Nov 2012 06:25:56 -0500
Message-ID: <50A622AE.3080809@parallels.com>
Date: Fri, 16 Nov 2012 15:25:34 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "bfields@fieldses.org" <bfields@fieldses.org>,
        Jeff Layton <jlayton@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: NFSd state: nfs4_lock_state() and nfs4_lock_state()
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello, guys.
Right now I'm looking how client_mutex can be containerised.
And it looks like this mutex is too widely used. And I can't get what it 
protects exactly.

I'd like to hear your opinions about the following:
1) Why do we need to use this mutex in nfsd4_load_reboot_recovery_data()? This 
function is called only once on NFS server start before launching kthreads.

2) Look like using of this mutex can be easely moved out from read, write and 
setattr functions in nfs4proc.c to nfs4_preprocess_stateid_op() in nfs4state.c. 
It it also could be removed from nfs4_open(), then nfs4_lock_state() and 
nfs4_lock_state() can become static.

So the question is: why this mutex covers that much different code in 
nfsd4_open() call?

-- 
Best regards,
Stanislav Kinsbursky

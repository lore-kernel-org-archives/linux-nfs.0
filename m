Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:49910 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755135Ab2K1RNb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Nov 2012 12:13:31 -0500
Message-ID: <50B64628.4070007@parallels.com>
Date: Wed, 28 Nov 2012 21:13:12 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "bfields@fieldses.org" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Jeff Layton <jlayton@redhat.com>,
        "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>
Subject: NFSd in container - it works
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi.
I have about ~10 more patches, which makes NFS server works in container (mnt + pid + net namesapces). And it passes basic tests.
But there are some issues I would like to discuss:
1) NFSd threads are running in init_pid namespace. This makes impossible to stop NFS server by signals from container. Also is makes possible to stop and 
destroy container without stopping its NFS server (network namespace thus will stay alive). So, there should be implemented some way to destroy these threads, 
when container's child reaper is exiting.
2) We need to solve this issue with registering in wrong portmapper. Sync connects suits both Lockd and NFSd. Bruce, what about gss daemon? Maybe some other 
socket (abstract UNIX or loopback) can be used instead? Or PipeFS?
3) Holding net by tracker looks redundant. What was the reason for this?

-- 
Best regards,
Stanislav Kinsbursky

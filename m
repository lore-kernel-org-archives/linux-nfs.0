Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx.nrchpc.ac.cn ([211.103.180.228]:46745 "EHLO mx.bwstor.cn"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751253AbaAOIfi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Jan 2014 03:35:38 -0500
Received: from localhost (localhost [127.0.0.1])
	by mx.bwstor.cn (Postfix) with ESMTP id BC3C2668FE
	for <linux-nfs@vger.kernel.org>; Wed, 15 Jan 2014 16:35:20 +0800 (CST)
Received: from mx.bwstor.cn ([127.0.0.1])
	by localhost (mx1.bwstor.com.cn [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id EIDF80hMJEdE for <linux-nfs@vger.kernel.org>;
	Wed, 15 Jan 2014 16:35:20 +0800 (CST)
Received: from linux-odmv (unknown [10.10.37.58])
	by mx.bwstor.cn (Postfix) with ESMTPA id 9B82A668FA
	for <linux-nfs@vger.kernel.org>; Wed, 15 Jan 2014 16:35:20 +0800 (CST)
Date: Wed, 15 Jan 2014 16:34:53 +0800
From: shaobingqing@bwstor.com.cn
To: linux-nfs@vger.kernel.org
Subject: What caused the rpc_rqst unable to be obtained in
 xs_tcp_read_callback?
Message-ID: <52d6482d.9uhxuyZrGvlNd2GD%shaobingqing@bwstor.com.cn>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In the function xs_tcp_read_callback, when the rpc_rqst are 
unable to be obtained, the connection will be closed and the
system will give a KERN_WARNING "Callback slot table overflowed".
We know that although there is only one rpc_rqst is prealloced,
metadata server cannot send two or more callback requests to one
client at the  same time, because there is only one slot on the
metadate server for the client.

Now, in my test, the KERN_WARNING "Callback slot table overflowed"
always occurs. So, I want to know that what caused the rpc_rqst
unable to be obtained. Maybe there are retransmissions in the systems. 

Are there anybody can expain the reason for us? 

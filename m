From: Olga Kornievskaia <aglo@citi.umich.edu>
Subject: size of nfsv4 writes
Date: Wed, 04 Jun 2008 12:40:38 -0400
Message-ID: <4846C586.1050000@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
	Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:20373 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751283AbYFDQkk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Jun 2008 12:40:40 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


While testing NFSv4 performance over the 10GE network, we are seeing the 
following behavior and would like to know if it is normal or a bug in 
the client code.

The server offers the max_write of 1M. The client mounts the server with 
the "wsize" option of 1M. Yet during the write we are seeing that the 
write size is at most 49K. Why does client never come close to 1M limit?

Thanks.

-Olga

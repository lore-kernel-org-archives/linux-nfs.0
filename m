From: Chuck Lever <chuck.lever@oracle.com>
Subject: nfs_utils: O_NONBLOCK sockets in support/nfs/svc_socket.c
Date: Thu, 7 Aug 2008 15:58:09 -0400
Message-ID: <F9B1C837-2779-4E81-83DF-139BBAEFD32B@oracle.com>
Mime-Version: 1.0 (Apple Message framework v928.1)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Neil Brown <neilb@suse.de>, Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet02.oracle.com ([141.146.126.229]:43382 "EHLO
	agminet02.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752858AbYHGVGb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Aug 2008 17:06:31 -0400
Received: from agminet01.oracle.com (agminet01.oracle.com [141.146.126.228])
	by agminet02.oracle.com (Switch-3.2.4/Switch-3.1.7) with ESMTP id m77K3AKC002609
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Thu, 7 Aug 2008 15:03:10 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi guys-

I'm looking at svc_socket() and friends to add IPv6 support.  Got a  
question.

I see in commits 11d34d11 and 58e58ffb there was a set of fcntl()  
calls added to make RPC service listener sockets non-blocking.

How come this support wasn't added in support/nfs/rpcmisc.c:makesock()  
as well?

I'm probably misreading the logic in rpc_init(), but it seems to me  
there are possibilities for the listener socket to be created by  
makesock() and not by svc_socket(), and then that listener would not  
be O_NONBLOCK.  For instance, if there was a port value specified on  
the mountd command line...?

Please straighten me out.  Thanks.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com

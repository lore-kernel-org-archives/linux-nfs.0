From: Chuck Lever <chuck.lever@oracle.com>
Subject: use of non-privileged ports for MNT and NLM
Date: Tue, 19 Aug 2008 17:14:54 -0400
Message-ID: <0CD0CE08-CB11-419A-9AAC-DEB1AC2B26B3@oracle.com>
Mime-Version: 1.0 (Apple Message framework v928.1)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
	Bruce Fields <bfields@citi.umich.edu>,
	Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:19865 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751830AbYHSVPn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Aug 2008 17:15:43 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Working on "resvport" mount option.  Question occurred to me:

If I specify "noresvport" on a mount, can the client also use a non- 
privileged port for the initial MNT request, and can it use it for the  
NLM connection as well?

Question applies not just to Linux servers, but servers in general.   
Brief searching on teh internets does not reveal a quick answer.  I  
think rpc.mountd will allow a non-privileged port for "insecure"  
exports.

I think the answer is "yes, non-privileged ports can be used for MNT  
and NLM if the server explicitly allows it" but I thought I would open  
this up to the list.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com

From: Mi Jinlong <mijinlong@cn.fujitsu.com>
Subject: [RFC] NLM server can not process retransmited request correctly
Date: Mon, 02 Nov 2009 17:28:02 +0800
Message-ID: <4AEEA622.6000705@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: NFSv3 list <linux-nfs@vger.kernel.org>, bfields@fieldses.org,
	mingo@elte.hu
To: "Trond.Myklebust" <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:55559 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754114AbZKBJ22 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Nov 2009 04:28:28 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond et al:

When i test the nfslock of NFSv3 at RHEL5.3GA (kernel: 2.6.18-128.el5),
NLM server can not process client's retransmited request correctly.

Steps of my test likes followed:
           client                          server
             |                                |
      step1  |           open file            |
      open   |------------------------------->|
             |              ok                |
             |<-------------------------------|
             |                                | step2
             |                             -> | <-  service nfslock stop
             |                                |
      step3  | WL1: write lock request{0, 0}  |
      fcntl  |------------------------------->|
             |                                |
             |    WL1_re: WL1 retransmit      |
             |------------------------------->|
             |                                |
             |       WL1.reply   ENOLCK       |
             |<-------------------------------|
             |                                | step4
             |                             -> | <- service nfslock start
             |                                |
      step5  | WL2: write lock request{0, 0}  |
      fcntl  |------------------------------->|
             |                                |
             |        WL1_re.reply OK         |
             |<-------------------------------|
             |       WL2.reply EBLOCKD        |
             |<-------------------------------|
             V                                V

   Client can not acquire for write lock any more after step4.

Reason:
   Server reply ENOLCK for WL1 to client because nfslock service stoped,
   but it can not distinguish retransmited request with normal request, 
   so it reply OK for WL1_re to client after nfslock service start. But 
   fcntl client called will return when it receive WL1.reply, WL1_re.reply
   will be droped at Client. So that, the lock between client and server
   is different. When client send a some lock request to server again,
   it will get a EBLOCKD error from Server.

Suggestion:
   1. I suggest add an DRC(Duplicate request cache) for NLM.
      Because, as mentioned above, when a client send a lock request to 
      server through NLM. If server isn't reply in time, a retransmit 
      request will be send from client. 

      Maybe the retransmit request will get different reply from server
      as the lock request, the lock between client and server will different.
      So that, the DRC for NLM is necessary.

      What's your opinion ?

   2. If everybody thinks it's necessary to add it, here is some ideas in
      my opinion and some patchs implement at 2.6.32-rc5:

      a. Because the implement of NLM's DRC is same as NFS's DRC almost,
         many codes will be repeated.
         I think, could we implement a common DRC for sunrpc?
         NLM and NFS will use this DRC.

         Do you have some good ideas ?

      b. A brief description of the patch at the reply:

         [0001-Add-a-common-DRC-for-sunrpc.patch]
         Add a common DRC for sunrpc, NLM and NFS implement their DRC using it.

         [0002-Add-DRC-for-NLM-using-sunrpc-s-common-DRC.patch]
         [0003-Modify-nfs-s-DRC-to-use-sunrpc-s-common-DRC.patch]

         Particular description will be implement at corresponding patch.

Waiting for your reply ...... 

thanks,

Mi Jinlong



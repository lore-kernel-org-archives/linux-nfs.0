From: Mi Jinlong <mijinlong@cn.fujitsu.com>
Subject: [RFC] When locking an inexistent file, NFSv3 and NFSv4 get different
 result.
Date: Tue, 20 Oct 2009 17:06:23 +0800
Message-ID: <4ADD7D8F.1040700@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: NFSv3 community <linux-nfs@vger.kernel.org>, mingo@elte.hu,
	bfields@fieldses.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:50641 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751481AbZJTJF1 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Oct 2009 05:05:27 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


When locking an inexistent file, NFSv3 and NFSv4 get different result.

A: Test procedure=EF=BC=9A

         Client              Server
       ---------------+----------------
step1:  open file     |
step2:                |   delete file
step3:  lock file     |
step4:  close file    |
                      V

   On NFSv3: lock file fail, and return ESTALE at step3.
   On NFSv4: lock file success, and return OK at step3.

B: Reason:

   NFSv4 server open file when client open the file at step1.
         so it can lock file success at step3.
   NFSv3 server don't open file when client open the file at step1,
         but open file at step3, so lock fail caused by open file fail.

C: Suggestion:

   I suggest modifying the NFSv3 to accordding with NFSv4. As followed:

   1. Add two NLMPROCs for nlm.

      NLMPROC_OPEN:  client sent it to server, and server open file
      NLMPROC_CLOSE: client sent it to server, and server close file

   2.=20
     If use NLM, client send NLMPROC_OPEN request to server when client=
 open file,
     and send NLMPROC_CLOSE request when client close file.

            client                  server
              |   nfs.lookup request   |
         Open |----------------------->|
              |    nfs.lookup reply    |
              |<-----------------------|
              |                        |
              |  NLMPROC_OPEN request  |
              |----------------------->| open file and add it to nlm_fi=
les list
              |   NLMPROC_OPEN reply   | =20
              |<-----------------------|
              |                        |
        Lock  |  NMLPROC_LOCK request  |
              |----------------------->| use the file opened before=20
              |   NMLPROC_LOCK reply   |
              |<-----------------------|
              |                        |
        Close |  NMLPROC_CLOSE request |
              |----------------------->| remove the file from nlm_files=
 list
              |   NMLPROC_CLOSE reply  |
              |<-----------------------|
              V                        V

--=20
Regards
Mi Jinlong


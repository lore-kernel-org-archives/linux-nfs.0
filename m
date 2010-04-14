From: Mi Jinlong <mijinlong@cn.fujitsu.com>
Subject: [RFC] After sending NLM request, client don't wait reply, instead
 send FIN
Date: Wed, 14 Apr 2010 18:19:36 +0800
Message-ID: <4BC596B8.2020808@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: NFSv3 list <linux-nfs@vger.kernel.org>,
	"Trond.Myklebust" <trond.myklebust@fys.uio.no>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:62463 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754216Ab0DNKRf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Apr 2010 06:17:35 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all, 

When testing NFSv3's lock service at RHEL with kernel 2.6.31, I get a 
strange result like that: client send NLM request success, but don't 
wait reply, instead send FIN request; server receive NLM request success,
but don't replay.

Test process:

             client                         server
 1. mount -t nfs host:/tmp /mnt (OK)
 2.       open file             (OK)
 3.       lock file             (OK)
 4.       unlokc file           (OK)
 5.                                      service nfs stop (OK)
 6.       lock file again      (hang)

 7.             <-----------   waiting 170s   ------------> 
 8.                                      service nfs start (OK)
 9.       step6's lock return -88

 And, I get the tcpdump as below:
    a. step1 ~ step4: It's regular;
    b. step5 ~ step8: client send portmap request, and get PROGRAM_NOT_AVAILABLE
                      error reply.
    c. step8 ~ step9: (the important part)
                 c.1: portmap success.
                 c.2: <NLM>
                      client  -------- SYN ---------> server 
                              <------- SYN ACK-------
                              -------- ACK --------->
                              ------ LOCK CALL ----->
                              <-------- ACK ---------
                              ------- FIN ACK ------>
                              <------ FIN ACK -------
                              --------- ACK -------->

                c.3: client's user space get error -88(Socket operation on non-socket).

 Question:
   1. c.3, user space get error -88, the LOCK request should not send success, 
      but as c.2 show, the client's LOCK request have send success.
      Is there some reason ?

   2. When traceing the kernel, I find kernel send two LOCK request at step8~9,
      the first one send success(but can't get reply), the second one send fail 
      with error -88.
      IMO, at step8~9, after server's nfs start, and client get portmap success,
      there will be only one LOCK request task at client's kernel, and send only 
      one LOCK request.
      What cause client send two LOCK request ?

  Waiting for your reply.

thanks,
Mi Jinlong


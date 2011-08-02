Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from snt0-omc3-s31.snt0.hotmail.com ([65.55.90.170]:52749 "EHLO
	snt0-omc3-s31.snt0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753027Ab1HBOwK convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Aug 2011 10:52:10 -0400
Message-ID: <SNT124-W64CD9D41C92B91E501D45BF73B0@phx.gbl>
From: Mrbuddy <buddy_sz@hotmail.com>
To: <linux-nfs@vger.kernel.org>
Subject: A error about stat
Date: Tue, 2 Aug 2011 14:52:09 +0000
Content-Type: text/plain; charset="iso-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


    After I use open(TESTFILE,O_RDWR | O_CREAT,0644),and then close it, then I get gid and uid,I found that the uid and gid is -2.But after 3S, I can get the right uid and gid.     The reason is that when opening a file,we can get the right uid andgid.but after decode,we lost it and the client set the value to 2. whenclosing it,we also get the stat info,but only fo size,ctime and mtime.After 3s,local attribute become invalidated,and then ge the stat from disk.    In order to resolver that problem,I made a change innfs4_xdr_dec_open();
change
if(decode_getfatr(&xdr,res->f_attr,res->server,!RPC_IS_ASYNC(rqstp->rq_task))!=0)
to
if(decode_getfatr(&xdr,res->f_attr,res->server,1) 		 	   		  
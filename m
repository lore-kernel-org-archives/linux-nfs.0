Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mho-02-ewr.mailhop.org ([204.13.248.72]:23278 "EHLO
	mho-02-ewr.mailhop.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752558Ab3JLR1s (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 12 Oct 2013 13:27:48 -0400
Received: from [98.156.78.19] (helo=portal.home.hanaden.com)
	by mho-02-ewr.mailhop.org with esmtpsa (TLSv1:AES128-SHA:128)
	(Exim 4.72)
	(envelope-from <hanasaki@hanaden.com>)
	id 1VV2yh-000DQv-Ef
	for linux-nfs@vger.kernel.org; Sat, 12 Oct 2013 17:27:47 +0000
Received: from russia.home.hanaden.com ([10.1.1.30])
	by portal.home.hanaden.com with esmtps (TLS1.0:DHE_RSA_CAMELLIA_256_CBC_SHA1:256)
	(Exim 4.80)
	(envelope-from <hanasaki@hanaden.com>)
	id 1VV2yc-0004Jt-QI
	for linux-nfs@vger.kernel.org; Sat, 12 Oct 2013 12:27:46 -0500
Message-ID: <52598677.1000708@hanaden.com>
Date: Sat, 12 Oct 2013 12:27:19 -0500
From: hanasaki <hanasaki@hanaden.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Subject: nfs RPC: AUTH_GSS upcall timed out and running nfs v4 without full
 kerberos : how?
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

1. Below appears to require krb for auth.  Is this correct?  How can nfs 
v4 be setup and used over tcp? udp? and not require a full kerberos 
server setup?

2. The stat issue is ok.  It takes a long time to timeout which is 
causing problems.  Using the full directory path locally on the nfs 
server works ok without stat issue or long timeouts.

3. the user daemon does appear to be running fine.

Oct 12 00:49:07 host-01 kernel: [ 1775.106615] RPC: AUTH_GSS upcall 
timed out.
Oct 12 00:49:07 host-01 kernel: [ 1775.106615] Please check user daemon
is running.
Oct 12 00:49:07 host-01 rpc.mountd[3097]: authenticated mount request
from 10.1.1.30:762 for /storage/data-01/dist-export/pom.xml
(/storage/data-01)
Oct 12 00:49:07 host-01 rpc.mountd[3097]: can't stat exported dir
/storage/data-01/dist-export/pom.xml: No such file or directory

linux-nfs@vger.kernel.org

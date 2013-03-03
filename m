Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 77-175-125-29.FTTH.ispfabriek.nl ([77.175.29.125]:52004 "EHLO
	srv2.net.home" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750846Ab3CCG5e (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 3 Mar 2013 01:57:34 -0500
Received: from localhost (localhost [127.0.0.1])
	by srv2.net.home (Postfix) with ESMTP id 78C65B2675
	for <linux-nfs@vger.kernel.org>; Sun,  3 Mar 2013 07:50:29 +0100 (CET)
Received: from srv2.net.home ([127.0.0.1])
	by localhost (webmail.net.home [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id u9EHMdGl9lbg for <linux-nfs@vger.kernel.org>;
	Sun,  3 Mar 2013 07:50:29 +0100 (CET)
Received: from [192.168.1.2] (vovan.net.home [192.168.1.2])
	(Authenticated sender: vovan)
	by srv2.net.home (Postfix) with ESMTPSA id 33E90B266F
	for <linux-nfs@vger.kernel.org>; Sun,  3 Mar 2013 07:50:29 +0100 (CET)
Message-ID: <5132F2B4.3070105@net.home>
Date: Sun, 03 Mar 2013 07:50:28 +0100
From: Vlad <vovan@vovan.nl>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: NFS3/kerberos/ACL - strange problem
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

Recently I've discovered quite strange issue with nfs v3 and ACL's.
While on the clients without updates everything works as expected, on
the clients with recent updates ACL's simply don't work:
- "ls" gives "Permission denied" error on folders with ACL's
- getfacl gives the same "permission denied" error
- on kerberos server I see strange errors while executing "ls" on the
client:
krb5kdc[2661]: TGS_REQ (4 etypes {18 17 16 23}) 192.168.1.2:
UNKNOWN_SERVER: authtime 0,  xxx@NET.HOME for
nfsacl/nfs.net.home@NET.HOME, Server not found in Kerberos database


I can track what has been updated but the list is too long... I'd
appreciate any thoughts on this issue.

Regards,
Vlad.

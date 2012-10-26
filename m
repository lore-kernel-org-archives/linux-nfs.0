Return-Path: linux-nfs-owner@vger.kernel.org
Received: from c2bthomr07.btconnect.com ([213.123.20.125]:41789 "EHLO
	mail.btconnect.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751756Ab2JYXi5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Oct 2012 19:38:57 -0400
From: "lux-integ" <lux-integ@btconnect.com>
To: linux-nfs@vger.kernel.org
Subject: nfs-utils, --enable-gss   librpcsecgss.so glitch
Date: Fri, 26 Oct 2012 02:34:04 +0100
MIME-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Message-Id: <201210260234.04247.lux-integ@btconnect.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Greetings,

I hope I am posting to the right list.  

I am trying to compile nfs-utils  on a cblfs setup  with (
gcc-4.6.3, 
 linx-3.6.3, 
kerberos-10.3
as well as 
librpcsecgss-0.19 and
libgssglue-0.4 )


I tried  nfs-utils 1.2.5, 1.2.6. and r.1.2.7rc7  In all  instances  

 with the --disable-gss ,  compilation sicceeds 
BUT
with --enable-gss (the default)
make ends like so.
#########
/usr/lib/librpcsecgss.so: undefined reference to `__rpc_thread_svc_fdset'
collect2: ld returned 1 exit status
make[2]: *** [gssd] Error 1
########

The thing is, I want the gss feature  for an NFSv4 setup.

I have successfully compiled earlier versions of nfs-utils   on hosts  with 
earlier versions of kerberos, librpcsecgss-and libgssglue

I would be grateful for advice concerning  the current setup and result(s)

sincerely
lux-integ

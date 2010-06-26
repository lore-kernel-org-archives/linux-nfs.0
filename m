From: "Henry Shao" <hshao-oSioyQM9ZPnuBjGU1YDckgC/G2K4zDHf@public.gmane.org>
Subject: About configure error
Date: Sat, 26 Jun 2010 12:37:09 -0700
Message-ID: <74B0AE1BA53C37449DE49BB274F9A2DB2B3DA2@orion8.netlogicmicro.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: <chuck.lever@oracle.com>, <steved@redhat.com>
To: <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.netlogicmicro.com ([12.49.93.86]:1970 "EHLO
	orion5.netlogicmicro.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756447Ab0GQScB convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 17 Jul 2010 14:32:01 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Hi Sir:

    I try to compile nfs-utils-1.2.2 for our mips64 platform using cross compiler.  I keek get configure error:
checking for clnt_tli_create in -ltirpc... no
configure: error: libtirpc not found.

     Then I download libtirpc  and compile it successfully and install it in  ../lib directory.   I try to use LIBS or exec_prefix ... to pass it in.   It did not successful.   Still keeping get this error.

     Do you mind to tell me how can I pass this error and get it compiled for our mips target?

    Thank you very much!



# CC=mipsisa64r2rmi-linux-gcc ./configure --host=mips-linux --disable-gss --disable-nfsv4


Henry Shao

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:45787 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753689Ab1ILWfI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Sep 2011 18:35:08 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1R3F5m-0006a3-PE
	for linux-nfs@vger.kernel.org; Tue, 13 Sep 2011 00:35:06 +0200
Received: from 89-201-186-203.dsl.optinet.hr ([89.201.186.203])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Tue, 13 Sep 2011 00:35:06 +0200
Received: from vedran.furac by 89-201-186-203.dsl.optinet.hr with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Tue, 13 Sep 2011 00:35:06 +0200
To: linux-nfs@vger.kernel.org
From: =?UTF-8?B?VmVkcmFuIEZ1cmHEjQ==?= <vedran.furac@gmail.com>
Subject: Error: state manager failed on NFSv4 server foo with error 13
Date: Tue, 13 Sep 2011 00:31:19 +0200
Message-ID: <j4m17n$l37$1@dough.gmane.org>
Reply-To: vedran.furac@gmail.com
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi all,

I've recently upgraded nfs mounts from nfs3 to nfs4 and now I often have:

Error: state manager failed on NFSv4 server foo with error 13

in logs. Error 13 is NFS4ERR_ACCESS Permission denied: The caller does
not have the correct permission to perform the requested operation.

Client machines run Debian Lenny. I don't use Kerberos. Could you give
me suggestions on how to debug this issue or resolve it.

Thanks,
Vedran


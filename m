From: "Payphone LIOU" <lioupayphone@gmail.com>
Subject: may be a bug?
Date: Thu, 28 Aug 2008 16:52:58 +0800
Message-ID: <200808281652540341291@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="gb2312"
To: "linux-nfs" <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.187]:17502 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751009AbYH1IxE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Aug 2008 04:53:04 -0400
Received: by ti-out-0910.google.com with SMTP id b6so176009tic.23
        for <linux-nfs@vger.kernel.org>; Thu, 28 Aug 2008 01:53:02 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi, ALL.

in moutd.h of nfs-utils-1.1.3, an union object was defined  below.
union mountd_results {
	fhstatus		fstatus;
	mountlist		mountlist;
	exports			exports;
};

the space size of mountd_results is the maximum one among fsstaus,mountlist and exports, and all of them are the output arguments of mountd procedures.
in nfsv3, mount_mnt_3_svc takes "mountres3" as its output. so i think it may be :

union mountd_results {
	fhstatus		fstatus;
	mountlist		mountlist;
	exports			exports;
	mountres3    mountres3;
};

because the size of fstatus is larger than mountres3, no erros happens. but i think semantically  "mountres3" should be added into this union structure. am i wrong?

thansk a lot.

Best regards. :-)

Payphone LIOU 


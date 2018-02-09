Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50568 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751034AbeBIPuo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 9 Feb 2018 10:50:44 -0500
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 8960E3D945
        for <linux-nfs@vger.kernel.org>; Fri,  9 Feb 2018 15:50:44 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-116-113.phx2.redhat.com [10.3.116.113])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 3D5B1608FA
        for <linux-nfs@vger.kernel.org>; Fri,  9 Feb 2018 15:50:44 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/1] Eliminate warnings from rpcgen generated code
Date: Fri,  9 Feb 2018 10:50:41 -0500
Message-Id: <20180209155042.28461-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For years, the rpcgen generated code causes 
a number of -Wunused-variable. Taking a closer
look at rpcgen , it turns out these warnings 
were caused by rpcgen trying inline the code.

Inlining is a technique that allows xdr routines
to run faster and more efficiently. It turns out
only one routine, xdr_ppathcnf(), was taking 
advantage of this technique. 

So by turning off rpcgen inline the warnings 
are eliminated with no lost of speed or efficiency

The patch also eliminates a -Wmissing-prototypes
by a hack to the nsm/Makefile.am.

Steve Dickson (1):
  Remove warnings from rpcgen genrated files

 support/export/Makefile.am | 2 +-
 support/nsm/Makefile.am    | 3 ++-
 2 files changed, 3 insertions(+), 2 deletions(-)

-- 
2.14.3


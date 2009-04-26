From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH 3/11] nfsd: CHANGE old function calls to new calls
Date: Sun, 26 Apr 2009 16:46:50 +0530
Message-ID: <OF9FC3EADE.4D0D6832-ON652575A4.003DB62E-652575A4.003DF752@in.ibm.com>
References: <20090325133607.16437.33288.sendpatchset@localhost.localdomain> <20090325133707.16437.66360.sendpatchset@localhost.localdomain> <20090422200553.GH9541@fieldses.org> <OFB63DF5D6.1A77785C-ON652575A1.004F6726-652575A1.00577C61@in.ibm.com> <20090423223909.GF1906@fieldses.org> <OFC1241E6B.C4476A61-ON652575A2.00207885-652575A2.00598912@in.ibm.com> <20090424162321.GB17365@fieldses.org> <OFBB4FF305.DD2B4946-ON652575A2.005CB412-652575A2.005D3AC2@in.ibm.com> <20090424192506.GQ17365@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Greg Banks <gnb-xTcybq6BZ68@public.gmane.org>, jlayton@redhat.com,
	Krishna Kumar <krikku@gmail.com>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e28smtp09.in.ibm.com ([59.145.155.9]:52639 "EHLO
	e28smtp09.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751159AbZDZLRQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 26 Apr 2009 07:17:16 -0400
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp09.in.ibm.com (8.13.1/8.13.1) with ESMTP id n3QAggla030354
	for <linux-nfs@vger.kernel.org>; Sun, 26 Apr 2009 16:12:42 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3QBH9EP622658
	for <linux-nfs@vger.kernel.org>; Sun, 26 Apr 2009 16:47:09 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id n3QBH8Jq027738
	for <linux-nfs@vger.kernel.org>; Sun, 26 Apr 2009 16:47:08 +0530
In-Reply-To: <20090424192506.GQ17365@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

"J. Bruce Fields" <bfields@fieldses.org> wrote on 04/25/2009 12:55:06 AM:

> Why not use the whole thing?:
>
>    fh1->fh_size == fh2->fh_size
>       && memcmp(fh1->fh_base, fh2->fh_base, fh1->fh_size) == 0

OK - so I just add a knfsd_fh in the cache and compare fh's. That
sounds good, let me test and see what is the result.

thanks,

- KK


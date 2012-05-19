Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.14.82]:33045 "EHLO
	hellskitchen.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751473Ab2ESCfs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 May 2012 22:35:48 -0400
Date: Fri, 18 May 2012 22:35:45 -0400
From: Jim Rees <rees@umich.edu>
To: linux-nfs@vger.kernel.org
Subject: warning: the frame size of 1040 bytes is larger than 1024 bytes
Message-ID: <20120519023545.GA28688@umich.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I get this when I build 3.4.0-rc7 plus blklayout patches:

  CC [M]  fs/nfs/nfs4xdr.o
/home/rees/l/pnfs/linux/fs/nfs/nfs4xdr.c: In function ‘encode_exchange_id’:
/home/rees/l/pnfs/linux/fs/nfs/nfs4xdr.c:1719:1: warning: the frame size of 1040 bytes is larger than 1024 bytes [-Wframe-larger-than=]

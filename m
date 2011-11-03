Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.14.81]:59975 "EHLO
	hackers.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753303Ab1KCCv5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Nov 2011 22:51:57 -0400
Date: Wed, 2 Nov 2011 22:51:54 -0400
From: Jim Rees <rees@umich.edu>
To: linux-nfs@vger.kernel.org
Subject: rpcbind listen on localhost only?
Message-ID: <20111103025154.GA10875@umich.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

How do I get rpcbind to only listen on localhost and not on INADDR_ANY,
equivalent to the "-l" option to portmap?  The man page implies that
"-h 127.0.0.1" should do it, but that doesn't work.

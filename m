Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.12.86]:38009 "EHLO
	tombraider.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753072Ab1KFP6t (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 6 Nov 2011 10:58:49 -0500
Date: Sun, 6 Nov 2011 10:58:44 -0500
From: Jim Rees <rees@umich.edu>
To: linux-nfs@vger.kernel.org
Subject: rpcbind -h
Message-ID: <20111106155844.GA1790@umich.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Is there some good reason why the rpcbind '-h' option (bind to given
address) applies only to the udp listening socket and not to the tcp socket?

And is there any good reason why an nfs3 client not providing any services
would need to run rpcbind?

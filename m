From: "Krzysztof Adamski" <k@adamski.org>
Subject: Replacment for the nfsd thread busy histogram
Date: Thu, 17 Sep 2009 16:42:34 -0400 (EDT)
Message-ID: <49899.205.189.93.240.1253220154.squirrel@webmail.netxsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from radon.netxsys.com ([204.16.202.162]:35720 "EHLO
	radon.netxsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751636AbZIQVGs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Sep 2009 17:06:48 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi All,

Since the nfsd thread busy histogram has been removed from
/proc/net/rpc/nfsd, what is the replacement?
How can I find out how many treads I should run on mt nfs server?

K

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:12785 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756697Ab3E3SGq convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 May 2013 14:06:46 -0400
Received: from vmwexceht03-prd.hq.netapp.com (exchsmtp.hq.netapp.com [10.106.76.241])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id r4UI6j1W008002
	for <linux-nfs@vger.kernel.org>; Thu, 30 May 2013 11:06:45 -0700 (PDT)
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Labeled NFS
Date: Thu, 30 May 2013 18:06:44 +0000
Message-ID: <1369937203.4195.15.camel@leira.trondhjem.org>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

OK, I've pushed out a tentative 'linux-next', and 'testing' branch with
the client side labeled NFS stuff merged.

See the gitweb repository on:

    http://git.linux-nfs.org/?p=trondmy/linux-nfs.git;a=summary


Please test...


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

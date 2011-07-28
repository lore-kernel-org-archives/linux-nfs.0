From: =?gb2312?B?ssW/oQ==?= <buddy_sz@hotmail.com>
Subject: nfs:truncate didn't zero the new area
Date: Thu, 28 Jul 2011 00:43:00 +0000
Message-ID: <SNT124-w600D6FDE708FE34B3D88DEF7340@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset="gb2312"
To: <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from snt0-omc3-s3.snt0.hotmail.com ([65.55.90.142]:41025 "EHLO
	snt0-omc3-s3.snt0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751231Ab1G1Ase (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Jul 2011 20:48:34 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



There is a error when using truncate in 2.6.32e.g1.create a file test,the content is:test:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa  (100 a)2.use truncate(test,25),the content is:test:aaaaaaaaaaaaaaaaaaaaaaa3.use truncate(test,50),what we expect result is:test:aaaaaaaaaaaaaaaaaaaaaaa0000000000000000000000but in fact the content is:test:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaathe new part is not cleared.
I lookuped the code of nfs and nfsd,but i haven't fount the code that clear the new part of truncate.
 		 	   		  

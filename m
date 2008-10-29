From: Chuck Lever <chuck.lever@oracle.com>
Subject: NFSD IPv6 support for 2.6.29
Date: Wed, 29 Oct 2008 13:04:18 -0400
Message-ID: <9BBD5BD5-C461-43C4-AEB0-69D3E31F92B7@oracle.com>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Le Rouzic <aime.le-rouzic@bull.net>,
	Varun Chandramohan <varunc@linux.vnet.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:12815 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753996AbYJ2RGZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Oct 2008 13:06:25 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Aime, Varun-

Bruce asked me to collect server-side IPv6 patches for upstream.  I've  
collected the patches that have been posted on the list, and added  
some fixes of my own.

Can you have a look at

   http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=summary

   tag cel-ipv6-10292008

These have been build tested, but I haven't done any run-time testing  
yet.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com

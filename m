From: Christoph Bartoschek <bartoschek-eefaeeawk+jFLWzOrOlZPg@public.gmane.org>
Subject: Invisible files and input/output errors
Date: Tue, 4 Dec 2007 00:37:36 +0100
Message-ID: <200712040037.36598.bartoschek@or.uni-bonn.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from brical.or.uni-bonn.de ([131.220.141.99]:47389 "EHLO
	brical.or.uni-bonn.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751060AbXLCX6r (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Dec 2007 18:58:47 -0500
Received: from wse04.or.uni-bonn.de (bg-1.or.uni-bonn.de [131.220.141.100])
	by brical.or.uni-bonn.de (Postfix) with ESMTP id 697743B6CE
	for <linux-nfs@vger.kernel.org>; Tue,  4 Dec 2007 00:36:11 +0100 (CET)
Received: from [10.0.0.34] (unknown [10.0.0.34])
	by wse04.or.uni-bonn.de (Postfix) with ESMTP id 5F47DE927
	for <linux-nfs@vger.kernel.org>; Tue,  4 Dec 2007 00:37:37 +0100 (CET)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

we use a DFS-NFS-Gateway on AIX 5.1 as our NFS-Server. This works fine most of 
the time but for four months we have strange problems. There are basically 
two issues:

1. Using "ls" in specific directories after certain idle time gives us 
an "Input/Output Error" without any results.

2. In some directories some entries are not shown. For example there is a 
directory with the subdirectory ak_fcp in it. "ls" does not show this 
directory. But it is possible to do "cd ak_fcp" and then normally work with 
it.  It is also possible to access files in the directory while being in the 
parent directory: " less ak_fcp/logfile"  works.

Does anybody know how to get rid of the problems? The problems occur on 
several different linux versions.

Greetings
Christoph

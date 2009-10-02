From: Tom Haynes <tdh-8AdZ+HgO7noAvxtiuMwx3w@public.gmane.org>
Subject: mount retries
Date: Fri, 02 Oct 2009 16:45:37 -0500
Message-ID: <4AC67481.20900@excfb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from eastrmpop110.cox.net ([68.230.240.52]:35724 "EHLO
	eastrmpop110.cox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753490AbZJBWCT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Oct 2009 18:02:19 -0400
Received: from eastrmimpo01.cox.net ([68.1.16.119])
          by eastrmmtao101.cox.net
          (InterMail vM.8.00.01.00 201-2244-105-20090324) with ESMTP
          id <20091002214629.IVBK6358.eastrmmtao101.cox.net-jOUDVclVbkwbwS5KOAyqYuTW4wlIGRCZ@public.gmane.org>
          for <linux-nfs@vger.kernel.org>; Fri, 2 Oct 2009 17:46:29 -0400
Received: from [192.168.2.115] (kanigix.internal.excfb.com [192.168.2.115])
	by adept.internal.excfb.com (8.14.3/8.14.2) with ESMTP id n92LkQ9K000949
	for <linux-nfs@vger.kernel.org>; Fri, 2 Oct 2009 16:46:27 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Does the Linux mount client have any algorithms to retry a NFS mount?

Or does it depend entirely on the underlying protocol.

I.e., would TCP retry and UDP just give up?

From: Tom Haynes <tdh-8AdZ+HgO7noAvxtiuMwx3w@public.gmane.org>
Subject: Security negotiation
Date: Fri, 10 Jul 2009 13:07:46 -0500
Message-ID: <4A578372.1020005@excfb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from eastrmmtao101.cox.net ([68.230.240.7]:34113 "EHLO
	eastrmmtao101.cox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753389AbZGJS2D (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jul 2009 14:28:03 -0400
Received: from eastrmimpo03.cox.net ([68.1.16.126])
          by eastrmmtao101.cox.net
          (InterMail vM.7.08.02.01 201-2186-121-102-20070209) with ESMTP
          id <20090710180758.DYBA20709.eastrmmtao101.cox.net-jOUDVclVbkx9GQUQ9EqIheTW4wlIGRCZ@public.gmane.org>
          for <linux-nfs@vger.kernel.org>; Fri, 10 Jul 2009 14:07:58 -0400
Received: from [192.168.2.115] (kanigix.internal.excfb.com [192.168.2.115])
	by adept.internal.excfb.com (8.14.2/8.14.2) with ESMTP id n6AI7v3n017770
	for <linux-nfs@vger.kernel.org>; Fri, 10 Jul 2009 13:07:57 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

During a NFSv3 mount request, the server returns an array of supported 
security flavors.

With a Linux server, exports(5) states:

For the purposes of security  flavor  negotiation, order counts: 
preferred flavors should be listed first.

And the Solaris client states in mount_nfs(1M):

     NFS Version 3 mounts negotiate a security mode when the server 
returns an array of security modes. The
     client picks the first mode in the array that is supported on the 
client. In negotiations, an NFS Version 3 client
     is limited to the security flavors listed in /etc/nfssec.conf.

The Linux nfs(5) states:

     If the sec option is not specified, or if sec=sys is specified, the 
NFS client uses the AUTH_SYS
     security flavor for  all  NFS  requests on this mount point.

So, I'm trying to understand what the Linux client would do if the 
export does not support AUTH_SYS and
there is no sec= supplied.

Does the Linux client traverse the array in order until it finds a match 
or does it consider which flavor is strongest?


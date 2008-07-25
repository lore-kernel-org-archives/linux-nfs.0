From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [NFS] setting up NFS - help!
Date: Fri, 25 Jul 2008 14:37:53 -0400
Message-ID: <488A1D81.9050205@RedHat.com>
References: <175553.71825.qm@web59912.mail.ac4.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: John Smith <jsmith_at_work@yahoo.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:37396 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751664AbYGYSij (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jul 2008 14:38:39 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1KMSBY-00008V-Vg
	for linux-nfs@vger.kernel.org; Sat, 26 Jul 2008 04:38:37 +1000
In-Reply-To: <175553.71825.qm-159wZH6VlHj5nGHA2nhOEg9VFclH1bkmQQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



John Smith wrote:
> Trying to do a ./configure on the nfs-utils-1.1.2 on an ubuntu 8.04 server.  
> 
> All is well, except for one line involving Kerberos v5, which I'm not sure about.  Any insight into why it is giving me the following message would be appreciated!  (I am trying to incorporate Kerberos v5 into the build).
> 
> checking for Kerberos v5... ./configure: line 23561: test: 163-beta1-debian: integer expression expected
> /usr
> The current KRBDIR is /usr
no idea... Is Kerberos installed? 

steved.

-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great prizes
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=100&url=/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs


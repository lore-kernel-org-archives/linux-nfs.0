From: "fanpost-EXMfOWiJQmyoYr4blSSd5g@public.gmane.org" <fanpost-EXMfOWiJQmyoYr4blSSd5g@public.gmane.org>
Subject: AW: NFS strange sync issues - different versions of same file using multiple clients
Date: Wed, 15 Sep 2010 15:23:31 +0200
Message-ID: <E1OvrxT-0004Sc-47@saphir-ld-031.synserver.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-out-112.synserver.de ([212.40.180.112]:1056 "HELO
	smtp-out-111.synserver.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with SMTP id S1752707Ab0IONXd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Sep 2010 09:23:33 -0400
Received: from www-data by saphir-ld-031.synserver.de with local (Exim 4.63)
	(envelope-from <fanpost-EXMfOWiJQmyoYr4blSSd5g@public.gmane.org>)
	id 1OvrxT-0004Sc-47
	for linux-nfs@vger.kernel.org; Wed, 15 Sep 2010 15:23:31 +0200
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi, 


> If you downgrade to nfs3, or if you run
>
>	echo 0 >/proc/sys/fs/leases-enable
>
> before starting the nfs server, does the problem go away?

the system is currently in use so debugging on the server is a bit difficult. 
I'll try it in next maintenance cycle. 

Ihank you. 

Do you have suggestions for debugging on the client side?

josh




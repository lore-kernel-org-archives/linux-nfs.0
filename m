From: Simone Carbonara <simone-2dnJtoj8yUAi5CQI31g/s0B+6BGkLq7r@public.gmane.org>
Subject: Strange NFS behaviour
Date: Fri, 23 May 2008 11:41:55 +0200
Message-ID: <g163h5$3mu$3@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:51058 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750703AbYEWJuH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 May 2008 05:50:07 -0400
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1JzTuU-0006U2-Ny
	for linux-nfs@vger.kernel.org; Fri, 23 May 2008 09:50:02 +0000
Received: from adsl-ull-216-106.49-151.net24.it ([151.49.106.216])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Fri, 23 May 2008 09:50:02 +0000
Received: from simone by adsl-ull-216-106.49-151.net24.it with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Fri, 23 May 2008 09:50:02 +0000
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

i'm experiencing on debian etch the following behaviour with NFS.

I have 1 backend running linux debian sarge that exports via NFS a  SVN 
working copy to a couple of frontend (debian etch) that read the 
contents of the exported NFS share called /WEB-2 (under drbd ) and 
publish it via apache.

Sometimes when i update my working copy on my backend i don't see the 
changes on all the frontends as follows the output on ls on the frontends.

FE-01:~# ls -alio /WEB-2/sites/http/pilot/frontend/contenuto_lista_nozze.php
17237334 -rw-r----- 0 vapache 3387 2008-05-16 11:10 
/WEB-2/sites/http/pilot/frontend/contenuto_lista_nozze.php
FE-02:~# ls -alio /WEB-2/sites/http/pilot/frontend/contenuto_lista_nozze.php
17237564 -rw-r--r-- 1 vapache 3801 2008-05-23 11:09 
/WEB-2/sites/http/pilot/frontend/contenuto_lista_nozze.php


If i remount the /WEB-1 share on the frontend the changes are seen and 
updated correctly on all frontends but it's clear that this behaviour is 
not accetable when writing codes that needs to be updated directly on 
production.

The exportfs flag options on the exported fs on the Backend are as follows

rw,all_squash,anonuid=4001,anongid=555,no_subtree_check,sync.

Someone could address me in any troubleshooting steps on this issue?

Best Regards,

Simone Carbonara



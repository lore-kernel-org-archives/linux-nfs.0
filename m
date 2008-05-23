From: "david m. richter" <richterd@citi.umich.edu>
Subject: Re: Strange NFS behaviour
Date: Fri, 23 May 2008 13:22:36 -0400 (EDT)
Message-ID: <Pine.BSO.4.64.0805231310040.32037@citi.umich.edu>
References: <g163h5$3mu$3@ger.gmane.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org
To: Simone Carbonara <simone-2dnJtoj8yUAi5CQI31g/s0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:46109 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751979AbYEWRWg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 May 2008 13:22:36 -0400
In-Reply-To: <g163h5$3mu$3@ger.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 23 May 2008, Simone Carbonara wrote:

> Hello,
> 
> i'm experiencing on debian etch the following behaviour with NFS.
> 
> I have 1 backend running linux debian sarge that exports via NFS a  SVN
> working copy to a couple of frontend (debian etch) that read the contents of
> the exported NFS share called /WEB-2 (under drbd ) and publish it via apache.
> 
> Sometimes when i update my working copy on my backend i don't see the changes
> on all the frontends as follows the output on ls on the frontends.
> 
> FE-01:~# ls -alio /WEB-2/sites/http/pilot/frontend/contenuto_lista_nozze.php
> 17237334 -rw-r----- 0 vapache 3387 2008-05-16 11:10
> /WEB-2/sites/http/pilot/frontend/contenuto_lista_nozze.php
> FE-02:~# ls -alio /WEB-2/sites/http/pilot/frontend/contenuto_lista_nozze.php
> 17237564 -rw-r--r-- 1 vapache 3801 2008-05-23 11:09
> /WEB-2/sites/http/pilot/frontend/contenuto_lista_nozze.php
> 
> 
> If i remount the /WEB-1 share on the frontend the changes are seen and updated
> correctly on all frontends but it's clear that this behaviour is not accetable
> when writing codes that needs to be updated directly on production.

	it's the client-side caching.  i used to run into essentially the 
same thing when developing on a git repository that's exported over NFSv4, 
then mounting and building on the clients (with lndir or make O=) -- i'll 
quick fix a little bug and try to recompile, but the clients don't notice 
the change until their caches expire or they're forced to invalidate them 
(say, touch the changed file, but that's lame).

	you can experiment with mount options like 'noac' or 'actimeo' 
(see the nfs(5) manpage); they'll impact performance somewhat, but maybe 
in your situation it won't be a problem.

	good luck,

	d
	.

> 
> The exportfs flag options on the exported fs on the Backend are as follows
> 
> rw,all_squash,anonuid=4001,anongid=555,no_subtree_check,sync.
> 
> Someone could address me in any troubleshooting steps on this issue?
> 
> Best Regards,
> 
> Simone Carbonara
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

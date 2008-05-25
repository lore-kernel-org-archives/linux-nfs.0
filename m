From: Simone Carbonara <simone-2dnJtoj8yUAi5CQI31g/s0B+6BGkLq7r@public.gmane.org>
Subject: Re: Strange NFS behaviour
Date: Sun, 25 May 2008 09:12:12 +0200
Message-ID: <g1b3ge$abj$1@ger.gmane.org>
References: <g163h5$3mu$3@ger.gmane.org> <Pine.BSO.4.64.0805231310040.32037@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:60322 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751831AbYEYHMd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 25 May 2008 03:12:33 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1K0AP9-0008RY-Q5
	for linux-nfs@vger.kernel.org; Sun, 25 May 2008 07:12:31 +0000
Received: from 151.60.226.94 ([151.60.226.94])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Sun, 25 May 2008 07:12:31 +0000
Received: from simone by 151.60.226.94 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Sun, 25 May 2008 07:12:31 +0000
In-Reply-To: <Pine.BSO.4.64.0805231310040.32037@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thank you David for the reply.

> 	it's the client-side caching.  i used to run into essentially the 
> same thing when developing on a git repository that's exported over NFSv4, 
> then mounting and building on the clients (with lndir or make O=) -- i'll 
> quick fix a little bug and try to recompile, but the clients don't notice 
> the change until their caches expire or they're forced to invalidate them 
> (say, touch the changed file, but that's lame).

That's sounds like the same behaviour. But what i noticed is that .svn 
dir of the repository is correctly updated while the file remains in 
this 0 state. Did you see the 0 after the permission fields? I've never 
experiencing such output.

> 	you can experiment with mount options like 'noac' or 'actimeo' 
> (see the nfs(5) manpage); they'll impact performance somewhat, but maybe 
> in your situation it won't be a problem.
> 

I've added the noac option just last monday but it didn't fix the 
problem. I'll try actimeo flag and give you a feedback. I don't care 
about the performance lately i just need my customer see the changes on 
the svn repos exported :-).

Thanks a lot.

simone






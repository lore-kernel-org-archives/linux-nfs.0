From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] Exportfs and rpc.mountd optimalization (revisited)
Date: Wed, 18 Feb 2009 19:43:10 -0500
Message-ID: <499CAB1E.10705@RedHat.com>
References: <499C5861.6050408@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:45971 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752476AbZBSApu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Feb 2009 19:45:50 -0500
Received: from int-mx2.corp.redhat.com (int-mx2.corp.redhat.com [172.16.27.26])
	by mx2.redhat.com (8.13.8/8.13.8) with ESMTP id n1J0jgJM027731
	for <linux-nfs@vger.kernel.org>; Wed, 18 Feb 2009 19:45:46 -0500
In-Reply-To: <499C5861.6050408-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Steve Dickson wrote:
> Very long time ago Tomas Richter submitted a patch that added
> a export hash table to both exportfs and mountd. Very recently 
> I ran across it and actually used some parts in the recent TCP
> wrappers patch... 
> 
> Looking at the discussion 
>     http://marc.info/?l=linux-nfs&m=111938362106991&w=2
> It seem no one took the time to test out the patch.. There
> was even a Red Hat bug opened on it but for some reason
> it got closed... Anyway... 
> 
> This is a good patch... imho.. It does help with very large exports 
> at least in my testing... And I'm also hoping the hash table will
> useful in the pseudo root work... 
> 
> Any objections to committing this?? 
> 
Committed...

steved.

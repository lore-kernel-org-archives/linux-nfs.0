Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bronze.cs.yorku.ca ([130.63.90.34]:33273 "EHLO
	bronze.cs.yorku.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753150Ab0G1OXf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Jul 2010 10:23:35 -0400
Received: from [130.63.86.125] (ident=jas)
	by bronze.cs.yorku.ca with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.67)
	(envelope-from <jas@cse.yorku.ca>)
	id 1Oe6wC-00006D-A8
	for linux-nfs@vger.kernel.org; Wed, 28 Jul 2010 09:44:48 -0400
Message-ID: <4C503450.1010609@cse.yorku.ca>
Date: Wed, 28 Jul 2010 09:44:48 -0400
From: Jason Keltz <jas@cse.yorku.ca>
To: linux-nfs@vger.kernel.org
Subject: hang on existing systems when exporting NFS share to new systems
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi.

My list of NFS exports has been gradually growing over the years.  Right 
now, for example, my home directories are exported to around 800 hosts. 
(although only a relatively small subset of those will mount at the same 
time...).  I used to just add hosts to /etc/exports on the file server, 
and run "exportfs -r", and everything would be fine.  New systems would 
be able to mount everything perfectly, and existing systems would not be 
affected at all.  As the list has grown, I've been noticing a problem. 
Now, when I run exportfs -r, there is an approximate 7-10 second hang on 
the systems that have already mounted the share, and then everything 
returns to normal.  This doesn't happen *while* exportfs -r is running, 
but just after it exits.  I figured that maybe exportfs was 
"unexporting"/re-exporting to hosts that already had the share in use 
which might have caused the problem, so I tried to manually add/remove 
hosts thinking that this would only affect those hosts, but it did not. 
Exporting to one new host still causes the hang on all existing hosts.

Since I have multiple exports to all of the hosts, adding one new host 
can hang things for a while.  I can see that reducing the list of 
exports, or hosts would reduce the delay.  What I am wondering is if 
there is a better way that I can add hosts without affecting 
connectivity to existing hosts?

The NFS server itself is pretty powerful -- dual quad core box, lots of 
memory, many NFS threads, exclusive NFS server, etc...  I am running an 
older RHEL4 release though, so it would have an older kernel/NFS system. 
  Maybe this issue has been solved in newer releases.

Any feedback would be helpful.

Thanks!

Jason.


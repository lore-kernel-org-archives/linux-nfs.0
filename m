From: Timo Aaltonen <tjaalton-kf+aQKke1yb1KXRcyAk9cg@public.gmane.org>
Subject: atomic rename buggy on NFS?
Date: Thu, 19 Mar 2009 14:23:13 +0200 (EET)
Message-ID: <alpine.OSF.1.99.0903191403140.384018@replicant.hut.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
To: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-1.hut.fi ([130.233.228.91]:57658 "EHLO smtp-1.hut.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753086AbZCSMoK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Mar 2009 08:44:10 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


 	Hi

   There's a bug (*) which has annoyed me for some time now. With $HOME on 
NFS, editing a desktop launcher with nautilus closes the window after 
nautilus tries to change the file. This was debugged and upstream thinks 
that atomic rename is buggy on NFS. Quote:

"Results from mv temp.txt foobar

On NFS:
Directory Monitor Event:
Child = /mnt/data/temp/foobar
Event = DELETED
Directory Monitor Event:
Child = /mnt/data/temp/temp.txt
Event = DELETED
Directory Monitor Event:
Child = /mnt/data/temp/foobar
Event = CREATED

On ext3:
Directory Monitor Event:
Child = /tmp/x/temp.txt
Event = DELETED
Directory Monitor Event:
Child = /tmp/x/foobar
Event = CREATED

This is IMHO bogus behaviour from NFS. At no time is the "foobar" file not
visible, so it should IMHO not be reported as deleted."


Or is it a feature that needs to be worked around in client apps?


* http://bugzilla.gnome.org/show_bug.cgi?id=575684


t

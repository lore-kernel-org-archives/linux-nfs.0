Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:7549 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751706Ab2LUDOH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Dec 2012 22:14:07 -0500
Message-ID: <50D3D3EE.4060301@RedHat.com>
Date: Thu, 20 Dec 2012 22:13:50 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: David Quigley <dpquigl@davequigley.com>
CC: joseph_vu@hotmail.com, trond.myklebust@netapp.com, bfields@fieldses.org,
        rodel_fm@dsi.a-star.edu.sg, casey@schaufler-ca.com,
        linux-nfs@vger.kernel.org, selinux@tycho.nsa.gov
Subject: Re: Labeled NFS Meeting Info for Tonight Dec 20/Dec 21st for our
 friends in Singapore
References: <cd02d79979bf6c825152f3bcf3a7f33d@countercultured.net>
In-Reply-To: <cd02d79979bf6c825152f3bcf3a7f33d@countercultured.net>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I can seem to find the hangout...

steved.

On 20/12/12 15:41, David Quigley wrote:
> Hello Everyone,
> 
> The meeting info and agenda is listed below. I will try to have the google+ hangout posted and running a half an hour before the meeting so people can join. just add me to a circle and I will add you to my LNFS Meeting circle and send out the invite. You can add me earlier in the day if you like I should be able to add people whenever.
> 
> 
> Time: Thursday Dec 20th 10:00pm-12:00pm (The latest) Eastern
>             8:00pm-10:00pm Central
>             7:00pm-9:00pm Pacific
>       Friday Dec 21st 11:00am-1:00pm Singapore
> 
> Where: Google+ Hangout Hosted by +SELinux or +Dave Quigley (If you see a blue 350z you have the right dave quigley).
> 
> 
> 
> 
> Proposed Agenda
> -------------------------
> 
> + Discuss merge windows and which one we'd like to target
> 
> Do we want to shoot for 3.9 or will we attempt to implement the remaining features and go for 3.10
> 
> + Discuss current feedback from Bruce Fields
> 
> Patch 1/13: Cleanup comment for dentry_init_security
> Patch 2/13: Cleanup comment to reflect that xattrs aren't being used in the protocol.
> Patch 5/13: Add warning that the functionality is highly experimental and still volatile.
> Patch 7/13: Concern about nfs4_label_alloc doing higher order allocations (more than 4096).
> Patch 10/13: Investigate removing ifdefs from server code and making sure that nfs_server_capable and other functions handle it being configured off.
> Patch 13/13: Similar comments about removing ifdefs if possible and hiding it away in other areas. Find out why security_inode_setsecctx may fail and see if it can in its usecase here. Remove BUGONs and cleanup whitespace.
> 
> 
> + Discuss current feedback from Trond Myklebust
> 
> Trond commented about changing the definition of encode_getfattr. He would rather instead of modifying getfattr we mimic encode/decode_fsinfo. We should look at that and determine what to do.
> 
> + Discuss implementing remaining features from NFSv4.2 specification
> 
> Attribute change notification
> RPCSECGSSv3?
> 
> + Discuss viability of future every other week meetings

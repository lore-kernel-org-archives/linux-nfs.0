Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:35105 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751267Ab1IUPpW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Sep 2011 11:45:22 -0400
Date: Wed, 21 Sep 2011 11:45:21 -0400
From: "'J. Bruce Fields'" <bfields@fieldses.org>
To: Tim <supertimothy@web.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Writing / Locking problem with NFSv4
Message-ID: <20110921154521.GC21510@fieldses.org>
References: <001101cc745e$356aeed0$a040cc70$@web.de>
 <20110920135050.GA12422@fieldses.org>
 <001e01cc784b$bba7fa10$32f7ee30$@web.de>
Content-Type: text/plain; charset=utf-8
In-Reply-To: <001e01cc784b$bba7fa10$32f7ee30$@web.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Sep 21, 2011 at 12:46:34PM +0200, Tim wrote:
> On Fri, Sep 16, 2011 at 12:48:45PM +0200, Tim wrote:
> >> I’m  facing a rather strange problem. 
> >> 
> >> From one client I can mount and access my NFSServer without any problems.
> >> Writing and locking works with a non root user accout. 
> >> From another client (in another subnet), with root everything works 
> >> fine. If I use another user, locking doesnt work and also when I 
> >> create a file with vim, the *.swp file is not deleted afterwards. But 
> >> reading works without problems.
> >> Strange thing is user mapping seems to work correct – at least what ls 
> >> -la and the logfiles for idmapd shows.
> 
> >Which client and server?  (Linux on both?  Which versions?)  Are you using kerberos?  If not, are your uid's the same between client and server?  What does your export file look like?
> 
> Client and Server are both RHEL 6.1. I am not using kerberos. And yes, the uid's are the same, also the gid is the same: 3000 for both.
> This is my export file:
> 
> /srv/nfs/			10.1.4.32/255.255.255.224(rw,fsid=0,sync,no_subtree_check,no_root_squash) 10.1.0.9(rw,fsid=0,sync,no_subtree_check,no_root_squash)
> /srv/nfs/mail/users		10.1.4.32/255.255.255.224(rw,fsid=1,sync,no_subtree_check,no_root_squash)
> /srv/nfs/mail/tmp		10.1.4.32/255.255.255.224(rw,fsid=2,sync,no_subtree_check,no_root_squash)
> /srv/nfs/testdata		10.1.0.9(rw,fsid=10,sync,no_subtree_check,no_root_squash)
> 
> I tried to take tcpdumps as root and non root user: They look the same to me. However, I'm not so sure what I'm looking for...

Hm.  Sounds possibly like

	http://marc.info/?t=129183437900003&r=1&w=2

--b.

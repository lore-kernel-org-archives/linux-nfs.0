From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH v2] register NFS_ACL with rpcbind
Date: Tue, 03 Nov 2009 10:28:42 -0500
Message-ID: <4AF04C2A.4020203@redhat.com>
References: <4AEF2D19.5090409@redhat.com> <4AEF562B.9070606@redhat.com> <200911031013.27247.agruen@suse.de> <200911031017.41564.okir@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Andreas Gruenbacher <agruen@suse.de>,
	NFS list <linux-nfs@vger.kernel.org>,
	"J. Bruce Fields" <bfields@fieldses.org>
To: Olaf Kirch <okir@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29825 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750972AbZKCP2p (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Nov 2009 10:28:45 -0500
In-Reply-To: <200911031017.41564.okir@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Olaf Kirch wrote:
> On Tuesday 03 November 2009 10:13:27 Andreas Gruenbacher wrote:
>> I don't understand the reasoning behind .vs_hidden for NFS_ACL, hopefully
>> Olaf can clarify. NFS_ACL is the only user of .vs_hidden as far as I can
>> see though, so if this is changeg, shouldn't the entire commit bc5fea4
>> which introduced the flag be reverted?
> 
> I can't remember the details of that one. I do remember that this is
> based on someone's request who told me that we shouldn't register nfsacl
> with portmap. I didn't check myself whether Solaris did or did not do
> it at that time.
> 
> I have no issue with reverting that change, and removing the whole
> .vs_hidden kludge too.
> 

It seems that vs_hidden is used in 1 place outside of the NFS_ACL
server code.  It is used in the NFSv4 callback code.

I will look to see how difficult that might be to fix this spot
as well and then get rid of vs_hidden.

	Thanx...

		ps

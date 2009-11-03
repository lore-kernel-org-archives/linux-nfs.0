From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH v2] register NFS_ACL with rpcbind
Date: Tue, 3 Nov 2009 10:17:41 +0100
Message-ID: <200911031017.41564.okir@suse.de>
References: <4AEF2D19.5090409@redhat.com> <4AEF562B.9070606@redhat.com> <200911031013.27247.agruen@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Peter Staubach <staubach@redhat.com>,
	NFS list <linux-nfs@vger.kernel.org>,
	"J. Bruce Fields" <bfields@fieldses.org>
To: Andreas Gruenbacher <agruen@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:47947 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754074AbZKCJT1 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Nov 2009 04:19:27 -0500
In-Reply-To: <200911031013.27247.agruen@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tuesday 03 November 2009 10:13:27 Andreas Gruenbacher wrote:
> I don't understand the reasoning behind .vs_hidden for NFS_ACL, hopef=
ully
> Olaf can clarify. NFS_ACL is the only user of .vs_hidden as far as I =
can
> see though, so if this is changeg, shouldn't the entire commit bc5fea=
4
> which introduced the flag be reverted?

I can't remember the details of that one. I do remember that this is
based on someone's request who told me that we shouldn't register nfsac=
l
with portmap. I didn't check myself whether Solaris did or did not do
it at that time.

I have no issue with reverting that change, and removing the whole
=2Evs_hidden kludge too.

Thanks,
Olaf
--=20
Neo didn't bring down the Matrix. SOA did. (soafacts.com)
--------------------------------------------
Olaf Kirch - Director Server (okir@novell.com)
SUSE LINUX Products GmbH, Maxfeldstr. 5, D-90409 N=FCrnberg
GF: Markus Rex, HRB 16746 (AG N=FCrnberg)


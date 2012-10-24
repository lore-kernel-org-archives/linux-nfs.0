Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37956 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934318Ab2JXUip (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Oct 2012 16:38:45 -0400
Date: Wed, 24 Oct 2012 16:38:43 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>
Subject: Re: 3.7-rc1 NFSv3/sec=krb5 mkdir failure
Message-ID: <20121024203843.GE6697@fieldses.org>
References: <20121016125832.GC30649@fieldses.org>
 <20121024200249.GC6697@fieldses.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9092906F7@SACEXCMBX04-PRD.hq.netapp.com>
 <20121024201517.GD6697@fieldses.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA909290827@SACEXCMBX04-PRD.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA909290827@SACEXCMBX04-PRD.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 24, 2012 at 08:31:16PM +0000, Myklebust, Trond wrote:
> > -----Original Message-----
> > From: J. Bruce Fields [mailto:bfields@fieldses.org]
> > Sent: Wednesday, October 24, 2012 4:15 PM
> > To: Myklebust, Trond
> > Cc: linux-nfs@vger.kernel.org; Schumaker, Bryan
> > Subject: Re: 3.7-rc1 NFSv3/sec=krb5 mkdir failure
> > 
> > On Wed, Oct 24, 2012 at 08:07:55PM +0000, Myklebust, Trond wrote:
> > > > -----Original Message-----
> > > > From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
> > > > owner@vger.kernel.org] On Behalf Of J. Bruce Fields
> > > > Sent: Wednesday, October 24, 2012 4:03 PM
> > > > To: linux-nfs@vger.kernel.org; Myklebust, Trond; Schumaker, Bryan
> > > > Subject: Re: 3.7-rc1 NFSv3/sec=krb5 mkdir failure
> > > >
> > > > Anyone get a chance to look at this?  It seems very reproduceable.
> > > >
> > > > --b.
> > > >
> > > > On Tue, Oct 16, 2012 at 08:58:32AM -0400, bfields wrote:
> > > > > On 3.7-rc1:
> > > > >
> > > > > 	client# mount -tnfs -osec=krb5,vers=3 server:/exports/ext4 /mnt/
> > > > >
> > > > > 		server# ls -l /exports/ext4|grep TMP
> > > > > 		server#
> > > > >
> > > > > 	# mkdir /mnt/TMP
> > > > > 	mkdir: cannot create directory `/mnt/TMP': Permission denied
> > > > >
> > > > > 		server# ls -l /exports/ext4|grep TMP
> > > > > 		drwxr-xr-x  2 nfsnobody nfsnobody 4096 Oct 16 08:56 TMP
> > > > > 		server#
> > > > >
> > > > > Wireshark also shows that the create succeeds.
> > >
> > > Can you share the wireshark trace?
> > 
> > Sure.  This covers the mount and mkdir.  The mkdir call and reply are in
> > frames 77 and 78.
> 
> Hmm.... Can you please check if the ACL is being set correctly on the server? I suspect that might be the source of the error.

ACLs on the export and the new directory are both trivial:

	[root@pip1 ~]# ls -ld /exports/ext4/
	drwxrwxrwx. 8 root root 4096 Oct 24 16:12 /exports/ext4/
	[root@pip1 ~]# getfacl /exports/ext4
	getfacl: Removing leading '/' from absolute path names
	# file: exports/ext4
	# owner: root
	# group: root
	user::rwx
	group::rwx
	other::rwx

	[root@pip1 ~]# ls -ld /exports/ext4/TMP
	drwxr-xr-x 2 nfsnobody nfsnobody 4096 Oct 24 16:12
	/exports/ext4/TMP
	[root@pip1 ~]# getfacl /exports/ext4/TMP
	getfacl: Removing leading '/' from absolute path names
	# file: exports/ext4/TMP
	# owner: nfsnobody
	# group: nfsnobody
	user::rwx
	group::r-x
	other::r-x

	[root@pip1 ~]# 

--b.

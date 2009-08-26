From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 2/2] Enable v4 mounts when either "nfsvers=4" or
 "vers=4" option are set (vers-02)
Date: Wed, 26 Aug 2009 15:59:24 -0400
Message-ID: <1251316764.5226.21.camel@heimdal.trondhjem.org>
References: <4A9424DB.2040303@RedHat.com> <4A942593.8030101@RedHat.com>
	 <CF5F0448-E859-4EA2-805B-909B8C907533@oracle.com>
	 <4A943914.9020104@RedHat.com>
	 <7AB7BC01-F9E5-4611-BB4B-2B6E27069631@oracle.com>
	 <4A944645.1020003@RedHat.com>
	 <1251233345.25372.67.camel@heimdal.trondhjem.org>
	 <B62E906B-F215-4400-B48D-DDE2C8428F9E@oracle.com>
	 <4A954FBF.3030606@RedHat.com>
	 <23199F1A-EA23-4DE1-AAB8-92D4B508C865@oracle.com>
	 <4A956BF2.6000902@RedHat.com>
	 <F805BE4F-BA72-4B13-A60A-B298C69611C8@oracle.com>
	 <4A95760C.9000604@RedHat.com>
	 <B26EBCDF-5836-440E-81D5-5E089158BFE1@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steve Dickson <SteveD@redhat.com>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>,
	Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:34268 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752829AbZHZT7e (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 26 Aug 2009 15:59:34 -0400
In-Reply-To: <B26EBCDF-5836-440E-81D5-5E089158BFE1@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-08-26 at 15:50 -0400, Chuck Lever wrote:
> Yeah, switching file system types in the mount(2) system call is the  
> fly in the ointment.  I'm just wondering if Trond had some thoughts  
> about making that more feasible.

Just look at what we're already doing for NFSv4. Inside nfs4_get_sb, we
basically do a kernel mount in order to get the real super block. We
then simply have to attach it to the vfsmount that the sys_mount() call
passed down to us.

This really isn't anything new or difficult...



Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:31268 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750811Ab3E3U0S convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 May 2013 16:26:18 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.3 \(1503\))
Subject: Re: 3.10-rc3 NFSv3 mount issues
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <51A7B442.9010108@sandia.gov>
Date: Thu, 30 May 2013 16:26:12 -0400
Cc: Weston Andros Adamson <dros@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        LKML Kernel <linux-kernel@vger.kernel.org>
Message-Id: <D74C8145-AD4D-4CFE-963C-643B8D7DBA10@oracle.com>
References: <51A7B442.9010108@sandia.gov>
To: Jim Schutt <jaschut@sandia.gov>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On May 30, 2013, at 4:19 PM, Jim Schutt <jaschut@sandia.gov> wrote:

> Hi,
> 
> I've been trying to test 3.10-rc3 on some diskless clients, and found
> that I can no longer mount my root file system via NFSv3.
> 
> I poked around looking at NFS changes for 3.10, and found these two
> commits:
> 
> d497ab9751 "NFSv3: match sec= flavor against server list"
> 4580a92d44 "NFS: Use server-recommended security flavor by default (NFSv3)"
> 
> If I revert both of these commits from 3.10-rc3, then my diskless
> client can mount its root file system.
> 
> The busybox mount command fails like this, when using 3.10-rc3:
> 
> / # mount  -t nfs -o ro,nolock,vers=3,proto=tcp 172.17.0.122:/gmi/images/jaschut/ceph.toss-2x /mnt
> mount: mounting 172.17.0.122:/gmi/images/jaschut/ceph.toss-2x on /mnt failed: Invalid argument
> 
> The commit messages for both these commits seem to say that mounting
> with the "sys=sec" option should work, but unfortunately, my busybox doesn't
> seem to understand the "sec=" mount option:
> 
> / # mount  -t nfs -o ro,nolock,vers=3,proto=tcp,sec=sys 172.17.0.122:/gmi/images/jaschut/ceph.toss-2x /mnt
> mount: invalid number 'sys'
> 
> My NFS server is based on RHEL6, and is not using any "sec=" option
> in its export for this file system.  I did try exporting with "sec=sys",
> but it didn't seem to make any difference either.
> 
> So far, this seems like a regression to me ....
> Any ideas what I might be doing wrong?  How can I
> help make this work again?

3.10-rc3 appears to be missing the fix for this.  See:

  http://marc.info/?l=linux-nfs&m=136855668104598&w=2

Trond, can we get this applied?

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com





Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:32958 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753559Ab3AVQgq convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Jan 2013 11:36:46 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Ben Greear <greearb@candelatech.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: RE: Cache request denied due to non-unique superblock keys
Date: Tue, 22 Jan 2013 16:36:44 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA915C1A030@SACEXCMBX04-PRD.hq.netapp.com>
References: <50FEBB08.2090709@candelatech.com>
In-Reply-To: <50FEBB08.2090709@candelatech.com>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
> owner@vger.kernel.org] On Behalf Of Ben Greear
> Sent: Tuesday, January 22, 2013 11:15 AM
> To: linux-nfs@vger.kernel.org
> Subject: NFS: Cache request denied due to non-unique superblock keys
> 
> I saw this on an overnight run with 3000 NFSv4 mounts:
> 
> NFS: Cache request denied due to non-unique superblock keys
> 
> 
> Any idea if it's a problem or not?

You are missing commit c4271c6e37c32105492cbbed35f45330cb327b94 (NFS: Kill fscache warnings when mounting without -ofsc). That shouldn't be a problem, but if the warning bothers you, the commit should be easy to backport.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com



Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:29215 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751156Ab3KKVE5 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Nov 2013 16:04:57 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Christoph Hellwig <hch@infradead.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs: fix pnfs Kconfig defaults
Date: Mon, 11 Nov 2013 21:04:54 +0000
Message-ID: <1384203889.7614.17.camel@leira.trondhjem.org>
References: <20131102102201.GA3860@infradead.org>
	 <6C8CF6D6-0456-4195-B00B-F35A37B64E12@netapp.com>
	 <20131111210141.GB13942@infradead.org>
In-Reply-To: <20131111210141.GB13942@infradead.org>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2013-11-11 at 13:01 -0800, Christoph Hellwig wrote:
+AD4- On Mon, Nov 11, 2013 at 08:30:48PM +-0000, Myklebust, Trond wrote:
+AD4- +AD4- +AD4- diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
+AD4- +AD4- +AD4- index b5e80b0..f731180 100644
+AD4- +AD4- +AD4- --- a/fs/nfs/Kconfig
+AD4- +AD4- +AD4- +-+-+- b/fs/nfs/Kconfig
+AD4- +AD4- +AD4- +AEAAQA- -116,17 +-116,17 +AEAAQA- config NFS+AF8-V4+AF8-2
+AD4- +AD4- +AD4- config PNFS+AF8-FILE+AF8-LAYOUT
+AD4- +AD4- +AD4- 	tristate
+AD4- +AD4- +AD4- 	depends on NFS+AF8-V4+AF8-1
+AD4- +AD4- +AD4- -	default m
+AD4- +AD4- +AD4- +-	default NFS+AF8-FS
+AD4- +AD4- 
+AD4- +AD4- Shouldn?t that really be
+AD4- +AD4- 	default NFS+AF8-V4
+AD4- +AD4- in order to get the dependency right? The current Kconfig does allow you to have nfs built in, while leaving NFSv4 as a module.
+AD4- 
+AD4- Probably should.  For some reason I had NFS+AF8-V4+AF8-1 in mind as a bool.

NFS+AF8-V4+AF8-1 is indeed a bool, but it just defines whether or not we compile
v4.1 behaviour into the 'nfsv4 module' (which is controlled by the
tristate NFS+AF8-V4).

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com

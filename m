Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:25445 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754940Ab3EMXzi convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 May 2013 19:55:38 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
CC: "Adamson, Dros" <Weston.Adamson@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Possible bug introduced by: NFS: Use server-recommended
 security flavor by default (NFSv3)?
Date: Mon, 13 May 2013 23:55:36 +0000
Message-ID: <1368489335.3563.24.camel@leira.trondhjem.org>
References: <20130513203556.GA8049@blackbox.djwong.org>
	 <C98A6B64-9648-4CBD-8E10-8C54B7DA98B6@oracle.com>
	 <20130513212440.GB8049@blackbox.djwong.org>
	 <6B5CEA91-77C1-4F2A-8A97-B01B9399EF85@oracle.com>
	 <497CC2C4-E417-4BB9-B4FD-E737A23479E3@netapp.com>
	 <20130513233411.GB29406@blackbox.djwong.org>
	 <1368488912.3563.21.camel@leira.trondhjem.org>
In-Reply-To: <1368488912.3563.21.camel@leira.trondhjem.org>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2013-05-13 at 19:48 -0400, Trond Myklebust wrote:
> Guys, please fix nfs23_validate_mount_data() and
> nfs4_validate_mount_data() to do the right thing.

The right thing, in this case, being to default to AUTH_SYS unless the
user specifies a security flavour.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

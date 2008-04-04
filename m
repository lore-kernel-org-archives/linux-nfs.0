From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 1/8] NLM/lockd: Ensure we don't corrupt fl->fl_flags in
	nlmclnt_unlock()
Date: Fri, 04 Apr 2008 15:02:44 -0400
Message-ID: <1207335765.13540.2.camel@heimdal.trondhjem.org>
References: <20080403223921.12713.71396.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
	 <20080403223921.12713.20317.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
	 <73396B15-0B3A-457E-8573-64A12197F29C@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:13759 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755437AbYDDTCs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Apr 2008 15:02:48 -0400
In-Reply-To: <73396B15-0B3A-457E-8573-64A12197F29C@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Fri, 2008-04-04 at 10:37 -0400, Chuck Lever wrote:
> It looks like nfs4_proc_unlck() also leaves the FL_EXISTS bit set.   
> Should this patch also fix nfs4_proc_unlck() ?

I checked _nfs4_proc_setlk(), but missed the fact that nfs4_proc_unlck()
messes around with the flags too. I'll fix that in a separate patch. 

Thanks for the heads-up
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

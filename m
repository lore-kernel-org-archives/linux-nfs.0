Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.14.81]:35507 "EHLO
	hackers.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756383Ab2D3THs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Apr 2012 15:07:48 -0400
Date: Mon, 30 Apr 2012 15:07:43 -0400
From: Jim Rees <rees@umich.edu>
To: bjschuma@netapp.com
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/7] NFS: Rename nfs4_proc_get_root()
Message-ID: <20120430190743.GA2461@umich.edu>
References: <1335811229-2989-1-git-send-email-bjschuma@netapp.com>
 <1335811229-2989-2-git-send-email-bjschuma@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1335811229-2989-2-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

bjschuma@netapp.com wrote:

  From: Bryan Schumaker <bjschuma@netapp.com>
  
  This function is really getting the root filehandle and not the root
  dentry of the filesystem.  I also removed the rpc_ops lookup from
  nfs4_get_rootfh() under the assumption that if we reach this function
  then we already know we are using NFS v4.

And when NFSv5 comes out?

From: Eugene Teo <eugene@redhat.com>
Subject: Re: [PATCH] nfs: Fix NFS v4 client handling of MAY_EXEC in 	nfs_permission.
Date: Tue, 19 May 2009 08:13:11 +0800
Message-ID: <4A11F997.5030602@redhat.com>
References: <1242674983.4273.8.camel@dyn9047022153>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: NFS List <linux-nfs@vger.kernel.org>,
	NFS V4 Mailing List <nfsv4@linux-nfs.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	security@kernel.org, Trond Myklebust <trond.myklebust@fys.uio.no>,
	Bruce Fields <bfields@fieldses.org>
To: Frank Filz <ffilzlnx@us.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:39193 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751854AbZESAOT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 May 2009 20:14:19 -0400
In-Reply-To: <1242674983.4273.8.camel@dyn9047022153>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Frank Filz wrote:
> Sorry for the resend, got lkml address wrong...
> 
> The problem is that permission checking is skipped if atomic open is
> possible, but when exec opens a file, it just opens it O_READONLY which
> means EXEC permission will not be checked at that time.
> 
> This problem is observed by the following sequence (executed as root):
> 
> mount -t nfs4 server:/ /mnt4
> echo "ls" >/mnt4/foo
> chmod 744 /mnt4/foo
> su guest -c "mnt4/foo"
> 
> Signed-off-by: Frank Filz <ffilzlnx@us.ibm.com>

Tested-by: Eugene Teo <eugeneteo-X4ZF2iejbADYtjvyW6yDsg@public.gmane.org>

Thanks, Eugene

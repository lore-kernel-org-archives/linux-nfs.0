From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: nfs-utils 1.1.2 + knfsd 2.6.27 (.5) breaks fsid= option
Date: Sun, 16 Nov 2008 15:02:11 -0500
Message-ID: <20081116200211.GK21551@fieldses.org>
References: <20081112104811.GA15011@janus> <491ADEBF.80900@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Frank van Maarseveen <frankvm@frankvm.com>,
	Linux NFS mailing list <linux-nfs@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:52667 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752018AbYKPUCP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 16 Nov 2008 15:02:15 -0500
In-Reply-To: <491ADEBF.80900-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 12, 2008 at 08:48:47AM -0500, Steve Dickson wrote:
> Frank van Maarseveen wrote:
> > Tested on Debian lenny with nfs-kernel-server 1:1.1.2-6lenny1 and a
> > 2.6.27.5 kernel. /etc/exports says:
> > 
> > 	/mp @general(rw,sync,no_root_squash,no_subtree_check,mp,fsid=2886795869)
> > 
> > After actually using it /proc/fs/nfsd/exports says:
> > 
> > 	/mp @general(rw,no_root_squash,sync,wdelay,no_subtree_check,fsid=-1408171427,uuid=db4387a6:bed949d0:8f5ef6a2:6a0c
> > 
> > (yes, 2886795869 == (ulong)-1408171427)
> > However, file handles over the wire now seem to have fsid_type=6
> > (FSID_UUID16) instead of 1 (FSID_NUM) due to this.
> 
> This is a known problem... The kernel checks UUIDs before FSIDS which cause
> FSIDS to be ignored. There are two outstanding proposals to fix this problem.
>    1) Move two lines in the kernel so FSIDs are checked before UUIDS
>    2) Change mountd to only send down  the FSID or the UUID but
>       not both as it does today.
>  
> Neither proposal has been accepted... yet...

I'd have a mild preference for the 2nd, but I'd first like to understand
why the new behavior is a problem for Frank.

--b.

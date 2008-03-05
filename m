From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [opensuse] nfs_update_inode: inode X mode changed, Y to Z
Date: Wed, 05 Mar 2008 16:27:42 -0500
Message-ID: <1204752463.5035.34.camel@heimdal.trondhjem.org>
References: <47CF0829.4020502@m2000.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: lkml@vger.kernel.org, linux-nfs@vger.kernel.org,
	Thomas Daniel <tdaniel-PMR2DCmmWYEAvxtiuMwx3w@public.gmane.org>, jesper.juhl@gmail.com,
	Neil Brown <neilb@suse.de>
To: Adam Schrotenboer <adam-PMR2DCmmWYEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:33313 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757270AbYCEV1q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Mar 2008 16:27:46 -0500
In-Reply-To: <47CF0829.4020502-PMR2DCmmWYEAvxtiuMwx3w@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Wed, 2008-03-05 at 12:52 -0800, Adam Schrotenboer wrote:
> Running SLES 10 on multiple compute nodes, with an OpenSuSE 10.2 NFS
> server, and I am receiving the above log message on a semi-regular basis
> in the NFS client system-logs. When this occurs, one of the users
> receives an error (although there seems to be no way to easily collate
> the users experience with the system log, short of using the timestamp).
>      Sometimes it's "read/write error", sometimes it's more specific
> about something that was a file now being a directory (SVN tends to be
> rather more verbose). Most of the time this is just a nuisance, but at 
> times (such as last week or so) it occurs so often that it blocks any 
> work getting done.
> 
>      The NFS Server is running OpenSuSE 10.2 on a Dell PowerEdge 2900 
> with the PERC5/i controller. The NFS Clients are all SLES10 with the 
> standard mountoptions, and running in TCP mode (something about UDP + 
> NFS + GbE leads to subtle data corruption).

Could you be a little bit more specific about the nature of the NFS
server: are you using knfsd or is this the legacy userland server?
Please also specify what kind of filesystem you are exporting, and the
export options you are using.

As for the client side, when do these errors occur? Have you seen them
occur after a prolonged period of use, or are they more frequent
immediately after a reboot or mount operation?

Cheers
  Trond

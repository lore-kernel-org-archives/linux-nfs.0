From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [opensuse] nfs_update_inode: inode X mode changed, Y to Z
Date: Wed, 12 Mar 2008 14:08:03 -0400
Message-ID: <1205345284.9419.8.camel@heimdal.trondhjem.org>
References: <47CF0829.4020502@m2000.com>
	 <1204752463.5035.34.camel@heimdal.trondhjem.org>
	 <47CF157B.1010908@m2000.com>	<18383.24847.381754.517731@notabene.brown>
	 <47CF62C5.7000908@m2000.com> <18384.50909.866848.966192@notabene.brown>
	 <47D0D8B5.6050403@m2000.com>  <47D818FB.8080302@m2000.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Neil Brown <neilb@suse.de>, linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org, Thomas Daniel <tdaniel-PMR2DCmmWYEAvxtiuMwx3w@public.gmane.org>,
	jesper.juhl@gmail.com, Fred Revenu <frevenu-PMR2DCmmWYEAvxtiuMwx3w@public.gmane.org>
To: Adam Schrotenboer <adam-PMR2DCmmWYEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:35403 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754145AbYCLSIG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Mar 2008 14:08:06 -0400
In-Reply-To: <47D818FB.8080302-PMR2DCmmWYEAvxtiuMwx3w@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Wed, 2008-03-12 at 10:55 -0700, Adam Schrotenboer wrote:
> Another excerpt from last night.
> 
> Mar 12 00:53:16 wanda kernel: nfs: server 192.168.1.27 not responding, 
> still trying
> Mar 12 00:53:18 wanda kernel: nfs: server 192.168.1.27 OK
> Mar 12 00:54:29 wanda kernel: nfs_update_inode: inode 1075049148 mode 
> changed, 0040755 to 0100644

Hang on. That does not look like an XID collision problem...

That code path basically means that the fileids/inode numbers match,
which would not be the case if we were talking about an XID collision
causing the reply cache to replay an old request...

That message rather symptomatic of a filehandle reuse problem. In other
words a NFS filehandle appears to be reused to label a regular file
after it has been used for a directory with the same fileid/inode
number. That is a definite server bug.

Are you sure that you are using the regular kernel nfs server?

-- 
Trond Myklebust
NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

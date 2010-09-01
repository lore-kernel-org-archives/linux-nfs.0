Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:41947 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753554Ab0IARfK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Sep 2010 13:35:10 -0400
Date: Wed, 1 Sep 2010 13:34:41 -0400
To: Greg <greg-sys@duchatelet.net>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Relocate NFS root FS for maintenance
Message-ID: <20100901173441.GB3268@fieldses.org>
References: <4C7E4469.70807@duchatelet.net>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4C7E4469.70807@duchatelet.net>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Sep 01, 2010 at 02:17:45PM +0200, Greg wrote:
>  Hi,
> 
> I don't know if it is the good place to ask for such a problem, if
> not please apologize.
> 
> I have a pseudo active/active NFSv4 configuration: 2 NFSv4 servers
> (1:1.1.2-6lenny1), exporting 3 filesystems. Each filesystem are
> connected to a SAN volume, via iscsi and multipath.
> 
> filer-01 :
> /var/local
> 10.0.0.0/16(rw,fsid=0,crossmnt,insecure,async,no_subtree_check)
> /var/local/large
> 10.0.0.0/16(rw,insecure,async,no_subtree_check,no_root_squash,fsid=3)
> 
> filer-02 :
> /var/local
> 10.0.0.0/16(rw,fsid=0,crossmnt,insecure,async,no_subtree_check)
> /var/local/small
> 10.0.0.0/16(rw,insecure,async,no_subtree_check,no_root_squash,fsid=1)
> /var/local/medium
> 10.0.0.0/16(rw,insecure,async,no_subtree_check,no_root_squash,fsid=2)
> 
> filer-01 share a volume on the first SAN, filer-02 share 2 volumes
> on the second SAN.
> 
> I have to do a firmware upgrade on the SANs, so I have to umount
> /var/local/* on the nfs servers. On way could be to relocate NFS
> root FS from /var/local to /var/maintenance with empty directories
> large, medium and small
> But how to do that ? I try to change /etc/exports then exportfs
> -rvf, but got "Stale NFS file handle" on clients...
> 
> If not, is there a better way to do that, without to shutdown NFS servers ?

I'm a little confused as to what you actually want to happen.  Clearly
clients can't continue as usual, because you're taking all the storage
away.  So presumably you expect the clients to just hang till the
upgrade is done?  If so, why not just shut down the servers?

--b.

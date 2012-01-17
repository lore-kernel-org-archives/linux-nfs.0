Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:40866 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753763Ab2AQPJD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Jan 2012 10:09:03 -0500
Date: Tue, 17 Jan 2012 10:09:01 -0500
To: Bertrand Jacquin <bjacquin@exosec.fr>
Cc: linux-nfs@vger.kernel.org
Subject: Re: I/O Wait on exportfs
Message-ID: <20120117150901.GA12274@fieldses.org>
References: <20120117142945.GA19990@lady-voodoo.exosec.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120117142945.GA19990@lady-voodoo.exosec.local>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 17, 2012 at 03:29:45PM +0100, Bertrand Jacquin wrote:
> For a specific case I have /etc/exports with 1281 entries as I need
> mount --bind to be exported to NFS Clients too.

Could you explain what you mean by that?

> Since I have ~1100 entries, reexporting /etc/exports have some bad
> effects to connected clients, load rise to ~500 for 4/5 minutes, this is
> always reproducible.
> 
> This was using 'exportfs -ra'. I did try with 'exportfs
> 192.168.0.1:/srv/mail/1234' to avoid reexport every directories, and
> the sync process but the result is the same.

Does a -t option (see rpc.mountd(8)) help?

> /etc/exports options look like :
> 
> /srv/mail      192.168.0.0/24(rw,async,no_wdelay,secure,no_root_squash,insecure_locks,no_subtree_check,nohide,crossmnt)
> /srv/mail/1234 192.168.0.0/24(rw,async,no_wdelay,no_root_squash,insecure_locks,no_subtree_check,nohide,crossmnt)

Why do you need to export both?

--b.

> 
> NFS is mounted like this on client :
> 
>  192.168.0.1:/srv/mail on /var/mail type nfs (rw,nosuid,sync,remount,noatime,nodiratime,nfsvers=3,rsize=8192,wsize=8192,hard,intr,proto=udp,nolock,actimeo=3)
> 
> Server versions:
>  Kernel: 2.6.32-bpo.5-amd64 (debian)
>  nfs-utils: 1.1.2
> 
> Client versions:
>  Kernel: 2.6.26-2-amd64 (debian)
>  nfs-utils: 1.1.2
> 
> Am I in a huge case not really intended or a configuration mistake ?
> 
> Thanks,
> Bertrand
> 
> -- 
> Bertrand Jacquin, EXOSEC (http://www.exosec.fr/)
> ZAC des Metz - 3 Rue du petit robinson - 78350 JOUY EN JOSAS
> Tel: +33 1 30 67 60 65  -  Fax: +33 1 75 43 40 70
> GSM: +33 6 71 01 70 30  -  mailto:bjacquin@exosec.fr
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

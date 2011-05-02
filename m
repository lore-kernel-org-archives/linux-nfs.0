From: NeilBrown <neilb@suse.de>
Subject: Re: rpc.statd is not running but is required
Date: Mon, 2 May 2011 18:35:47 +1000
Message-ID: <20110502183547.7e9f1295@notabene.brown>
References: <846668.33333.qm@web111707.mail.gq1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: nfs <linux-nfs@vger.kernel.org>
To: Mahmood Naderan <nt_mahmood@yahoo.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:45891 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754887Ab1EBIf4 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 May 2011 04:35:56 -0400
In-Reply-To: <846668.33333.qm-DGv3z2LcBbdeqboJWQvT7/u2YVrzzGjVVpNB7YpNyf8@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2 May 2011 00:59:01 -0700 (PDT) Mahmood Naderan
<nt_mahmood@yahoo.com> wrote:

> Hi,
> I have setup NFS and I checked every thing with documents and manual.
> After the client boots up, it says:
> =A0
> =A0
> mount.nfs: rpc.statd is not running but is required for remote lockin=
g.
> mount.nfs: Either use '-o nolock' to keep locks local, or start statd=
=2E
> mountall: mount /opt [1000] terminated with status 32

mount tried to run  /usr/sbin/start-statd and it failed for some reason=
=2E
What is in /usr/sbin/start-statd ??
What happens if you run it directly?
What happens if you just run  /usr/sbin/rpc.statd??

> =A0
> and I can not see the shared folder.
> my hosts.allow file contains:
> =A0
> =A0
> portmap: 192.168.1.0/255.255.255.0
> lockd: 192.168.1.0/255.255.255.0
> rqoutad: 192.168.1.0/255.255.255.0
> mountd: 192.168.1.0/255.255.255.0
> =A0
> =A0
> also /etc/exports contain:
> /opt=A0=A0=A0=A0=A0=A0=A0 192.168.1.0/255.255.255.0(rw,no_subtree_che=
ck,sync,no_root_squash)
> =A0
> =A0
> Any idea about that? What does '-o loop' mean?

How is that relevant?

 man 8 mount

might help you.

NeilBrown


> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


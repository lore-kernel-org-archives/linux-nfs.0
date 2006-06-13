From: Ian Kent <raven@themaw.net>
Subject: Re: [PATCH 1 / 1] Move NFS mount code from util-linux
	to	nfs-utils - take2
Date: Tue, 13 Jun 2006 10:24:55 +0800
Message-ID: <1150165495.3061.19.camel@raven.themaw.net>
References: <448DF37C.4000109@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, gud@eth.net,
	nfs@lists.sourceforge.net, Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-list2-b.sourceforge.net ([10.3.1.8]
	helo=sc8-sf-list2.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fpyal-0006yT-Sj
	for nfs@lists.sourceforge.net; Mon, 12 Jun 2006 19:25:19 -0700
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Fpyal-0006mv-Rh
	for nfs@lists.sourceforge.net; Mon, 12 Jun 2006 19:25:19 -0700
Received: from ihug-mail.icp-qv1-irony3.iinet.net.au ([203.59.1.197]
	helo=mail-ihug.icp-qv1-irony3.iinet.net.au)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Fpyaj-0003tw-Ey
	for nfs@lists.sourceforge.net; Mon, 12 Jun 2006 19:25:19 -0700
To: Amit Gud <agud@redhat.com>
In-Reply-To: <448DF37C.4000109@redhat.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Mon, 2006-06-12 at 19:06 -0400, Amit Gud wrote:
> Neil,
> 
> It avoids code duplication (of parsing the options and error checking) 
> if we don't branch two different binaries for the NFSv4 and older versions.
> 

> +
> +		if(!nomtab)
> +			add_mtab(spec, mount_point, nfs_mount_vers == 4 ? "nfs4" : "nfs",
> +				 flags, extra_opts, 0, 0);

If mtab~ is busy won't this cause mtab to get out of sync?

Ian



_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

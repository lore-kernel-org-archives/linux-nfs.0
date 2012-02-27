Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx0.aculab.com ([213.249.233.131]:38480 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753404Ab2B0QAK convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Feb 2012 11:00:10 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 17758-07 for <linux-nfs@vger.kernel.org>;
 Mon, 27 Feb 2012 16:00:04 +0000 (GMT)
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Subject: RE: [PATCH v2 2/4] NFS: release per-net clients lock before calling PipeFS dentries creation
Date: Mon, 27 Feb 2012 15:59:23 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6E7E@saturn3.aculab.com>
In-Reply-To: <20120227155103.7941.17006.stgit@localhost6.localdomain6>
From: "David Laight" <David.Laight@ACULAB.COM>
To: "Stanislav Kinsbursky" <skinsbursky@parallels.com>,
        <Trond.Myklebust@netapp.com>
Cc: <linux-nfs@vger.kernel.org>, <xemul@parallels.com>, <neilb@suse.de>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <jbottomley@parallels.com>, <bfields@fieldses.org>,
        <davem@davemloft.net>, <devel@openvz.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

 
>  	spin_lock(&nn->nfs_client_lock);
> -	list_for_each_entry(clp, &nn->nfs_client_list, cl_share_link) {
> +	list_for_each_entry_safe(clp, tmp, &nn->nfs_client_list,
cl_share_link) {
>  		if (clp->rpc_ops != &nfs_v4_clientops)
>  			continue;
> +		atomic_inc(&clp->cl_count);
> +		spin_unlock(&nn->nfs_client_lock);
>  		error = __rpc_pipefs_event(clp, event, sb);
> +		nfs_put_client(clp);
>  		if (error)
>  			break;
> +		spin_lock(&nn->nfs_client_lock);
>  	}
>  	spin_unlock(&nn->nfs_client_lock);
>  	return error;

The locking doesn't look right if the loop breaks on error.
(Same applied to patch v2 1/4)

Although list_fo_each_entry_safe() allows the current entry
to be freed, I don't believe it allows the 'next' to be freed.
I doubt there is protection against that happening.

Do you need to use an atomic_inc() for cl_count.
I'd guess the nfs_client_lock is usually held?

	David



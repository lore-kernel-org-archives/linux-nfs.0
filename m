Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx0.aculab.com ([213.249.233.131]:39749 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753318Ab2B0RM0 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Feb 2012 12:12:26 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 00601-08 for <linux-nfs@vger.kernel.org>;
 Mon, 27 Feb 2012 17:12:20 +0000 (GMT)
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Subject: RE: [PATCH v2 1/4] SUNRPC: release per-net clients lock before calling PipeFS dentries creation
Date: Mon, 27 Feb 2012 17:11:37 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6E80@saturn3.aculab.com>
In-Reply-To: <4F4BB570.60105@parallels.com>
From: "David Laight" <David.Laight@ACULAB.COM>
To: "Stanislav Kinsbursky" <skinsbursky@parallels.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: <linux-nfs@vger.kernel.org>, "Pavel Emelianov" <xemul@parallels.com>,
        <neilb@suse.de>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>,
        "James Bottomley" <jbottomley@parallels.com>, <bfields@fieldses.org>,
        <davem@davemloft.net>, <devel@openvz.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

 
> Gmmm.
> Please, correct me, if I'm wrong, that you are proposing 
> something like this:
> 
>    	spin_lock(&sn->rpc_client_lock);
> again:
> 	list_for_each_entry(clnt,&sn->all_clients, cl_clients) {
> 		if ((event == RPC_PIPEFS_MOUNT) && clnt->cl_dentry) ||
> 		    (event == RPC_PIPEFS_UMOUNT) && !clnt->cl_dentry))
> 			continue;
> 		atomic_inc(&clnt->cl_count);
> 		spin_unlock(&sn->rpc_client_lock);
>     		error = __rpc_pipefs_event(clnt, event, sb);
> 		rpc_release_client(clnt);
> 		spin_lock(&sn->rpc_client_lock);
>     		if (error)
>     			break;
> 		goto again;
>     	}
>     	spin_unlock(&sn->rpc_client_lock);

You might manage to request reference to the 'next'
item while holding the lock. So maybe a loop that has:

	error = ...
	if (error) {
		rpc_release_client(clnt);
		break;
	}
	spin_lock(&sn->rpc_client_lock);
	next_clnt = list_next(clnt);
	if (next_clnt)
		atomic_inc(&next_clnt->cl_count);
	spin_unlock(&sn->rpc_client_lock);
	rpc_release_client(clnt);
	clnt = next_clnt;
   } while (clnt != NULL);

	David



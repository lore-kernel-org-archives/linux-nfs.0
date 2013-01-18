Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:49523 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751829Ab3ARVdx convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Jan 2013 16:33:53 -0500
Content-Type: text/plain; charset=US-ASCII
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Subject: Re: Question on nfs40_discover_server_trunking.
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <50F9BE66.6080608@candelatech.com>
Date: Fri, 18 Jan 2013 16:33:45 -0500
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <0F001F0E-229D-4314-A42E-84402E4F1FC7@oracle.com>
References: <50F9BE66.6080608@candelatech.com>
To: Ben Greear <greearb@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 18, 2013, at 4:28 PM, Ben Greear <greearb@candelatech.com> wrote:

> Any chance the STALE_CLIENTID case needs a 'break'?

I don't think so.  LEASE_CONFIRM is set, and we want to wake the state renewal thread.

> 
> Twice I've seen kernel crashes after the nfs40_walk_client_list
> failed (though code comments say it should never fail).

nfs40_walk_client_list() is looking for an nfs_client that is supposed to already be in the nfs_client list.  If the search fails, that's a bug.

Eyeball the contents of your nfs_client list.  You should find an appropriate nfs_client in there, and then figure out why the search doesn't find it.


> int nfs40_discover_server_trunking(struct nfs_client *clp,
> 				   struct nfs_client **result,
> 				   struct rpc_cred *cred)
> {
> 	struct nfs4_setclientid_res clid = {
> 		.clientid = clp->cl_clientid,
> 		.confirm = clp->cl_confirm,
> 	};
> 	struct nfs_net *nn = net_generic(clp->cl_net, nfs_net_id);
> 	unsigned short port;
> 	int status;
> 
> 	port = nn->nfs_callback_tcpport;
> 	if (clp->cl_addr.ss_family == AF_INET6)
> 		port = nn->nfs_callback_tcpport6;
> 
> 	status = nfs4_proc_setclientid(clp, NFS4_CALLBACK, port, cred, &clid);
> 	if (status != 0)
> 		goto out;
> 	clp->cl_clientid = clid.clientid;
> 	clp->cl_confirm = clid.confirm;
> 
> 	status = nfs40_walk_client_list(clp, result, cred);
> 	switch (status) {
> 	case -NFS4ERR_STALE_CLIENTID:
> 		set_bit(NFS4CLNT_LEASE_CONFIRM, &clp->cl_state);
> 	case 0:
> 		/* Sustain the lease, even if it's empty.  If the clientid4
> 		 * goes stale it's of no use for trunking discovery. */
> 		nfs4_schedule_state_renewal(*result);
> 		break;
> 	}
> 
> out:
> 	return status;
> }
> 
> -- 
> Ben Greear <greearb@candelatech.com>
> Candela Technologies Inc  http://www.candelatech.com
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com





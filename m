Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.candelatech.com ([208.74.158.172]:50493 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753967Ab3ARV2U (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Jan 2013 16:28:20 -0500
Message-ID: <50F9BE66.6080608@candelatech.com>
Date: Fri, 18 Jan 2013 13:28:06 -0800
From: Ben Greear <greearb@candelatech.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Question on nfs40_discover_server_trunking.
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Any chance the STALE_CLIENTID case needs a 'break'?

Twice I've seen kernel crashes after the nfs40_walk_client_list
failed (though code comments say it should never fail).



int nfs40_discover_server_trunking(struct nfs_client *clp,
				   struct nfs_client **result,
				   struct rpc_cred *cred)
{
	struct nfs4_setclientid_res clid = {
		.clientid = clp->cl_clientid,
		.confirm = clp->cl_confirm,
	};
	struct nfs_net *nn = net_generic(clp->cl_net, nfs_net_id);
	unsigned short port;
	int status;

	port = nn->nfs_callback_tcpport;
	if (clp->cl_addr.ss_family == AF_INET6)
		port = nn->nfs_callback_tcpport6;

	status = nfs4_proc_setclientid(clp, NFS4_CALLBACK, port, cred, &clid);
	if (status != 0)
		goto out;
	clp->cl_clientid = clid.clientid;
	clp->cl_confirm = clid.confirm;

	status = nfs40_walk_client_list(clp, result, cred);
	switch (status) {
	case -NFS4ERR_STALE_CLIENTID:
		set_bit(NFS4CLNT_LEASE_CONFIRM, &clp->cl_state);
	case 0:
		/* Sustain the lease, even if it's empty.  If the clientid4
		 * goes stale it's of no use for trunking discovery. */
		nfs4_schedule_state_renewal(*result);
		break;
	}

out:
	return status;
}

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com


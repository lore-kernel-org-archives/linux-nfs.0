From: Ondrej Valousek <webserv@s3group.cz>
Subject: Re: why does each NFS mount have (at least) 2 rpc_clnt's ?
Date: Thu, 01 Apr 2010 15:26:37 +0200
Message-ID: <4BB49F0D.80009@s3group.cz>
References: <20100401084620.3475d4c0@barsoom.rdu.redhat.com>
	<1270127869.3533.12.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1270127869.3533.12.camel@localhost.localdomain>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

Does it have anything to do with the situation when we want an the same 
filesystem to be mounted twice somewhere else with a different flags? 
(i.e. RO/RW for example)
If yes, I remember some discussion about it in the past (the above was 
not possible).
Thanks,

Ondrej
> Look again at nfs_init_server_rpcclient(). The pseudoflavour is not the
> only thing that is changed. We also change the soft flag and the timeout
> properties of the server->client.
>
> The point is that users sometimes want to specify per-mountpoint
> transport properties, and so we try to give them that possibility, while
> at the same time sharing sockets/rdma connections.
>
> Cheers
>   Trond
>
> _______________________________________________
> NFSv4 mailing list
> NFSv4@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
>   

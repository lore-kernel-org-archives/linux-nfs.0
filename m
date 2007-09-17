From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 01/10] mount.nfs: Provide comments for
	public	network functions
Date: Mon, 17 Sep 2007 12:46:33 -0400
Message-ID: <1190047593.6700.93.camel@heimdal.trondhjem.org>
References: <20070917162842.25850.7104.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, nfs@lists.sourceforge.net
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IXJk7-0003En-Uo
	for nfs@lists.sourceforge.net; Mon, 17 Sep 2007 09:46:40 -0700
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IXJkC-0006f0-1v
	for nfs@lists.sourceforge.net; Mon, 17 Sep 2007 09:46:44 -0700
In-Reply-To: <20070917162842.25850.7104.stgit@monet.1015granger.net>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Mon, 2007-09-17 at 12:28 -0400, Chuck Lever wrote:
> Clean up: Document public functions in util/mount/network.c with block
> comments.

Just out of curiosity. I see that you've used the kernel 'docbook'
format in your comments. Are there any plans to port the kernel
documentation mechanism to nfs-utils, or is there perhaps a public
utility that can make use of this format?

Cheers
  Trond

> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  utils/mount/network.c |   42 +++++++++++++++++++++++++++++++++++++-----
>  1 files changed, 37 insertions(+), 5 deletions(-)
> 
> diff --git a/utils/mount/network.c b/utils/mount/network.c
> index 16b802d..49d3c6b 100644
> --- a/utils/mount/network.c
> +++ b/utils/mount/network.c
> @@ -139,6 +139,13 @@ static const unsigned long probe_mnt3_first[] = {
>  	0,
>  };
>  
> +/**
> + * nfs_gethostbyname - resolve a hostname to an IPv4 address
> + * @hostname: pointer to a C string containing a DNS hostname
> + * @saddr: returns an IPv4 address 
> + *
> + * Returns 1 if successful, otherwise zero.
> + */
>  int nfs_gethostbyname(const char *hostname, struct sockaddr_in *saddr)
>  {
>  	struct hostent *hp;
> @@ -457,6 +464,16 @@ static int probe_mntport(clnt_addr_t *mnt_server)
>  		return probe_port(mnt_server, probe_mnt1_first, probe_udp_only);
>  }
>  
> +/**
> + * probe_bothports - discover the RPC endpoints of mountd and NFS server
> + * @mnt_server: pointer to address and pmap argument for mountd results
> + * @nfs_server: pointer to address and pmap argument for NFS server
> + *
> + * Returns 1 if successful, otherwise zero if some error occurred.
> + * Note that the arguments are both input and output arguments.
> + *
> + * A side effect of calling this function is that rpccreateerr is set.
> + */
>  int probe_bothports(clnt_addr_t *mnt_server, clnt_addr_t *nfs_server)
>  {
>  	struct pmap *nfs_pmap = &nfs_server->pmap;
> @@ -524,8 +541,10 @@ static int probe_statd(void)
>  	return 1;
>  }
>  
> -/*
> - * Attempt to start rpc.statd
> +/**
> + * start_statd - attempt to start rpc.statd
> + *
> + * Returns 1 if statd is running; otherwise zero.
>   */
>  int start_statd(void)
>  {
> @@ -549,7 +568,7 @@ int start_statd(void)
>  	return 0;
>  }
>  
> -/*
> +/**
>   * nfs_call_umount - ask the server to remove a share from it's rmtab
>   * @mnt_server: address of RPC MNT program server
>   * @argp: directory path of share to "unmount"
> @@ -593,6 +612,13 @@ int nfs_call_umount(clnt_addr_t *mnt_server, dirpath *argp)
>  	return 0;
>  }
>  
> +/**
> + * mnt_openclnt - get a handle for a remote mountd service
> + * @mnt_server: address and pmap arguments of mountd service
> + * @msock: returns a file descriptor of the underlying transport socket
> + *
> + * Returns an active handle for the remote's mountd service
> + */
>  CLIENT *mnt_openclnt(clnt_addr_t *mnt_server, int *msock)
>  {
>  	struct sockaddr_in *mnt_saddr = &mnt_server->saddr;
> @@ -634,6 +660,12 @@ CLIENT *mnt_openclnt(clnt_addr_t *mnt_server, int *msock)
>  	return NULL;
>  }
>  
> +/**
> + * mnt_closeclnt - terminate a handle for a remote mountd service
> + * @clnt: pointer to an active handle for a remote mountd service
> + * @msock: file descriptor of the underlying transport socket
> + *
> + */
>  void mnt_closeclnt(CLIENT *clnt, int msock)
>  {
>  	auth_destroy(clnt->cl_auth);
> @@ -641,7 +673,7 @@ void mnt_closeclnt(CLIENT *clnt, int msock)
>  	close(msock);
>  }
>  
> -/*
> +/**
>   * clnt_ping - send an RPC ping to the remote RPC service endpoint
>   * @saddr: server's address
>   * @prog: target RPC program number
> @@ -729,7 +761,7 @@ int clnt_ping(struct sockaddr_in *saddr, const unsigned long prog,
>  		return 0;
>  }
>  
> -/*
> +/**
>   * get_client_address - acquire our local network address
>   * @saddr: server's address
>   * @caddr: filled in with our network address
> 
> 
> -------------------------------------------------------------------------
> This SF.net email is sponsored by: Microsoft
> Defy all challenges. Microsoft(R) Visual Studio 2005.
> http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

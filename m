From: Neil Brown <neilb@suse.de>
Subject: Re: [RFC,
	PATCH 33/33] knfsd: Support adding transports by writing portlist
	file
Date: Fri, 28 Sep 2007 14:48:56 +1000
Message-ID: <18172.34744.784138.666846@notabene.brown>
References: <20070927045751.12677.98896.stgit@dell3.ogc.int>
	<20070927050243.12677.15463.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, gnb@sgi.com
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ib7me-00085v-Fl
	for nfs@lists.sourceforge.net; Thu, 27 Sep 2007 21:49:00 -0700
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Ib7mi-0001yA-Sl
	for nfs@lists.sourceforge.net; Thu, 27 Sep 2007 21:49:05 -0700
In-Reply-To: message from Tom Tucker on Thursday September 27
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

On Thursday September 27, tom@opengridcomputing.com wrote:
> 
> Update the write handler for the portlist file to allow creating new
> listening endpoints on a transport. The general form of the string is:
> 
> <transport_name><space><port number>
> 
> For example:
> 
> tcp 2049
> 
> This is intended to support the creation of a listening endpoint for
> RDMA transports without adding #ifdef code to the nfssvc.c file.
> The general idea is that the rpc.nfsd program would read the transports
> file and then write the portlist file to create listening endpoints
> for all or selected transports. The current mechanism of writing an
> fd would become obsolete.

Nuh.
I'll only accept
      rdma 2049
(or whatever) because there seems to be no other way to do it.
Writing an 'fd' is the *preferred* way.

There is more to binding an endpoint than protocol and port number.
There is also local address and I'm not convinced that someone might
come up with some other way they want to pre-condition a socket.

If there was any way to associate an RDMA endpoint with a
filedescriptor, I would much prefer that 'rpc.nfsd' does that and passes
down the filedescriptor.  If RDMA is so no-Unix-like (rant rant..)
that there is no such file descriptor, then I guess we can live with 
getting the kernel to open the connection.


> 
> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> ---
> 
>  fs/nfsd/nfsctl.c |   16 ++++++++++++++++
>  1 files changed, 16 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> index baac89d..923b817 100644
> --- a/fs/nfsd/nfsctl.c
> +++ b/fs/nfsd/nfsctl.c
> @@ -554,6 +554,22 @@ static ssize_t write_ports(struct file *
>  		kfree(toclose);
>  		return len;
>  	}
> +	/*
> +	 * Add a transport listener by writing it's transport name
> +	 */
> +	if (isalnum(buf[0])) {

Should really be "isalpha" as we already know it isn't isdigit.

NeilBrown


> +		int err;
> +		char transport[16];
> +		int port;
> +		if (sscanf(buf, "%15s %4d", transport, &port) == 2) {
> +			err = nfsd_create_serv();
> +			if (!err)
> +				err = svc_create_xprt(nfsd_serv,
> +						      transport, port,
> +						      SVC_SOCK_ANONYMOUS);
> +			return err < 0 ? err : 0;
> +		}
> +	}
>  	return -EINVAL;
>  }
>  

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

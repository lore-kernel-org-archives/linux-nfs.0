From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] nfsd: select CONFIG_PROC_FS in nfsv4 and
	gss	server cases
Date: Thu, 15 Nov 2007 17:06:36 -0500
Message-ID: <1195164396.8905.62.camel@heimdal.trondhjem.org>
References: <1195163823-24609-1-git-send-email-bfields@citi.umich.edu>
	<1195163823-24609-2-git-send-email-bfields@citi.umich.edu>
	<1195163823-24609-3-git-send-email-bfields@citi.umich.edu>
	<1195163823-24609-4-git-send-email-bfields@citi.umich.edu>
	<1195163823-24609-5-git-send-email-bfields@citi.umich.edu>
	<1195163823-24609-6-git-send-email-bfields@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org,
	nfs@lists.sourceforge.net
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <nfs-bounces@lists.sourceforge.net>
In-Reply-To: <1195163823-24609-6-git-send-email-bfields@citi.umich.edu>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net
List-ID: <linux-nfs.vger.kernel.org>


On Thu, 2007-11-15 at 16:57 -0500, J. Bruce Fields wrote:
> The server depends on upcalls under /proc to support nfsv4 and gss.
> 
> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> ---
>  fs/Kconfig |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/Kconfig b/fs/Kconfig
> index 429a002..340b233 100644
> --- a/fs/Kconfig
> +++ b/fs/Kconfig
> @@ -1670,6 +1670,8 @@ config NFSD
>  	select CRYPTO_MD5 if NFSD_V4
>  	select CRYPTO if NFSD_V4
>  	select FS_POSIX_ACL if NFSD_V4
> +	select PROC_FS if NFSD_V4
> +	select PROC_FS if SUNRPC_GSS
>  	help
>  	  If you want your Linux box to act as an NFS *server*, so that other
>  	  computers on your local network which support NFS can access certain

What if you just want it to act as a client? No need for PROC_FS then...

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

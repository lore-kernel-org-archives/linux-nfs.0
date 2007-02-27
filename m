From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 06/11] nfs-utils: mount:  AUTH_NONE mounts
Date: Tue, 27 Feb 2007 17:14:29 +1100
Message-ID: <17891.52293.103984.465480@notabene.brown>
References: <45E2C1FD.7000506@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HLvcY-0003C8-LW
	for nfs@lists.sourceforge.net; Mon, 26 Feb 2007 22:15:30 -0800
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HLvcX-00076i-E6
	for nfs@lists.sourceforge.net; Mon, 26 Feb 2007 22:15:29 -0800
In-Reply-To: message from Steve Dickson on Monday February 26
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

On Monday February 26, SteveD@redhat.com wrote:
> commit 0ffd74c990aca3761b79316d47e1b1778273681c
> Author: Steve Dickson <steved@redhat.com>
> Date:   Sat Feb 24 15:27:46 2007 -0500
> 
>     Added support to specify the AUTH_NONE security flavor (i.e. -o sec=none)

If you specify "-o sec=none" then data.pseudoflavor will == AUTH_NONE,
but

>     
>     Signed-off-by: Steve Dickson <steved@redhat.com>
> 
> diff --git a/utils/mount/nfsmount.c b/utils/mount/nfsmount.c
> index d437036..7759260 100644
> --- a/utils/mount/nfsmount.c
> +++ b/utils/mount/nfsmount.c
> @@ -1093,12 +1093,14 @@ nfsmount(const char *spec, const char *node, int *flags,
>  
>  		flavor = mountres->auth_flavors.auth_flavors_val;
>  		while (--i >= 0) {
> -			if (flavor[i] == data.pseudoflavor)
> -				yum = 1;
>  #ifdef NFS_MOUNT_DEBUG
> -			printf("auth flavor %d: %d\n",
> -				i, flavor[i]);
> +			printf("auth flavor[%d] %d\n", i, flavor[i]);
>  #endif
> +			if (flavor[i] == data.pseudoflavor ||
> +				flavor[i] == AUTH_NONE) {
> +				yum = 1;
> +				break;
> +			}

You are testing if flavor[i] == AUTH_NONE, which doesn't make sense to
me....

NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

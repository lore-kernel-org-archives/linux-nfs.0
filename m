From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: nfssvc: Permission denied
Date: Tue, 19 Nov 2002 15:47:32 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15833.49764.873851.3047@notabene.cse.unsw.edu.au>
References: <1037370050.3dd502c24af77@webmail.lphp.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18E0Ig-0003k3-00
	for <nfs@lists.sourceforge.net>; Mon, 18 Nov 2002 20:47:50 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.233.204] == wireless-204.wireless.cse.unsw.EDU.AU)
	(for <ajacoutot@lphp.org>) (for <nfs@lists.sourceforge.net>) By tone
	With Smtp ; Tue, 19 Nov 2002 15:47:33 +1100
To: Antoine Jacoutot <ajacoutot@lphp.org>
In-Reply-To: message from Antoine Jacoutot on Friday November 15
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Friday November 15, ajacoutot@lphp.org wrote:
> Hi,  
>  
> I'm using NFS under Gentoo Linux with kernel-2.4.19. 
> When starting nfs server with nfs init script (from nfs-utils), I get the  
> following message:  
>  
> /etc/init.d/nfs start  
> [ok ] * Starting NFS statd...  
> [ ok ] * Starting NFS rquotad...  
> [ ok ] * Starting NFS daemon...  
> nfssvc: Permission denied  

It looks like you are not running this as root.  You need to.

NeilBrown

> * Error starting NFS daemon  
> [ !! ]  
> * Starting NFS mountd...  
>  
> The modules are correctly loaded:  
> nfsd 61136 0 (autoclean)  
> lockd 44080 0 (autoclean) [nfsd]  
> sunrpc 60796 0 (autoclean) [nfsd lockd]  
>  
> This error is happening on all my servers, whether the nfs is user-space  
> or kernel-space.  
>  
> There's nothing in the logs except someting about the portmapper (in 
> auth.log):  
> Oct 7 07:03:09 srv01 portmap[29402]: connect from 127.0.0.1 to set(nfs):  
> request from unprivileged port  
> Oct 7 07:03:09 srv01 portmap[21158]: connect from 127.0.0.1 to unset(nfs):  
> request from unprivileged port  
> Oct 7 07:04:40 srv01 portmap[1765]: connect from 127.0.0.1 to set(nfs): 
> request  
> from unprivileged port  
>  
> Portmap is running and I have nfs-utils-0.3.3-r1. 
>  
> Thanks in advance if you have any clue. 
> I've search Google and didn't find anything usefull (this errors appears to 
> happen on old Linux kernels, but I'm using the lastest stable). 
>  
> --  
> Antoine Jacoutot 
> Gentoo Linux 
> ajacoutot@lphp.org 
> http://www.lphp.org 
>  
>  
>  
> 
> 
> -------------------------------------------------------
> This sf.net email is sponsored by: To learn the basics of securing
> your web site with SSL, click here to get a FREE TRIAL of a Thawte
> Server Certificate: http://www.gothawte.com/rd524.html
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------
This sf.net email is sponsored by: To learn the basics of securing 
your web site with SSL, click here to get a FREE TRIAL of a Thawte 
Server Certificate: http://www.gothawte.com/rd524.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

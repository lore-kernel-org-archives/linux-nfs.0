From: Chip Salzenberg <chip@pobox.com>
Subject: Re: remount error: 'unknown nfs mount option: v3'
Date: Tue, 29 Jul 2003 15:06:03 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030729220602.GA18733@perlsupport.com>
References: <20030728063639.GD2204@tenet.res.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tandu.perlsupport.com ([66.220.6.226] ident=mail)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19hccM-0000zD-00
	for <nfs@lists.sourceforge.net>; Tue, 29 Jul 2003 15:06:50 -0700
To: Nitin Chandrachoodan <nitin@tenet.res.in>
In-Reply-To: <20030728063639.GD2204@tenet.res.in>
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

According to Nitin Chandrachoodan:
>   mount -n -o remount,rw /
>   mount -n -o remount,rw /usr
> 
> the second mount fails with "unknown nfs mount option: v3".
> 
> /etc/mtab is linked to /proc/mounts.

That's not really a supported configuration, AFAIK.  While /etc/mtab
and /proc/mounts are obviously similar, they're not identical, and
you've run into one of the results.

That said, I really can't fathom why mount wants "vers=3" but refuses
to accept "v3", while the kernel only reports "v3".  It seems like a
pointless inconsistency.  Why not have mount accept "v2", "v3", and
"v4" as synoyms for the corresponding "vers=" values?
-- 
Chip Salzenberg               - a.k.a. -               <chip@pobox.com>
"I wanted to play hopscotch with the impenetrable mystery of existence,
    but he stepped in a wormhole and had to go in early."  // MST3K


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

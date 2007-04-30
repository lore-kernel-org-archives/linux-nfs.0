From: Gabriel Barazer <gabriel@oxeva.fr>
Subject: Re: Rpc.mountd growing 6 MB/day
Date: Mon, 30 Apr 2007 19:47:52 +0200
Message-ID: <46362BC8.9040305@oxeva.fr>
References: <37B62E0F71C9E14B9859FADB1FC3E3E133E51B@ala-mail02.corp.ad.wrs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Kottaridis, Chris" <chris.kottaridis@windriver.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HiZzG-0000gZ-Qs
	for nfs@lists.sourceforge.net; Mon, 30 Apr 2007 10:48:34 -0700
Received: from mail.reagi.com ([195.60.188.80])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HiZz5-0004DV-VK
	for nfs@lists.sourceforge.net; Mon, 30 Apr 2007 10:48:37 -0700
In-Reply-To: <37B62E0F71C9E14B9859FADB1FC3E3E133E51B@ala-mail02.corp.ad.wrs.com>
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

I have this problem too for a long time and already reported it, but 
propably forgotten. My rpc.mountd is actually 350MB and continue 
growing, with nfs-utils 1.1.0-rc2:

# rpc.mountd --version
kmountd 1.1.0-rc2

# top
  2259 root      15   0  340m 331m  744 S  0.0 16.5   0:20.12 rpc.mountd

I already provided a copy of the /proc/<pid>/smaps which show the main 
problem :
00514000-15033000 rw-p 00514000 00:00 0 
  [heap]
Size:            339068 kB
Rss:             338204 kB

I think there is a memory leak here.

Gabriel Barazer

On 04/30/2007 19:41:07 +0200, "Kottaridis, Chris" 
<chris.kottaridis@windriver.com> wrote:

> I have a situation where rpc.mountd is growing continuously and I am not 
> sure if it's a memory leak or expected behavior that can be controlled 
> with some configuration option.
>  
> Top is used to watch rpc.mountd over time and I can see Virtual size 
> continually growing. In this environment there is no swap space so RSS 
> is growing also. When RSS gets close to Virtual size,  Virtual size 
> jumps up by 128K until RSS again "catches up" to VIRTUAL which then 
> jumps up by 128K again:
>  
>  
>                               VIRT  RES
> 9951 root      16   0  1812 1052  668 S  0.0  0.0   0:20.07 rpc.mountd 
> --nfs-version 2 --nfs-version 3
>  9951 root      16   0  1812 1052  668 S  0.0  0.0   0:20.19 rpc.mountd 
> --nfs-version 2 --nfs-version 3
>  9951 root      15   0  1812 1052  668 S  0.0  0.0   0:20.44 rpc.mountd 
> --nfs-version 2 --nfs-version 3
>  9951 root      15   0  1940 1056  668 S  0.0  0.0   0:20.57 rpc.mountd 
> --nfs-version 2 --nfs-version 3
>  9951 root      16   0  1940 1056  668 S  0.0  0.0   0:20.69 rpc.mountd 
> --nfs-version 2 --nfs-version 3
>  9951 root      16   0  1940 1056  668 S  0.0  0.0   0:20.70 rpc.mountd 
> --nfs-version 2 --nfs-version 3
>  
> RES keeps incrementing every so often and eventually:
>  
>                                VIRT RES
>  9951 root      16   0  1940 1180  668 S  0.0  0.0   0:38.85 rpc.mountd 
> --nfs-version 2 --nfs-version 3
>  9951 root      16   0  1940 1180  668 S  0.0  0.0   0:38.99 rpc.mountd 
> --nfs-version 2 --nfs-version 3
>  9951 root      16   0  2068 1184  668 S  0.0  0.0   0:39.14 rpc.mountd 
> --nfs-version 2 --nfs-version 3
>  9951 root      16   0  2068 1184  668 S  0.0  0.0   0:39.33 rpc.mountd 
> --nfs-version 2 --nfs-version 3
>  
> This pattern continues.
>  
> I added some xlog() statements in rpc.mountd to try and show me if there 
> were some malloc's without free's. I didn't see anything, but here are 
> the routines that seemed to get called frequently:
>  
> Apr 26 18:55:13 unit0 mountd[24268]: auth_unix_ip client alloced 0x80695e0
> Apr 26 18:55:13 unit0 mountd[24268]: auth_unix_ip client freed 0x80695e0
> Apr 26 18:55:13 unit0 mountd[24268]: nfsd_export alocated dom 0x80695e0
> Apr 26 18:55:13 unit0 mountd[24268]: nfsd_export alocated path 0x80695f0
> Apr 26 18:55:13 unit0 mountd[24268]: nfsd_export : free dom 0x80695e0
> Apr 26 18:55:13 unit0 mountd[24268]: nfsd_export : free path 0x80695f0
> Apr 26 18:55:13 unit0 mountd[24268]: nfsd_fh : dom allocated 0x8069600
> Apr 26 18:55:13 unit0 mountd[24268]: nfsd_fh : freed dom 0x8069600
> Apr 26 19:10:33 unit0 mountd[24268]: auth_unix_ip client alloced 0x8069618
> Apr 26 19:10:33 unit0 mountd[24268]: auth_unix_ip client freed 0x8069618
> Apr 26 19:10:33 unit0 mountd[24268]: nfsd_export alocated dom 0x8069618
> Apr 26 19:10:33 unit0 mountd[24268]: nfsd_export alocated path 0x8069628
> Apr 26 19:10:33 unit0 mountd[24268]: nfsd_export : free dom 0x8069618
> Apr 26 19:10:33 unit0 mountd[24268]: nfsd_export : free path 0x8069628
> Apr 26 19:10:33 unit0 mountd[24268]: nfsd_fh : dom allocated 0x8069638
> Apr 26 19:10:33 unit0 mountd[24268]: nfsd_fh : freed dom 0x8069638
>  
> It seems to be these three routines that get called over and over, at 
> least so far that I have added xlog()'s to. These seem to be making some 
> interactions with the kernel nfsd via /proc, but I am not real sure how 
> that would impact rpc.mountd's virtual size.
>  
> I am using the kernel NFSD, the kernel version is 2.6.10, the nfs-utils 
> version is nfs-utils-1.0.7
>  
> I don't know if this growth is expected or if it will eventually stop, 
> over a period of days it has not stopped growing, and if there may be 
> some configuration option that can control it.
>  
> Has anyone seen this behavior before ?
>  
> Is it expected and controllable or is there a memory leak here ?
>  
> Thanks
>  
> Chris Kottaridis
> Senior Engineer
> Wind River Systems
> 719-522-9786
>  
> 
> 
> ------------------------------------------------------------------------
> 
> -------------------------------------------------------------------------
> This SF.net email is sponsored by DB2 Express
> Download DB2 Express C - the FREE version of DB2 express and take
> control of your XML. No limits. Just data. Click to get it now.
> http://sourceforge.net/powerbar/db2/
> 
> 
> ------------------------------------------------------------------------
> 
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

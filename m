From: Ryan Sweet <rsweet@atos-group.nl>
Subject: 2.4.18 knfsd load spikes
Date: Wed, 15 May 2002 14:53:29 +0200 (MEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.30.0205151421340.19272-100000@whitby.atos-group.nl>
References: <Pine.LNX.4.30.0205141435360.2723-100000@whitby.atos-group.nl>
Reply-To: Ryan Sweet <rsweet@atos-group.nl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [62.58.73.254] (helo=ats-core-0.atos-group.nl)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 177yHS-0000QH-00
	for <nfs@lists.sourceforge.net>; Wed, 15 May 2002 05:53:23 -0700
Received: from whitby (IDENT:rsweet@whitby [192.168.1.146])
	by ats-core-0.atos-group.nl (8.11.0/8.11.0) with ESMTP id g4FCfr401885
	for <nfs@lists.sourceforge.net>; Wed, 15 May 2002 14:41:53 +0200
To: <nfs@lists.sourceforge.net>
In-Reply-To: <Pine.LNX.4.30.0205141435360.2723-100000@whitby.atos-group.nl>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>


I didn't get any responses to the message below, but I _did_ bite the
bullet and update the IRIX systems, and now the 64bit filehandle problem
is solved.

However, the performance problem is not.  With 2.4.18+xfs1.1, It is
definitely better (the load spikes to 7 or 8, sometimes 10, instead of 20
or 30...), but I still get the periods where suddenly the system will
respond _very_ slowly, cpu is mostly idle, memory is all used, but only
for cache, the system is not swapping at all, but the load climbs up and
up.  It then gradually falls back down.  The top processes are usually
bdflush and kupdated, with kupdated always in the dead wait (DW) state.
It is basically the same behaviour that we saw with 2.4.[2|5]+xfs1.0.2,
though not as painful.  The problem usually lasts for 3 or four minutes,
then subsides.

The problem seemed to begin around the time we added a few new, really
fast compute workstations, each of which is periodically doing thousands
of small writes/reads.  I cannot yet make a direct correlation, however,
until I can get a decent tcpdump.

does anyone have any pointers on where to begin looking?  Have other
people seen this behaviour?

thanks,
-Ryan

On Tue, 14 May 2002, Ryan Sweet wrote:

>
> I have been running a server with 2.4.2+xfs-1.0.2 and the IRIX client
> patch (posted on this list a while back, to fix problems with IRIX
> clients and 64bit filehandles, included below) successfully for quite a
> while.
>
> The server is a dual PIII 733/256MB system with an adaptec 29xx UW160 card
> and an external SkyRAID array.
>
> Recently, after adding several new and _very_ fast client machines
> (several dual xeon 2.2 gigahertz systems, running 2.4.9-31 redhat kernel)
> that are doing thousands of small writes, all at once, the performance has
> started to really suck for periods of two/three minutes at a time.  the
> load will go up to 30+, the kernel will be thrashing in bdflush mostly,
> and then eventually the load will come back down again.
>
> Updating to 2.4.18+XFS-1.1 appears to have solved that problem (hard to
> say for sure since it is intermittent, however if we apply the IRIX client
> workaround patch then we get almost immediate oopses all over the nfs
> server components.  Here are some:
> May 13 22:53:47 ats-data-1 kernel: Unable to handle kernel NULL pointer
> dereference at virtual address 00000000
> May 13 22:53:47 ats-data-1 kernel:  printing eip:
> May 13 22:53:47 ats-data-1 kernel: c01831e3
> May 13 22:53:47 ats-data-1 kernel: *pde = 00000000
> May 13 22:53:47 ats-data-1 kernel: Oops: 0002
> May 13 22:53:47 ats-data-1 kernel: CPU:    1
> May 13 22:53:47 ats-data-1 kernel: EIP:    0010:[fh_compose+483/788]
> Not tainted
> May 13 22:53:47 ats-data-1 kernel: EFLAGS: 00010203
> May 13 22:53:47 ats-data-1 kernel: eax: 00000040   ebx: d83dc094   ecx:
> d83dc0a4   edx: 00000004
> May 13 22:53:47 ats-data-1 kernel: esi: dd535eb8   edi: 00000000   ebp:
> dd6b59e0   esp: dd535e7c
> May 13 22:53:47 ats-data-1 kernel: ds: 0018   es: 0018   ss: 0018
> May 13 22:53:47 ats-data-1 kernel: Process nfsd (pid: 723,
> stackpage=dd535000)
> May 13 22:53:47 ats-data-1 kernel: Stack: 00000006 dd6b59e0 cb0980c8
> d83dc004 dd6b59e0 cb0980ce 84e67838 cb0980c8
> May 13 22:53:47 ats-data-1 kernel:        d83dc004 c014242f dd535eb4
> da053820 00000006 d83dc0a4 d8985b60 0000000d
> May 13 22:53:47 ats-data-1 kernel:        c0183cf1 d83dc094 d6b2d000
> dd6b59e0 d83dc004 d83dc004 00000006 cb0980c8
> May 13 22:53:47 ats-data-1 kernel: Call Trace: [lookup_one_len+87/104]
> [nfsd_lookup+945/1000] [nfsd3_proc_lookup+331/348]
> [nfs3svc_decode_diropargs+152/260] [nfsd_dispatch+203
> /402]
> May 13 22:53:48 ats-data-1 kernel:    [svc_process+653/1308]
> [nfsd+428/856] [kernel_thread+35/48]
> May 13 22:53:48 ats-data-1 kernel:
> May 13 22:53:48 ats-data-1 kernel: Code: c7 07 00 00 00 00 83 c7 04 4a 79
> f4 8b 55 08 8b 4c 24 48 8b
> M
>
> May 14 14:02:17 ats-data-0 rpc.mountd: authenticated mount request from
> iapp-0:749 for /exportB/home (/exportB)
> May 14 14:02:17 ats-data-0 kernel: Unable to handle kernel NULL pointer
> dereference at virtual address 00000000
> May 14 14:02:17 ats-data-0 kernel:  printing eip:
> May 14 14:02:17 ats-data-0 kernel: c01831e3
> May 14 14:02:17 ats-data-0 kernel: *pde = 00000000
> May 14 14:02:17 ats-data-0 kernel: Oops: 0002
> May 14 14:02:17 ats-data-0 kernel: CPU:    0
> May 14 14:02:17 ats-data-0 kernel: EIP:    0010:[fh_compose+483/788]
> Not tainted
> May 14 14:02:17 ats-data-0 kernel: EFLAGS: 00010203
> May 14 14:02:17 ats-data-0 kernel: eax: 00000040   ebx: de9c5e8c   ecx:
> de9c5e9c   edx: 00000004
> May 14 14:02:17 ats-data-0 kernel: esi: de9c5e50   edi: 00000000   ebp:
> dd1b9940   esp: de9c5e14
> May 14 14:02:17 ats-data-0 kernel: ds: 0018   es: 0018   ss: 0018
> May 14 14:02:17 ats-data-0 kernel: Process rpc.mountd (pid: 751,
> stackpage=de9c5000)
> May 14 14:02:17 ats-data-0 kernel: Stack: de9c5e8c 00000083 de9c5f1c
> cac02800 019cc780 dd1b9940 c0141f18 de694320
> May 14 14:02:18 ats-data-0 kernel:        de9c5f1c 00000000 cc3b2000
> cac02800 c0186582 de9c5e9c dd1679a0 0000000d
> May 14 14:02:18 ats-data-0 kernel:        c0186d06 de9c5e8c cac02800
> dd1b9940 00000000 0000041c cc3b2004 cc3b2000
> May 14 14:02:18 ats-data-0 kernel: Call Trace: [link_path_walk+1872/2072]
> [exp_parent+50/68] [exp_rootfh+538/632] [sys_nfsservctl+878/1028] [filp_cl
> ose+156/168]
> May 14 14:02:18 ats-data-0 kernel:    [sys_close+91/112]
> [system_call+51/56]
> May 14 14:02:18 ats-data-0 kernel:
> May 14 14:02:18 ats-data-0 kernel: Code: c7 07 00 00 00 00 83 c7 04 4a 79
> f4 8b 55 08 8b 4c 24 48 8b
>
> I assume then that this patch (below) needs to be updated somewhere for
> 2.4.18.  I tried diving in to see if I could figure out where/why/etc...,
> but I have to admit that I do not see what is broken.
>
> Is there a newer version of the IRIX nfs client patch (IIRC Neil has said
> it would not ever go into the kernel because it was a temporary workaround
> for a bug in IRIX - the problem does not occur with IRIX 6.5.14+)?
>
> If not, does someone see what needs to be changed/fixed, etc...?
>
> Here is the patch:
> *** fs/nfsd/nfsfh.c	2001/02/14 03:20:12	1.1
> --- fs/nfsd/nfsfh.c	2001/02/14 04:23:40
> ***************
> *** 699,705 ****
>    * an inode.  In this case a call to fh_update should be made
>    * before the fh goes out on the wire ...
>    */
> ! inline int _fh_update(struct dentry *dentry, struct svc_export *exp,
>   		      __u32 **datapp, int maxsize)
>   {
>   	__u32 *datap= *datapp;
> --- 699,705 ----
>    * an inode.  In this case a call to fh_update should be made
>    * before the fh goes out on the wire ...
>    */
> ! inline int _fh_update2(struct dentry *dentry, struct svc_export *exp,
>   		      __u32 **datapp, int maxsize)
>   {
>   	__u32 *datap= *datapp;
> ***************
> *** 717,723 ****
>   	*datapp = datap;
>   	return 2;
>   }
> !
>   int
>   fh_compose(struct svc_fh *fhp, struct svc_export *exp, struct dentry *dentry)
>   {
> --- 717,733 ----
>   	*datapp = datap;
>   	return 2;
>   }
> ! inline int _fh_update(struct dentry *dentry, struct svc_export *exp,
> ! 		      __u32 **datapp, int maxsize)
> ! {
> !     __u32 *datap = *datapp;
> !     int i;
> !     for (i=3;i<8;i++)
> ! 	*datap++ = 0;
> !     i = _fh_update2(dentry, exp, datapp, maxsize);
> !     *datapp = datap;
> !     return i;
> ! }
>   int
>   fh_compose(struct svc_fh *fhp, struct svc_export *exp, struct dentry *dentry)
>   {
>
>
>

-- 
Ryan Sweet <ryan.sweet@atosorigin.com>
Atos Origin Engineering Services
http://www.aoes.nl



_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Jeff Layton <jlayton@redhat.com>
Subject: Re: linux-next NFSD: NULL pointer dereference at nfsd_svc()
Date: Mon, 2 Aug 2010 10:36:20 -0400
Message-ID: <20100802103620.5638dac1@corrin.poochiereds.net>
References: <201008020747.o727lqXs064715@www262.sakura.ne.jp>
	<20100802103214.7eea09eb@corrin.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	linux-nfs@vger.kernel.org, bfields@fieldses.org,
	linux-fsdevel@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20100802103214.7eea09eb@corrin.poochiereds.net>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2 Aug 2010 10:32:14 -0400
Jeff Layton <jlayton@redhat.com> wrote:

> On Mon, 02 Aug 2010 16:47:52 +0900
> Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> wrote:
> 
> > Hello.
> > 
> > I got below failure on Debian Sarge when starting /usr/sbin/rpc.nfsd .
> > 2.6.35 works fine.
> > Kernel config is at http://I-love.SAKURA.ne.jp/tmp/config-2.6.35-next-20100802
> > Regards.
> > 
> > 
> > [   26.081814] pcnet32 0000:02:00.0: eth0: link up
> > [   36.349815] BUG: unable to handle kernel NULL pointer dereference at 0000002c
> > [   36.351254] IP: [<c11455a6>] nfsd_svc+0x56/0x110
> > [   36.351398] *pde = 00000000 
> > [   36.351398] Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
> > [   36.351398] last sysfs file: /sys/devices/pci0000:00/0000:00:10.0/host0/target0:0:1/0:0:1:0/type
> > [   36.351398] Modules linked in: pcnet32
> > [   36.351398] 
> > [   36.351398] Pid: 2615, comm: rpc.nfsd Tainted: G        W   2.6.35-next-20100802 #2 440BX Desktop Reference Platform/VMware Virtual Platform
> > [   36.351398] EIP: 0060:[<c11455a6>] EFLAGS: 00010202 CPU: 0
> > [   36.351398] EIP is at nfsd_svc+0x56/0x110
> > [   36.351398] EAX: 00000000 EBX: 00000008 ECX: 00000000 EDX: c154c728
> > [   36.351398] ESI: 00000000 EDI: 00000801 EBP: dcf3bf68 ESP: dcf3bf54
> > [   36.351398]  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
> > [   36.351398] Process rpc.nfsd (pid: 2615, ti=dcf3b000 task=de6a8130 task.ti=dcf3b000)
> > [   36.351398] Stack:
> > [   36.351398]  dec3cf28 00f3bf70 00000002 dec3cf28 00000008 dcf3bf70 c1145bba dcf3bf84
> > [   36.351398] <0> c1145abf c1393f40 dec3cf28 00000000 dcf3bfac c10f633b dec3cf6c dec3cf6c
> > [   36.351398] <0> 00000000 bfb34204 00000201 00000000 b7740b90 bfb3420c dcf3b000 c137fba1
> > [   36.351398] Call Trace:
> > [   36.351398]  [<c1145bba>] ? write_svc+0x1a/0x30
> > [   36.351398]  [<c1145abf>] ? nfsctl_transaction_write+0x5f/0x80
> > [   36.351398]  [<c10f633b>] ? sys_nfsservctl+0xab/0xf0
> > [   36.351398]  [<c137fba1>] ? syscall_call+0x7/0xb
> > [   36.351398] Code: 00 00 00 0f 4e d8 81 fb 01 20 00 00 b8 00 20 00 00 0f 4d d8 31 f6 85 db 0f 85 97 00 00 00 a1 84 95 c9 c1 85 c0 74 69 c6 45 f3 00 <8b> 48 2c 85 c9 75 13 85 db 74 0f c6 45 f3 01 8d 74 26 00 8d bc 
> > [   36.351398] EIP: [<c11455a6>] nfsd_svc+0x56/0x110 SS:ESP 0068:dcf3bf54
> > [   36.351398] CR2: 000000000000002c
> > [   36.397072] ---[ end trace 3ca898c1e9981f94 ]---
> > [   37.597439] NET: Registered protocol family 10
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 
> 
> (cc'ing linux-nfs list...)
> 
> Ahh I think I see the bug, nfsd_svc does this:
> 
>         first_thread = (nfsd_serv->sv_nrthreads == 0) && (nrservs != 0);
> 
> ...and only later does this:
> 
>         error = nfsd_create_serv();
>         if (error)
>                 goto out_shutdown;
> 
> Because you're using the older nfsctl interface rather
> than /proc/fs/nfsd, nfsd_svc is called before write_versions and
> nfsd_serv is NULL.
> 
> Does the following patch fix it?
> 
> diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
> index 92173bd..79cfd7a 100644
> --- a/fs/nfsd/nfssvc.c
> +++ b/fs/nfsd/nfssvc.c
> @@ -432,7 +432,9 @@ nfsd_svc(unsigned short port, int nrservs)
>  	if (nrservs == 0 && nfsd_serv == NULL)
>  		goto out;
>  
> -	first_thread = (nfsd_serv->sv_nrthreads == 0) && (nrservs != 0);
> +	first_thread = ((nfsd_serv == NULL) ||
> +			(nfsd_serv->sv_nrthreads == 0)) &&
> +		       (nrservs != 0);
>  
>  	if (first_thread) {
>  		error = nfsd_startup(port, nrservs);
> 
> 

nevermind...that patch will probably fix this panic, but there's another
possible one in nfsd_init_socks. We'll have to fix that one too.

-- 
Jeff Layton <jlayton@redhat.com>

From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Kernel Bug with 2.6.24-rc2-CITI_NFS4-ALL-1  in
	net/sunrpc/svc_xprt.c
Date: Sat, 15 Dec 2007 11:49:45 -0500
Message-ID: <20071215164945.GD14377@fieldses.org>
References: <20071215001211.GQ23121@fieldses.org>
	<C38960B3.22965%tom@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4 <nfsv4@linux-nfs.org>
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <C38960B3.22965%tom@opengridcomputing.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Dec 15, 2007 at 10:45:07AM -0600, Tom Tucker wrote:
> Bruce:
> 
> I've looked at this last week, btw, I requested a login on Bugzila to
> comment directly, but haven't received an account yet.
> 
> I was unable to reproduce this in my code base, however, I haven't yet tried
> it with your tree, so I don't have a definitive negative test.
> 
> I'll clone your tree and see if I can reproduce this.

OK, thanks!  (Note you shouldn't literally need to clone if you already
have a git repo; just

	git add bfields git://linux-nfs.org/~bfields/linux.git
	git fetch --tags bfields
	git checkout 2.6.24-rc2-CITI_NFS4_ALL-1

That'll be a lot faster!)

--b.

> 
> On 12/14/07 6:12 PM, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Wed, Dec 12, 2007 at 03:49:01PM +0100, Le Rouzic wrote:
> >> hi,
> >> Running as client RHEL5.1 Public Gold on a X86_64 bi-ways and
> >> as server 2.6.24-rc2-CITI_NFS4_ALL-1 on a X86_64 bi-ways,
> >> I get the following Oops on the server when on the client I run
> >> in a infinite loop iozone with -U option:
> >> 
> >> while true
> >> do
> >> ./iozone -+q 30 -ace -r 64 -i 0 -i 1 -i 2 -f /mnt/nosec/nfs4_gb -U
> >> /mnt/nosec
> >> date
> >> sleep 30
> >> done
> >> 
> >> =============================================================================
> >> Fedora Core release 6 (Zod)
> >> Kernel 2.6.24-rc2-CITI_NFS4_ALL-1 on an x86_64
> >> 
> >> nfs4gb login: ------------[ cut here ]------------
> >> kernel BUG at net/sunrpc/svc_xprt.c:323!
> > 
> > This is the BUG_ON() in svc_xprt_enqueue(), here:
> > 
> >  process:
> >         if (!list_empty(&pool->sp_threads)) {
> >                 rqstp = list_entry(pool->sp_threads.next,
> >                                    struct svc_rqst,
> >                                    rq_list);
> >                 dprintk("svc: transport %p served by daemon %p\n",
> >                         xprt, rqstp);
> >                 svc_thread_dequeue(pool, rqstp);
> >                 if (rqstp->rq_xprt)
> >                         printk(KERN_ERR
> >                                 "svc_xprt_enqueue: server %p, rq_xprt=%p!\n",
> >                                 rqstp, rqstp->rq_xprt);
> >                 rqstp->rq_xprt = xprt;
> >                 svc_xprt_get(xprt);
> >                 rqstp->rq_reserved = serv->sv_max_mesg;
> >                 atomic_add(rqstp->rq_reserved, &xprt->xpt_reserved);
> >                 BUG_ON(xprt->xpt_pool != pool);
> >                 wake_up(&rqstp->rq_wait);
> >         } else {
> > 
> > (Tom, you can get that particular version from my git tree if you want to take
> > a look--there's a tag for 2.6.24-rc2-CITI_NFS4_ALL-1.  It appears to be a
> > version of the transport switch from mid-october?)
> > 
> > --b.
> > 
> >> invalid opcode: 0000 [1] SMP
> >> Entering kdb (current=0xffff8100031e6080, pid 3227) on processor 1 Oops:
> >> <NULL>
> >> due to oops @ 0xffffffff805bfef1
> >>      r15 = 0x0000000000001000      r14 = 0xffff810006cfc000
> >>      r13 = 0xffff8100035363c0      r12 = 0xffff810004c30bc0
> >>      rbp = 0xffff810007df4000      rbx = 0xffff810006994000
> >>      r11 = 0xffff8100098c1d80      r10 = 0x0000000000007d2b
> >>       r9 = 0x0000000000000004       r8 = 0xffff810004df9180
> >>      rax = 0x0000000000041000      rcx = 0x0000000000000001
> >>      rdx = 0x0000000000000000      rsi = 0x0000000000000001
> >>      rdi = 0xffff810006994010 orig_rax = 0xffffffffffffffff
> >>      rip = 0xffffffff805bfef1       cs = 0x0000000000000010
> >>   eflags = 0x0000000000010203      rsp = 0xffff810007d73d90
> >>       ss = 0x0000000000000018 &regs = 0xffff810007d73cf8
> >> [1]kdb>
> >> [1]kdb> bt
> >> Stack traceback for pid 3227
> >> 0xffff8100031e6080     3227        2  1    1   R  0xffff8100031e63a0 *nfsd
> >> rsp                rip                Function (args)
> >> 0xffff810007d73d78 0xffffffff805bfef1 svc_xprt_enqueue+0x19a
> >> (0xffff810006994000)
> >> 0xffff810007d73dc8 0xffffffff805b9198 svc_tcp_recvfrom+0x367
> >> (0xffff810006cfc000)
> >> 0xffff810007d73e48 0xffffffff805c0db8 svc_recv+0x62d
> >> (0xffff810006cfc000, 0xdbba0)
> >> 0xffff810007d73f08 0xffffffff803329db nfsd+0xdb (0xffff810006cfc000)
> >> 0xffff810007d73f48 0xffffffff8020cbf8 child_rip+0xa (invalid, invalid)
> >> [1]kdb>
> >> 
> >> More at:
> >> Bug:  http://bugzilla.linux-nfs.org/show_bug.cgi?id=155
> >> 
> >> Regards
> >> 
> >> 
> >> -- 
> >> -----------------------------------------------------------------
> >> Company : Bull, Architect of an Open World TM (www.bull.com)
> >> Name    : Aime Le Rouzic
> >> Mail    : Bull - BP 208 - 38432 Echirolles Cedex - France
> >> E-Mail  : aime.le-rouzic@bull.net
> >> Phone   : 33 (4) 76.29.75.51
> >> Fax     : 33 (4) 76.29.75.18
> >> -----------------------------------------------------------------
> >> 
> >> _______________________________________________
> >> NFSv4 mailing list
> >> NFSv4@linux-nfs.org
> >> http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
> > -
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 

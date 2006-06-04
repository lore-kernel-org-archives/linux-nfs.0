From: Neil Brown <neilb@suse.de>
Subject: Re: nfsd pointer in __d_lookup
Date: Mon, 5 Jun 2006 09:31:33 +1000
Message-ID: <17539.27989.256573.829435@cse.unsw.edu.au>
References: <20060601201257.GE20253@coraid.com>
	<17536.8904.701109.163143@cse.unsw.edu.au>
	<20060602153701.GC1053@coraid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-list2-b.sourceforge.net ([10.3.1.8]
	helo=sc8-sf-list2.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fn24k-00050P-7j
	for nfs@lists.sourceforge.net; Sun, 04 Jun 2006 16:32:07 -0700
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Fn24j-0005Hw-FB
	for nfs@lists.sourceforge.net; Sun, 04 Jun 2006 16:32:05 -0700
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Fn24i-0003Be-SU
	for nfs@lists.sourceforge.net; Sun, 04 Jun 2006 16:32:05 -0700
To: "Ed L. Cashin" <ecashin@coraid.com>
In-Reply-To: message from Ed L. Cashin on Friday June 2
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

On Friday June 2, ecashin@coraid.com wrote:
> On Fri, Jun 02, 2006 at 09:36:40PM +1000, Neil Brown wrote:
> > On Thursday June 1, ecashin@coraid.com wrote:
> > > Hi.  On an x86_64 machine, the trace below appears in the system logs
> > > just before NFS service becomes unavailable (until a reboot).
> > > 
> > > I'm working on getting more specifics, but this machine is exporting
> > > an XFS on an LVM logical volume on one or more AoE device.  The aoe
> > > driver in use is not the one in 2.6.16.18 (it's aoe6-23), but I'm
> > > asking the end user to verify that this still happens with the aoe
> > > driver in 2.6.16.18.
> > > 
> > > Meanwhile, I'm hoping that the trace below will look familiar to
> > > someone.  It looks to me like a 32-bit all-ones value might have been
> > > put into a 64-bit variable by mistake.
> > 
> > Not enough detail.
> > If you could get a disassembly of __d_lookup so we could see where
> > +216 was, that might help.
> 
> Sure, I can do that.  I used this command:
> 
>   objdump --disassemble --section=.text ~/kernel/linux-2.6.16.18/vmlinux \
>     | sed -n '/<__d_lookup>:/,/^$/p'
> 
> ffffffff80179435:	75 06                	jne    ffffffff8017943d <__d_lookup+0xbf>
> ffffffff80179437:	f0 ff 03             	lock incl (%rbx)
> ffffffff8017943a:	48 89 d8             	mov    %rbx,%rax
> ffffffff8017943d:	c7 43 08 01 00 00 00 	movl   $0x1,0x8(%rbx)
> ffffffff80179444:	eb 28                	jmp    ffffffff8017946e <__d_lookup+0xf0>
> ffffffff80179446:	c7 43 08 01 00 00 00 	movl   $0x1,0x8(%rbx)
> ffffffff8017944d:	48 8b 6d 00          	mov    0x0(%rbp),%rbp
> ffffffff80179451:	48 85 ed             	test   %rbp,%rbp
> ffffffff80179454:	74 16                	je     ffffffff8017946c <__d_lookup+0xee>
> ffffffff80179456:	48 8b 45 00          	mov    0x0(%rbp),%rax
^^^^^^HERE^^^^^
> ffffffff8017945a:	0f 18 08             	prefetcht0 (%rax)
> ffffffff8017945d:	48 8d 5d e8          	lea    0xffffffffffffffe8(%rbp),%rbx
> ffffffff80179461:	44 39 73 30          	cmp    %r14d,0x30(%rbx)
> ffffffff80179465:	75 e6                	jne    ffffffff8017944d <__d_lookup+0xcf>
> ffffffff80179467:	e9 70 ff ff ff       	jmpq   ffffffff801793dc <__d_lookup+0x5e>
> ffffffff8017946c:	31 c0                	xor    %eax,%eax
> ffffffff8017946e:	41 5b                	pop    %r11
> ffffffff80179470:	5b                   	pop    %rbx
> ffffffff80179471:	5d                   	pop    %rbp
> ffffffff80179472:	41 5c                	pop    %r12
> ffffffff80179474:	41 5d                	pop    %r13
> ffffffff80179476:	41 5e                	pop    %r14
> ffffffff80179478:	41 5f                	pop    %r15
> ffffffff8017947a:	c3                   	retq   

That corresponds to the prefetch(pos->next) in hlist_for_each_entry_rcu.
'pos' has the values 0x000ffffffff.
Looks to me like an RCU related memory corruption.

It's hard to know what would cause this.  It would help if it could
crash a few times and we could see if the corruption was always
0xffffffff or if it was something else other times.

Anyway, I suggest you report it on linux-kernel as I doubt very much
if it is an NFS specific problem.

NeilBrown


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

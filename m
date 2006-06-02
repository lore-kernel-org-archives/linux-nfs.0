From: "Ed L. Cashin" <ecashin@coraid.com>
Subject: Re: nfsd pointer in __d_lookup
Date: Fri, 2 Jun 2006 11:37:01 -0400
Message-ID: <20060602153701.GC1053@coraid.com>
References: <20060601201257.GE20253@coraid.com>
	<17536.8904.701109.163143@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FmCZp-0002b9-1B
	for nfs@lists.sourceforge.net; Fri, 02 Jun 2006 09:32:45 -0700
Received: from ns1.coraid.com ([65.14.39.133] helo=coraid.com ident=none)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1FmCZn-0007ZU-L9
	for nfs@lists.sourceforge.net; Fri, 02 Jun 2006 09:32:45 -0700
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17536.8904.701109.163143@cse.unsw.edu.au>
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

On Fri, Jun 02, 2006 at 09:36:40PM +1000, Neil Brown wrote:
> On Thursday June 1, ecashin@coraid.com wrote:
> > Hi.  On an x86_64 machine, the trace below appears in the system logs
> > just before NFS service becomes unavailable (until a reboot).
> > 
> > I'm working on getting more specifics, but this machine is exporting
> > an XFS on an LVM logical volume on one or more AoE device.  The aoe
> > driver in use is not the one in 2.6.16.18 (it's aoe6-23), but I'm
> > asking the end user to verify that this still happens with the aoe
> > driver in 2.6.16.18.
> > 
> > Meanwhile, I'm hoping that the trace below will look familiar to
> > someone.  It looks to me like a 32-bit all-ones value might have been
> > put into a 64-bit variable by mistake.
> 
> Not enough detail.
> If you could get a disassembly of __d_lookup so we could see where
> +216 was, that might help.

Sure, I can do that.  I used this command:

  objdump --disassemble --section=.text ~/kernel/linux-2.6.16.18/vmlinux \
    | sed -n '/<__d_lookup>:/,/^$/p'

ffffffff8017937e <__d_lookup>:
ffffffff8017937e:	41 57                	push   %r15
ffffffff80179380:	48 ba 01 00 fc ff ff 	mov    $0x9e37fffffffc0001,%rdx
ffffffff80179387:	ff 37 9e 
ffffffff8017938a:	41 56                	push   %r14
ffffffff8017938c:	41 55                	push   %r13
ffffffff8017938e:	49 89 f5             	mov    %rsi,%r13
ffffffff80179391:	41 54                	push   %r12
ffffffff80179393:	49 89 fc             	mov    %rdi,%r12
ffffffff80179396:	55                   	push   %rbp
ffffffff80179397:	53                   	push   %rbx
ffffffff80179398:	53                   	push   %rbx
ffffffff80179399:	48 8b 46 08          	mov    0x8(%rsi),%rax
ffffffff8017939d:	44 8b 36             	mov    (%rsi),%r14d
ffffffff801793a0:	44 8b 7e 04          	mov    0x4(%rsi),%r15d
ffffffff801793a4:	8b 0d d6 4c 24 00    	mov    2378966(%rip),%ecx        # ffffffff803be080 <d_hash_shift>
ffffffff801793aa:	48 89 04 24          	mov    %rax,(%rsp)
ffffffff801793ae:	48 89 f8             	mov    %rdi,%rax
ffffffff801793b1:	48 31 d0             	xor    %rdx,%rax
ffffffff801793b4:	44 89 f6             	mov    %r14d,%esi
ffffffff801793b7:	48 c1 e8 07          	shr    $0x7,%rax
ffffffff801793bb:	48 01 c6             	add    %rax,%rsi
ffffffff801793be:	48 8b 05 b3 4c 24 00 	mov    2378931(%rip),%rax        # ffffffff803be078 <dentry_hashtable>
ffffffff801793c5:	48 31 f2             	xor    %rsi,%rdx
ffffffff801793c8:	48 d3 ea             	shr    %cl,%rdx
ffffffff801793cb:	48 31 d6             	xor    %rdx,%rsi
ffffffff801793ce:	8b 15 b0 4c 24 00    	mov    2378928(%rip),%edx        # ffffffff803be084 <d_hash_mask>
ffffffff801793d4:	21 f2                	and    %esi,%edx
ffffffff801793d6:	48 8b 2c d0          	mov    (%rax,%rdx,8),%rbp
ffffffff801793da:	eb 75                	jmp    ffffffff80179451 <__d_lookup+0xd3>
ffffffff801793dc:	4c 39 63 28          	cmp    %r12,0x28(%rbx)
ffffffff801793e0:	75 6b                	jne    ffffffff8017944d <__d_lookup+0xcf>
ffffffff801793e2:	48 8d 7b 08          	lea    0x8(%rbx),%rdi
ffffffff801793e6:	e8 7d d6 14 00       	callq  ffffffff802c6a68 <_spin_lock>
ffffffff801793eb:	4c 39 63 28          	cmp    %r12,0x28(%rbx)
ffffffff801793ef:	75 55                	jne    ffffffff80179446 <__d_lookup+0xc8>
ffffffff801793f1:	49 8b 84 24 88 00 00 	mov    0x88(%r12),%rax
ffffffff801793f8:	00 
ffffffff801793f9:	48 8d 73 30          	lea    0x30(%rbx),%rsi
ffffffff801793fd:	48 85 c0             	test   %rax,%rax
ffffffff80179400:	74 13                	je     ffffffff80179415 <__d_lookup+0x97>
ffffffff80179402:	48 8b 40 10          	mov    0x10(%rax),%rax
ffffffff80179406:	48 85 c0             	test   %rax,%rax
ffffffff80179409:	74 0a                	je     ffffffff80179415 <__d_lookup+0x97>
ffffffff8017940b:	4c 89 ea             	mov    %r13,%rdx
ffffffff8017940e:	4c 89 e7             	mov    %r12,%rdi
ffffffff80179411:	ff d0                	callq  *%rax
ffffffff80179413:	eb 16                	jmp    ffffffff8017942b <__d_lookup+0xad>
ffffffff80179415:	44 39 7e 04          	cmp    %r15d,0x4(%rsi)
ffffffff80179419:	75 2b                	jne    ffffffff80179446 <__d_lookup+0xc8>
ffffffff8017941b:	48 8b 7e 08          	mov    0x8(%rsi),%rdi
ffffffff8017941f:	48 8b 34 24          	mov    (%rsp),%rsi
ffffffff80179423:	44 89 fa             	mov    %r15d,%edx
ffffffff80179426:	e8 b1 65 04 00       	callq  ffffffff801bf9dc <memcmp>
ffffffff8017942b:	85 c0                	test   %eax,%eax
ffffffff8017942d:	75 17                	jne    ffffffff80179446 <__d_lookup+0xc8>
ffffffff8017942f:	31 c0                	xor    %eax,%eax
ffffffff80179431:	f6 43 04 10          	testb  $0x10,0x4(%rbx)
ffffffff80179435:	75 06                	jne    ffffffff8017943d <__d_lookup+0xbf>
ffffffff80179437:	f0 ff 03             	lock incl (%rbx)
ffffffff8017943a:	48 89 d8             	mov    %rbx,%rax
ffffffff8017943d:	c7 43 08 01 00 00 00 	movl   $0x1,0x8(%rbx)
ffffffff80179444:	eb 28                	jmp    ffffffff8017946e <__d_lookup+0xf0>
ffffffff80179446:	c7 43 08 01 00 00 00 	movl   $0x1,0x8(%rbx)
ffffffff8017944d:	48 8b 6d 00          	mov    0x0(%rbp),%rbp
ffffffff80179451:	48 85 ed             	test   %rbp,%rbp
ffffffff80179454:	74 16                	je     ffffffff8017946c <__d_lookup+0xee>
ffffffff80179456:	48 8b 45 00          	mov    0x0(%rbp),%rax
ffffffff8017945a:	0f 18 08             	prefetcht0 (%rax)
ffffffff8017945d:	48 8d 5d e8          	lea    0xffffffffffffffe8(%rbp),%rbx
ffffffff80179461:	44 39 73 30          	cmp    %r14d,0x30(%rbx)
ffffffff80179465:	75 e6                	jne    ffffffff8017944d <__d_lookup+0xcf>
ffffffff80179467:	e9 70 ff ff ff       	jmpq   ffffffff801793dc <__d_lookup+0x5e>
ffffffff8017946c:	31 c0                	xor    %eax,%eax
ffffffff8017946e:	41 5b                	pop    %r11
ffffffff80179470:	5b                   	pop    %rbx
ffffffff80179471:	5d                   	pop    %rbp
ffffffff80179472:	41 5c                	pop    %r12
ffffffff80179474:	41 5d                	pop    %r13
ffffffff80179476:	41 5e                	pop    %r14
ffffffff80179478:	41 5f                	pop    %r15
ffffffff8017947a:	c3                   	retq   

...
> >   Unable to handle kernel paging request at 00000000ffffffff RIP: 
> >   <ffffffff80179456>{__d_lookup+216}
> >   PGD 3d29d067 PUD 0 
> >   CPU 0 
> >   Modules linked in: ipv6 nfsd lockd nfs_acl sunrpc xfs exportfs dm_mod aoe i2c_i801 i2c_core piix md_mod rtc psmouse unix
> >   Pid: 2535, comm: nfsd Not tainted 2.6.16.18-c1 #8
> >   RIP: 0010:[__d_lookup+216/253] <ffffffff80179456>{__d_lookup+216}
> >   RSP: 0018:ffff81003e6dd958  EFLAGS: 00010206
> >   RAX: 00000000ffffffff RBX: ffff81003ca443c0 RCX: 0000000000000011
> 
> It appears to be dereferencing RAX at an offset of zero.
> Most of the structure references in that code aren't at offset zero.
> My guess is that it is in hlist_for_each_entry_rcu, the
>    pos = pos->next
> I cannot think what result in all those '1's being in pos though.
> 
> NeilBrown

-- 
  Ed L Cashin <ecashin@coraid.com>


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

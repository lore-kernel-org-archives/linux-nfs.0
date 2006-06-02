From: Neil Brown <neilb@suse.de>
Subject: Re: nfsd pointer in __d_lookup
Date: Fri, 2 Jun 2006 21:36:40 +1000
Message-ID: <17536.8904.701109.163143@cse.unsw.edu.au>
References: <20060601201257.GE20253@coraid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fm7xX-0000rf-9I
	for nfs@lists.sourceforge.net; Fri, 02 Jun 2006 04:36:55 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Fm7xW-0007FQ-Se
	for nfs@lists.sourceforge.net; Fri, 02 Jun 2006 04:36:55 -0700
To: "Ed L. Cashin" <ecashin@coraid.com>
In-Reply-To: message from Ed L. Cashin on Thursday June 1
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

On Thursday June 1, ecashin@coraid.com wrote:
> Hi.  On an x86_64 machine, the trace below appears in the system logs
> just before NFS service becomes unavailable (until a reboot).
> 
> I'm working on getting more specifics, but this machine is exporting
> an XFS on an LVM logical volume on one or more AoE device.  The aoe
> driver in use is not the one in 2.6.16.18 (it's aoe6-23), but I'm
> asking the end user to verify that this still happens with the aoe
> driver in 2.6.16.18.
> 
> Meanwhile, I'm hoping that the trace below will look familiar to
> someone.  It looks to me like a 32-bit all-ones value might have been
> put into a 64-bit variable by mistake.

Not enough detail.
If you could get a disassembly of __d_lookup so we could see where
+216 was, that might help.


> 
>   Unable to handle kernel paging request at 00000000ffffffff RIP: 
>   <ffffffff80179456>{__d_lookup+216}
>   PGD 3d29d067 PUD 0 
>   CPU 0 
>   Modules linked in: ipv6 nfsd lockd nfs_acl sunrpc xfs exportfs dm_mod aoe i2c_i801 i2c_core piix md_mod rtc psmouse unix
>   Pid: 2535, comm: nfsd Not tainted 2.6.16.18-c1 #8
>   RIP: 0010:[__d_lookup+216/253] <ffffffff80179456>{__d_lookup+216}
>   RSP: 0018:ffff81003e6dd958  EFLAGS: 00010206
>   RAX: 00000000ffffffff RBX: ffff81003ca443c0 RCX: 0000000000000011

It appears to be dereferencing RAX at an offset of zero.
Most of the structure references in that code aren't at offset zero.
My guess is that it is in hlist_for_each_entry_rcu, the
   pos = pos->next
I cannot think what result in all those '1's being in pos though.

NeilBrown


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: "Anirban Sinha" <ASinha-z4qIPS1Syiu/3pe1ocb+swC/G2K4zDHf@public.gmane.org>
Subject: Re: kernel exports table flushes out on running exportfs -a over mips
Date: Wed, 6 Feb 2008 19:42:31 -0800
Message-ID: <DDFD17CC94A9BD49A82147DDF7D545C57984EB@exchange.ZeugmaSystems.local>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
To: <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.zeugmasystems.com ([192.139.122.66]:17331 "EHLO
	zeugmasystems.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754058AbYBGDnR convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Feb 2008 22:43:17 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi:

I did some extensive digging into the codebase and I believe I have the
reason why exportfs -a flushes out the caches after NFS clients have
mounted the NFS filesystem. 
The analysis is complicated, but here's
the crux of the matter: 

There is a difference in the /etc/exports and the kernel maintained
cache. The difference is that in /etc/exports, we use anonymous clients
(*) whereas kernel maintains a FQDN client names in its exports cache
(see attached file). This difference (the parsing code client_gettype()
specifically checks for a * or an IP or hostname among other things and
based on that creates two different types of caches) is causing the nfs
codebase to recreate new in core exports entries (the second time when
we issue "exportfs -a") after parsing /proc/fs/nfs/export. Immediately
later, it then throws these away (for these newly created entries,
m_mayexport = 0 and m_exported = 1 in function xtab_read()). For
details, see the logic in exports_update_one():

if (exp->m_exported && !exp->m_mayexport) { ... unexporting ...}


Since both the anonymous and FQDN entries are essentially the same, this
results in blowing away the existing kernel exports table. 

My question is, is there a elegant solution to this problem without
simply using FQDN in /etc/exports? I have confirmed that the problem
does not occur when both the in kernel and /etc/exports tables have same
entries (both * or both FQDN).

Cheers,

Ani


Attached:

root:1@1.Zeugma:~# cat /proc/fs/nfs/exports
# Version 1.1
# Path Client(Flags) # IPs
/cf4
zeugma-1-3(rw,insecure,no_root_squash,async,wdelay,no_subtree_check,inse
cure_locks)
/cf2
zeugma-1-4(rw,insecure,no_root_squash,async,wdelay,no_subtree_check,inse
cure_locks)
/cf2/cpu3
zeugma-1-3(rw,insecure,no_root_squash,async,wdelay,no_subtree_check,inse
cure_locks)
/cf2/cpu4
zeugma-1-4(rw,insecure,no_root_squash,async,wdelay,no_subtree_check,inse
cure_locks)
/cf2/cpu2
zeugma-1-2(rw,insecure,no_root_squash,async,wdelay,no_subtree_check,inse
cure_locks)
/cf2
zeugma-1-2(rw,insecure,no_root_squash,async,wdelay,no_subtree_check,inse
cure_locks)
/cf4
zeugma-1-2(rw,insecure,no_root_squash,async,wdelay,no_subtree_check,inse
cure_locks)
/cf4
zeugma-1-4(rw,insecure,no_root_squash,async,wdelay,no_subtree_check,inse
cure_locks)
/cf2
zeugma-1-3(rw,insecure,no_root_squash,async,wdelay,no_subtree_check,inse
cure_locks)

root:1@1.Zeugma:~# cat /etc/exports
/cf2
*(rw,insecure,async,insecure_locks,no_subtree_check,no_root_squash)
/cf2/cpu2
*(rw,insecure,async,insecure_locks,no_subtree_check,no_root_squash)
/cf2/cpu3
*(rw,insecure,async,insecure_locks,no_subtree_check,no_root_squash)
/cf2/cpu4
*(rw,insecure,async,insecure_locks,no_subtree_check,no_root_squash)
/cf4
*(rw,insecure,async,insecure_locks,no_subtree_check,no_root_squash)


> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs- 
> owner@vger.kernel.org] On Behalf Of Anirban Sinha
> Sent: Thursday, January 31, 2008 2:09 PM
> To: Greg Banks
> Cc: linux-nfs@vger.kernel.org
> Subject: RE: kernel exports table flushes out on running exportfs -a 
> over mips
> 
> Hi Greg:
> 
> Thanks for replying. Here goes my response:
> 
> > -----Original Message-----
> > From: Greg Banks [mailto:gnb@sgi.com]
> > Sent: Wednesday, January 30, 2008 6:37 PM
> > To: Anirban Sinha
> > Cc: linux-nfs@vger.kernel.org
> > Subject: Re: kernel exports table flushes out on running exportfs -a

> > over mips
> >
> > On Wed, Jan 30, 2008 at 05:34:13PM -0800, Anirban Sinha wrote:
> > > Hi:
> > >
> > > I am seeing an unusual problem on running nfs server on mips. Over
> > Intel
> > > this does not happen. When I run exportfs -a on the server when 
> > > the clients have already mounted their nfs filesystem, the kernel
> exports
> > > table as can be seen from /proc/fs/nfs/exports gets completely
> > flushed
> > > out. We (me and one another colleague) have done some digging
> (mostly
> > > looking into nfsutils codebase) and it looks like a kernel side
> > issue.
> > > We had also asked folks in the linux-mips mailing list, but
> > apparently
> > > no one has any clue. I am just hoping that those who are more
> > familiar
> > > with the user level and kernel side of nfs might me something more
> to
> > > chew on. If you can give any suggestions that will be really
> useful.
> > If
> > > you think the information I provided is not enough, I can give you
> > any
> > > other information you need in this regard.
> >
> > Does the MIPS box have the /proc/fs/nfsd/ filesystem mounted?
> 
> Ahh, I see what you mean. Yes, it is mounted, both /proc/fs/nfsd and 
> /proc/fs/nfs. However, I can see from the code that check_new_cache() 
> checks for a file "filehandle" which does not exist in that location.
> To be dead sure, I instrumented the code to insert a perror and it 
> returns "no such file or directory". The new_cache flag remains 0. Is 
> this some sort of kernel bug?
> 
> 
> > Perhaps you could try
> >
> > 1) running exportfs under strace.  I suggest
> >    strace -o /tmp/s.log -s 1024 exportfs ...
> 
> Strace does not work in our environment as it has not been properly 
> ported to mips.
> 
> > 2) AND enabling kernel debug messages
> >    rpcdebug -m nfsd -s export
> >    rpcdebug -m rpc -s cache
> 
> I attach the dmesg output after enabling those flags. Zeugma-x-y are 
> the clients to this server. Not sure if it means anything suspicious.
> 
> Ani
> 
> 
> >
> >
> > --
> > Greg Banks, R&D Software Engineer, SGI Australian Software Group.
> > The cake is *not* a lie.
> > I don't speak for SGI.

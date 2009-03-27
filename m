From: hooanon05@yahoo.co.jp
Subject: Re: Problems with default ACLs over NFS
Date: Sat, 28 Mar 2009 07:50:55 +0900
Message-ID: <18513.1238194255@jrobl>
References: <20090323222427.00bb24e7@werewolf.home> <20090326170513.4e7d377a.akpm@linux-foundation.org>
Cc: "\"=?ISO-8859-1?Q? \" J. A. _Magall=F3n \" ?=\"" <jamagallon@ono.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-nfs@vger.kernel.org,
	Trond.Myklebust@netapp.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757807AbZC0Wvz@vger.kernel.org>
In-Reply-To: <20090326170513.4e7d377a.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Mon, 23 Mar 2009 22:24:27 +0100 "J.A. Magall__n" <jamagallon@ono.com> wrote:
> 
> > Hi all...
> > 
> > I have a strange problem with 2.6.29-rc8-git3.
> > It looks like a kernel bug... ?
> > 
> > I have a box with NFS autofs-mounted home directories. Server is a
> > Solaris 10 system. This worked in previous kernel versions, so I
> > don't blame Solaris, at this moment.
> > 
> > With this acls set in my home:
	:::
> > I get this strange message in the linux client:
> > 
> > cicely:~> mkdir kk  
> > mkdir: cannot create directory `kk': Invalid argument

I met a similar problem.
In linux-2.6.29 with CONFIG_NFS_V3_ACL enabled, 
when I executed "cp -p /local/ext2/file /nfsv3/file", I got EINVAL too.
Strace-ing this cp, I found setxsttr() return EINVAL. Before 2.6.29, it
was EOPNOTSUPPORTED.

Tracing some kernel functions, I observed several thigs.
- xdr_buf_subsegment() returned -1 due to 'len' is not 0.
- xdr_encode_word() call from nfsacl_encode() got this -1, and
  nfsacl_encode/nfs3_xdr_setaclargs/nfs3_proc_setacls/nfs3_proc_setacl/nfs3_setxattr
  returned -EINVAL.


Finally I am afraid this commit might be related to this issue.

commit ae46141ff08f1965b17c531b571953c39ce8b9e2
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Mar 10 20:33:18 2009 -0400

    NFSv3: Fix posix ACL code
    
    Fix a memory leak due to allocation in the XDR layer. In cases where the
    RPC call needs to be retransmitted, we end up allocating new pages without
    clearing the old ones. Fix this by moving the allocation into
    nfs3_proc_setacls().
    
    Also fix an issue discovered by Kevin Rudd, whereby the amount of memory
    reserved for the acls in the xdr_buf->head was miscalculated, and causing
    corruption.



J. R. Okajima

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from granite.fifsource.com ([173.255.216.206]:59377 "EHLO
	granite.fifsource.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755744AbaFKQPi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Jun 2014 12:15:38 -0400
Message-ID: <1402503318.27314.12.camel@niobium.home.fifi.org>
Subject: Re: Phantom ACL-related xattrs on 3.14.4 NFS client
From: Philippe Troin <phil@fifi.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel mailing list <linux-kernel@vger.kernel.org>
Date: Wed, 11 Jun 2014 09:15:18 -0700
In-Reply-To: <20140611072402.GA2683@infradead.org>
References: <1402082953.28220.7.camel@ceramic.home.fifi.org>
	 <CAHQdGtS2BL9u4DV=FZ0HaXO-iTNPU4hTGVR--HubNa4A_6UNog@mail.gmail.com>
	 <20140607140414.GA26534@infradead.org>
	 <1402195701.12743.18.camel@ceramic.home.fifi.org>
	 <1402435203.24047.9.camel@ceramic.home.fifi.org>
	 <20140611072402.GA2683@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Christoph,

On Wed, 2014-06-11 at 00:24 -0700, Christoph Hellwig wrote:
> On Tue, Jun 10, 2014 at 02:20:03PM -0700, Philippe Troin wrote:
> > Trond, Christoph,
> > 
> > Since my last email, I've been testing 3.14.6.
> > Stock 3.14.6 is still broken, and Christoph's patch does help, but does
> > not entirely cure the problem.
> 
> Can you send me the output of 
> 
> getfattr -n system.posix_acl_access -e hex <file>
> 
> for the working case, and the current kernel with my previous patch?

Here's the output on the broken kernel (vanilla 3.14.6 + your patch):

        % mkdir x
        % cd x
        % getfacl .                                   
        # file: .
        # owner: phil
        # group: phil
        user::rwx
        group::rwx
        other::r-x
        
        % getfattr -e hex -n system.posix_acl_access .
        .: system.posix_acl_access: No such attribute
        [2]    1901 exit 1     getfattr -e hex -n system.posix_acl_access .
        % setfacl -m u:root:r .                       
        % getfacl .                                   
        # file: .
        # owner: phil
        # group: phil
        user::rwx
        user:root:r--
        group::rwx
        mask::rwx
        other::r-x
        
        % getfattr -e hex -n system.posix_acl_access .
        # file: .
        system.posix_acl_access=0x0200000001000700ffffffff020004000000000004000700ffffffff10000700ffffffff20000500ffffffff
        
        % setfacl -b .                                
        % getfacl .                                   
        # file: .
        # owner: phil
        # group: phil
        user::rwx
        group::rwx
        other::r-x
        
        % getfattr -e hex -n system.posix_acl_access .
        # file: .
        system.posix_acl_access=0x0200000001000700ffffffff04000700ffffffff20000500ffffffff
        
On a working system (3.13.11 + Fedora patches), the output is the same.
So there's no regression here between 3.13.11 and 3.14.6 + your patch.
I would argue that this behavior (system.posix_acl_access still present
after clear the ACLs with setfacl -b) is wrong, and in fact there are no
traces of this xattr on the server, but it's not new.
I had missed that this counter-intuitive behavior was already in earlier
kernels.  My apologies.
Trond, what's your take on that one?

So, the only regression remaining between 3.13.11 and 3.14.6 + your
patch is the one where listxattr(2) and friends do not NUL-terminate the
xattr names they return.  This is detailed in
<1402435203.24047.9.camel@ceramic.home.fifi.org> I sent yesterday.

Phil.


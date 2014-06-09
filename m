Return-Path: linux-nfs-owner@vger.kernel.org
Received: from granite.fifsource.com ([173.255.216.206]:44075 "EHLO
	granite.fifsource.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932228AbaFIQF4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Jun 2014 12:05:56 -0400
Message-ID: <1402329504.3814.13.camel@niobium.home.fifi.org>
Subject: Re: Phantom ACL-related xattrs on 3.14.4 NFS client
From: Philippe Troin <phil@fifi.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@infradead.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel mailing list <linux-kernel@vger.kernel.org>
Date: Mon, 09 Jun 2014 08:58:24 -0700
In-Reply-To: <20140609144645.GB8390@fieldses.org>
References: <1402082953.28220.7.camel@ceramic.home.fifi.org>
	 <CAHQdGtS2BL9u4DV=FZ0HaXO-iTNPU4hTGVR--HubNa4A_6UNog@mail.gmail.com>
	 <20140607140414.GA26534@infradead.org>
	 <1402195701.12743.18.camel@ceramic.home.fifi.org>
	 <20140609144645.GB8390@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2014-06-09 at 10:46 -0400, J. Bruce Fields wrote:
> On Sat, Jun 07, 2014 at 07:48:21PM -0700, Philippe Troin wrote:
> > Hi Trond & Christoph,
> > 
> > It's still broken, but in a different way.
> > The phantom attrs are gone, but the attr/acl interaction is still
> > uncertain.
> > 
> > I have tested vanilla  3.14.5 + this patch on x86_64.
> > Mount options are the same as last time (NFSv3).
> > 
> > This is what I see on the client:
> > 
> >         nfsv3client% mkdir x
> >         nfsv3client% cd x
> >         nfsv3client% getfattr -m '.*' .
> >         nfsv3client% getfacl .
> >         # file: .
> >         # owner: phil
> >         # group: phil
> >         user::rwx
> >         group::rwx
> >         other::r-x
> > 
> > OK so far: no more phantom attrs.
> > This is where things get dodgy:
> >         
> >         nfsv3client% setfacl -m u:root:r .   
> >         nfsv3client% getfacl .
> >         # file: .
> >         # owner: phil
> >         # group: phil
> >         user::rwx
> >         user:root:r--
> >         group::rwx
> >         mask::rwx
> >         other::r-x
> >         
> >         nfsv3client% getfattr -m '.*' .
> >         [1]    2123 segmentation fault  getfattr -m '.*' .
> 
> Is there a backtrace or anything in the system logs?

No, nothing but the SIGSEGV getting logged in dmesg.

Since I've tested on 3.14.5, 3.14.6 came out, and contains NFSd related
patches that look to address further ACL issues.  I'm going to be trying
that out.

Phil.


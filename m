Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37869 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752247Ab2GJV4V (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Jul 2012 17:56:21 -0400
Date: Tue, 10 Jul 2012 17:56:19 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Simo Sorce <simo@redhat.com>, "bfields@redhat.com" <bfields@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/4] Add support for new RPCSEC_GSS upcall mechanism
 for nfsd
Message-ID: <20120710215618.GC6038@fieldses.org>
References: <1337983796-26476-1-git-send-email-simo@redhat.com>
 <20120710204913.GA6038@fieldses.org>
 <1341957169.17428.4.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1341957169.17428.4.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 10, 2012 at 09:52:51PM +0000, Myklebust, Trond wrote:
> On Tue, 2012-07-10 at 16:49 -0400, J. Bruce Fields wrote:
> > On Fri, May 25, 2012 at 06:09:52PM -0400, Simo Sorce wrote:
> > > This patchset implements a new upcall mechanism that uses the sunrpc
> > > client to talk to gssproxy[1], a new userspace daemon that handles gssapi
> > > operations on behalf of other processes on the system.
> > > 
> > > The main driver for this new mechanism is to overcome limitations with
> > > the current daemon and upcall. The current code cannot handle tickets
> > > larger than approximatively 2k and cannot handle sending back large user
> > > credential sets to the kernel.
> > > 
> > > These patches have been tested against the development version of gssproxy
> > > tagged as kernel_v0.1 in the master repo[2].
> > > 
> > > I have tested walking into mountpoints using tickets artificially pumped
> > > up to 64k and the user is properly authorized, after the accept_se_context
> > > call is performed through the new upcall mechanism and gssproxy.
> > > 
> > > The gssproxy has the potential of handling also init_sec_context calls,
> > > but at the moment the only targeted system is nfsd.
> > 
> > OK, absent objections from anyone else I'm commiting these for 3.6 and
> > pushing them out soon pending some regression testing.  Thanks!
> 
> Please test that the NFSv4 backchannel continues to work unchanged with
> the existing rpc.svcgssd before you commit.
> 
> I don't care what happens to the NFS server, but I do expect all
> existing NFSv4 client setups to work without any need for changes.

The rpc server's authentication method is global to the machine, so if
the NFS server is using gss proxy, then I believe the callback server
will be as well.

--b.

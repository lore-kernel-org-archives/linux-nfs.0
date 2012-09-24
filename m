Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:42685 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754667Ab2IXAlj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 23 Sep 2012 20:41:39 -0400
Date: Sun, 23 Sep 2012 20:41:34 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: NeilBrown <neilb@suse.de>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: What is NFSv4 READDIR doesn't return a filehandle....
Message-ID: <20120923204134.4bc143b6@corrin.poochiereds.net>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA908FDDEDC@SACEXCMBX04-PRD.hq.netapp.com>
References: <20120917090537.20e38026@notabene.brown>
	<4FA345DA4F4AE44899BD2B03EEEC2FA908FC54E3@SACEXCMBX04-PRD.hq.netapp.com>
	<20120918120417.4251733d@notabene.brown>
	<4FA345DA4F4AE44899BD2B03EEEC2FA908FDDEDC@SACEXCMBX04-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 21 Sep 2012 02:44:10 +0000
"Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> On Tue, 2012-09-18 at 12:04 +1000, NeilBrown wrote:
> > On Mon, 17 Sep 2012 12:51:33 +0000 "Myklebust, Trond"
> > <Trond.Myklebust@netapp.com> wrote:
> > 
> > > > -----Original Message-----
> > > > From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
> > > > owner@vger.kernel.org] On Behalf Of NeilBrown
> > > > Sent: Sunday, September 16, 2012 7:06 PM
> > > > To: linux-nfs@vger.kernel.org
> > > > Subject: What is NFSv4 READDIR doesn't return a filehandle....
> > > > 
> > > > 
> > > > In NFSv4, the server can report which attributes it chose to return in a
> > > > READDIR reply.
> > > > 
> > > > A customer has come across a server which does not return the filehandle
> > > > information (is that allowed?).
> > > 
> > > The filehandle attribute is a mandatory attribute according to RFC3530, so I believe that the answer is "no".
> > > 
> > > > A consequence of this is that Linux/NFS gets confused.
> > > > nfs_readdir_page_filler calls nfs_prime_dcache() (because it was a readdir
> > > > plus request that was sent) and nfs_prime_dcache goes ahead and creates
> > > > an inode based on the filehandle that it has.
> > > > However decode_attr_filehandle() had happily decoded nothing as the
> > > > FATTR4_WORD0_FILEHANDLE bit wasn't set.
> > > > So the inode gets created with a zero-length filehandle and when this gets
> > > > sent back to the server to act on the inode, it gets NFS4ERR_BADHANDLE to
> > > > the PUTFH op.
> > > > 
> > > > So should nfs_prime_dcache() abort if the filehandle doesn't exist (patch
> > > > below) or should nfs_fhget() return an error if the filehandle is empty?
> > > > 
> > > > Or maybe this behaviour should be detected and readdir should be disabled
> > > > for that server?
> > > > 
> > > 
> > > I don't want to have to code the client to deal with broken servers. If we start down that path, then we'll end up doing nothing else.
> > > 
> > > I can, however, see a case for extending the "nordirplus" mount option to cover NFSv4. Currently it only acts on NFSv3 mounts...
> > > 
> > >
> > 
> > Thanks Trond.
> > I'm happy with this position - less work for me :-)
> > 
> > As it happens, nordirplus *does* work for NFSv4 and customer had already
> > found that this is a successful work around.  They didn't want to have to use
> > it though.  I've pointed out that is really isn't our problem.
> 
> Good! I was worried that nordirplus wasn't working for NFSv4.
> 
> If there is an existing workaround, then I do not at all accept the
> argument that we need to add client-side patches to accommodate
> brokenness on the NFS servers.
> 
> If there is no existing workaround, then I'm willing to help people with
> a temporary fix while they wait for the server vendors to get their act
> together. However ultimately, I don't believe in fixing server bugs on
> the client: those temporary fixes should certainly not be finding their
> way into the upstream kernel, and as a consequence they should probably
> not go into distribution kernels either (although that is your call, and
> not mine :-)).
> 
> > Just a thought: while coping with broken servers would not be a good path to
> > follow, detecting protocol violations and reporting an error might be...
> > should the NFS client treat a missing filehandle and a malformed reply?
> 
> My concern is that the client can't objectively judge what constitutes a
> valid filehandle and what does not until it tries to use it in an RPC
> call.
> Given that premise, it makes more sense to concentrate on handling the
> cases where the usage fails. Jeff Layton's vfs ESTALE patches are a good
> case in point.
> 

Wait though -- is it not safe to assume that a zero length filehandle
is invalid?

Neil's earlier patch checked for entry->fh.size == 0, would it not be
reasonable to warn once per server when we get back such a fh?

-- 
Jeff Layton <jlayton@redhat.com>

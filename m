Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f179.google.com ([209.85.220.179]:36826 "EHLO
        mail-qk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751356AbdB0NFs (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Feb 2017 08:05:48 -0500
Received: by mail-qk0-f179.google.com with SMTP id n186so19374975qkb.3
        for <linux-nfs@vger.kernel.org>; Mon, 27 Feb 2017 05:04:40 -0800 (PST)
Message-ID: <1488196763.2876.1.camel@redhat.com>
Subject: Re: [PATCH v2 0/4] nfs/nfsd/sunrpc: enforce NFSv4 transport
 requirements
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: trond.myklebust@primarydata.com, schumaker.anna@gmail.com,
        linux-nfs@vger.kernel.org, chuck.lever@oracle.com, tom@talpey.com,
        jgunthorpe@obsidianresearch.com
Date: Mon, 27 Feb 2017 06:59:23 -0500
In-Reply-To: <20170224214442.GI26378@fieldses.org>
References: <20170223170337.10686-1-jlayton@redhat.com>
         <20170224182525.10390-1-jlayton@redhat.com>
         <20170224212516.GH26378@fieldses.org> <1487972064.3314.8.camel@redhat.com>
         <20170224214442.GI26378@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2017-02-24 at 16:44 -0500, J. Bruce Fields wrote:
> On Fri, Feb 24, 2017 at 04:34:24PM -0500, Jeff Layton wrote:
> > On Fri, 2017-02-24 at 16:25 -0500, J. Bruce Fields wrote:
> > > The one other minor thing we could do is skip adding the UDP listener
> > > entirely in the v4-only case.  I think that's a job for rpc.nfsd?
> > > 
> > > --b.
> > > 
> > 
> > Yeah I think we'd need to fix that in rpc.nfsd.
> > 
> > Maybe it's time to just start doing having it do TCP-only by default
> > anyway? Make it so you have to explicitly enable UDP listeners if you
> > want them? Does anyone seriously run NFS over UDP these days for
> > anything other than interop testing? :)
> 
> I thought I remembered somebody floating this on linux-nfs a couple
> years ago and finding there were still a couple vocal users.  Or maybe
> that was NFSv2.  I can't find the thread now.
> 
> I'm pretty conservative about anything that might break people's ancient
> but working setups on upgrade, but maybe it's time.
> 
> Just switching the default to off in nfs-utils first would be the way to
> go, I think, then if that goes well we could think about phasing out
> kernel support.
> 
> --b.
> 

Ok, I posted a patch a couple of days ago as an RFC. It's pretty
straightforward and works. I don't see any need to turn off kernel
support just yet. If we do have users who need it, turning it back on is
pretty trivial with nfs.conf.

What I'd really like is to eventually have distros move to a default
nfsd configuration that is v4-only. Have the kernel only listen for v4
calls on TCP, turn off lockd and statd, and make mountd not open any IP
sockets.

What we'd need to make that happen, I think is a [global] stanza in
nfs.conf with a single 'nfsd_v3' boolean that defaults to off. If
someone needs to serve v3, they could turn that on and everything would
be reenabled. That would take a bit of plumbing through various daemons
though.

-- 
Jeff Layton <jlayton@redhat.com>

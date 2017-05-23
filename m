Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:46089 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751800AbdEWKfi (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 23 May 2017 06:35:38 -0400
Message-ID: <1495535730.2564.5.camel@themaw.net>
Subject: Re: [RFC][PATCH 0/9] Make containers kernel objects
From: Ian Kent <raven@themaw.net>
To: James Bottomley <James.Bottomley@HansenPartnership.com>,
        Jeff Layton <jlayton@redhat.com>,
        David Howells <dhowells@redhat.com>, trondmy@primarydata.com
Cc: mszeredi@redhat.com, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org, cgroups@vger.kernel.org,
        ebiederm@xmission.com,
        Linux Containers <containers@lists.linux-foundation.org>
Date: Tue, 23 May 2017 18:35:30 +0800
In-Reply-To: <1495480860.9050.18.camel@HansenPartnership.com>
References: <149547014649.10599.12025037906646164347.stgit@warthog.procyon.org.uk>
         <1495472039.2757.19.camel@HansenPartnership.com>
         <1495478092.2816.17.camel@redhat.com>
         <1495480860.9050.18.camel@HansenPartnership.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2017-05-22 at 12:21 -0700, James Bottomley wrote:
> 
> > > >  (3) nfsdcltrack.  A way for NFSD to access stable storage for 
> > > > tracking of persistent state.  Again, network-namespace 
> > > > dependent, but also perhaps mount-namespace dependent.
> > 
> > Definitely mount-namespace dependent.
> > 
> > > 
> > > So again, given we can set this up to work today, this sounds like 
> > > more a restriction that will bite us than an enhancement that gives 
> > > us extra features.
> > > 
> > 
> > How do you set this up to work today?
> 
> Well, as above, it spawns into the root, you jump it to where it should
> be and re-execute or simply handle in the host. 
> 
> > AFAIK, if you want to run knfsd in a container today, you're out of 
> > luck for any non-trivial configuration.
> 
> Well "running knfsd in a container" is actually different from having a
> containerised nfs export.  My understanding was that thanks to the work
> of Stas Kinsbursky, the latter has mostly worked since the 3.9 kernel
> for v3 and below.  I assume the current issue is that there's a problem
> with v4?

Oh, ok, I thought that, say, a docker (NFS) volumes-from a container to another
container didn't work for any version of NFS.

Certainly didn't work last time I tried, it was a while ago though.

Ian

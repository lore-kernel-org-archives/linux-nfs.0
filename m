Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34362 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752052AbdJ0NXZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 27 Oct 2017 09:23:25 -0400
Date: Fri, 27 Oct 2017 14:23:18 +0100
From: "Daniel P. Berrange" <berrange@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: Matt Benjamin <mbenjami@redhat.com>,
        Stefan Hajnoczi <stefanha@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "J . Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Steve Dickson <steved@redhat.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        Trond Myklebust <trondmy@primarydata.com>,
        NFSv4 <nfsv4@ietf.org>
Subject: Re: Draft RFC for ONC RPC over AF_VSOCK
Message-ID: <20171027132318.GC30686@redhat.com>
Reply-To: "Daniel P. Berrange" <berrange@redhat.com>
References: <20171005200835.GA31525@stefanha-x1.localdomain>
 <CAKOnarmreQp6c8qM7x=ohGf1sAoj53qbE0bNvKxzyWLiS=2zKw@mail.gmail.com>
 <1509110202.4704.7.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <1509110202.4704.7.camel@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 27, 2017 at 09:16:42AM -0400, Jeff Layton wrote:
> On Thu, 2017-10-05 at 16:50 -0400, Matt Benjamin wrote:
> > Hi Stefan,
> > 
> > On Thu, Oct 5, 2017 at 4:08 PM, Stefan Hajnoczi <stefanha@redhat.com> wrote:
> > > I have previously submitted patches that implement NFS client and nfsd
> > > support for the AF_VSOCK address family.  In order for this to be
> > > acceptable for merge the AF_VSOCK transport needs to be defined in an
> > > IETF RFC.  Below is a draft RFC that defines ONC RPC over AF_VSOCK.
> > > 
> > > My patches use netid "vsock" but "tcpv" has also been suggested.  This draft
> > > RFC still uses "vsock" but I'll update it to "tcpv" if there is consensus.
> > > 
> > 
> > I think "vsock" is the appropriate netid, not "tcpv."  Stream
> > orientation, if anything, is the general category containing TCP and
> > VSOCK, not the reverse.  But really I think it's just more clear.
> > 
> 
> Agreed. VSOCK is its own thing. It bears some resemblance to TCP, but
> calling it tcpv would be confusing. IIRC, Chuck only proposed that when
> we were discussing an alternative transport that would look more like a
> typical network.
> 
> BTW: Does VSOCK have a connectionless mode, analogous to UDP? If so,
> then it may be nice to consider what the netid for that might look like
> as well, before we settle on any names.

Yes, you can use SOCK_STREAM or SOCK_DGRAM when using vsock.

Regards,
Daniel
-- 
|: https://berrange.com      -o-    https://www.flickr.com/photos/dberrange :|
|: https://libvirt.org         -o-            https://fstop138.berrange.com :|
|: https://entangle-photo.org    -o-    https://www.instagram.com/dberrange :|

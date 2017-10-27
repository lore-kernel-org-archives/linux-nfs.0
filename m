Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f171.google.com ([209.85.220.171]:55447 "EHLO
        mail-qk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932406AbdJ0NQp (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Oct 2017 09:16:45 -0400
Received: by mail-qk0-f171.google.com with SMTP id x82so8256266qkb.12
        for <linux-nfs@vger.kernel.org>; Fri, 27 Oct 2017 06:16:45 -0700 (PDT)
Message-ID: <1509110202.4704.7.camel@redhat.com>
Subject: Re: Draft RFC for ONC RPC over AF_VSOCK
From: Jeff Layton <jlayton@redhat.com>
To: Matt Benjamin <mbenjami@redhat.com>,
        Stefan Hajnoczi <stefanha@redhat.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "J . Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Steve Dickson <steved@redhat.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        Trond Myklebust <trondmy@primarydata.com>,
        Daniel Berrange <berrange@redhat.com>, NFSv4 <nfsv4@ietf.org>
Date: Fri, 27 Oct 2017 09:16:42 -0400
In-Reply-To: <CAKOnarmreQp6c8qM7x=ohGf1sAoj53qbE0bNvKxzyWLiS=2zKw@mail.gmail.com>
References: <20171005200835.GA31525@stefanha-x1.localdomain>
         <CAKOnarmreQp6c8qM7x=ohGf1sAoj53qbE0bNvKxzyWLiS=2zKw@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2017-10-05 at 16:50 -0400, Matt Benjamin wrote:
> Hi Stefan,
> 
> On Thu, Oct 5, 2017 at 4:08 PM, Stefan Hajnoczi <stefanha@redhat.com> wrote:
> > I have previously submitted patches that implement NFS client and nfsd
> > support for the AF_VSOCK address family.  In order for this to be
> > acceptable for merge the AF_VSOCK transport needs to be defined in an
> > IETF RFC.  Below is a draft RFC that defines ONC RPC over AF_VSOCK.
> > 
> > My patches use netid "vsock" but "tcpv" has also been suggested.  This draft
> > RFC still uses "vsock" but I'll update it to "tcpv" if there is consensus.
> > 
> 
> I think "vsock" is the appropriate netid, not "tcpv."  Stream
> orientation, if anything, is the general category containing TCP and
> VSOCK, not the reverse.  But really I think it's just more clear.
> 

Agreed. VSOCK is its own thing. It bears some resemblance to TCP, but
calling it tcpv would be confusing. IIRC, Chuck only proposed that when
we were discussing an alternative transport that would look more like a
typical network.

BTW: Does VSOCK have a connectionless mode, analogous to UDP? If so,
then it may be nice to consider what the netid for that might look like
as well, before we settle on any names.
-- 
Jeff Layton <jlayton@redhat.com>

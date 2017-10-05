Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:47884 "EHLO
        mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751381AbdJEUu5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Oct 2017 16:50:57 -0400
Received: by mail-io0-f170.google.com with SMTP id m201so9182811iom.4
        for <linux-nfs@vger.kernel.org>; Thu, 05 Oct 2017 13:50:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171005200835.GA31525@stefanha-x1.localdomain>
References: <20171005200835.GA31525@stefanha-x1.localdomain>
From: Matt Benjamin <mbenjami@redhat.com>
Date: Thu, 5 Oct 2017 16:50:55 -0400
Message-ID: <CAKOnarmreQp6c8qM7x=ohGf1sAoj53qbE0bNvKxzyWLiS=2zKw@mail.gmail.com>
Subject: Re: Draft RFC for ONC RPC over AF_VSOCK
To: Stefan Hajnoczi <stefanha@redhat.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Jeff Layton <jlayton@redhat.com>,
        "J . Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Steve Dickson <steved@redhat.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        Trond Myklebust <trondmy@primarydata.com>,
        Daniel Berrange <berrange@redhat.com>, NFSv4 <nfsv4@ietf.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Stefan,

On Thu, Oct 5, 2017 at 4:08 PM, Stefan Hajnoczi <stefanha@redhat.com> wrote:
> I have previously submitted patches that implement NFS client and nfsd
> support for the AF_VSOCK address family.  In order for this to be
> acceptable for merge the AF_VSOCK transport needs to be defined in an
> IETF RFC.  Below is a draft RFC that defines ONC RPC over AF_VSOCK.
>
> My patches use netid "vsock" but "tcpv" has also been suggested.  This draft
> RFC still uses "vsock" but I'll update it to "tcpv" if there is consensus.
>

I think "vsock" is the appropriate netid, not "tcpv."  Stream
orientation, if anything, is the general category containing TCP and
VSOCK, not the reverse.  But really I think it's just more clear.

I think this draft needs to be sent to the IETF NFSv4 working group
alias, nfsv4@ietf.org.

Matt

-- 

Matt Benjamin
Red Hat, Inc.
315 West Huron Street, Suite 140A
Ann Arbor, Michigan 48103

http://www.redhat.com/en/technologies/storage

tel.  734-821-5101
fax.  734-769-8938
cel.  734-216-5309

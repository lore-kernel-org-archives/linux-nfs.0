Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:53086 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753591AbcJ2U2v (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 29 Oct 2016 16:28:51 -0400
Date: Sat, 29 Oct 2016 16:28:50 -0400
To: Andreas Gruenbacher <agruenba@redhat.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>
Subject: Re: [PATCH 0/2] NFSv4.2 umask support
Message-ID: <20161029202850.GA23842@fieldses.org>
References: <1477686228-12158-1-git-send-email-bfields@redhat.com>
 <CAHc6FU5i3aDDNUKLUot9B8hjbiMxFR4nipB3b-ROa9k4a6KhPQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHc6FU5i3aDDNUKLUot9B8hjbiMxFR4nipB3b-ROa9k4a6KhPQ@mail.gmail.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Oct 29, 2016 at 11:38:43AM +0200, Andreas Gruenbacher wrote:
> On Fri, Oct 28, 2016 at 10:23 PM, J. Bruce Fields <bfields@redhat.com> wrote:
> > From: "J. Bruce Fields" <bfields@redhat.com>
> >
> > The following patches allow the umask to be ignored in the presence of
> > inheritable NFSv4 ACLs.  Otherwise inheritable ACLs can be rendered
> > mostly useless whenever the umask masks out group bits.
> >
> > This solves a problem we've seen complaints about for some time, both
> > upstream and from RHEL users.
> >
> > The new protocol has been discussed in the IETF working group and is
> > documented at:
> >
> >         https://tools.ietf.org/html/draft-ietf-nfsv4-umask-02
> >
> > It's unlikely that we'll discover problems requiring an incompatible
> > change, so I think we should consider this for 4.10.
> 
> Nope, these patches don't implement draft-ietf-nfsv4-umask-02 yet,

They don't?  What did I miss?

--b.

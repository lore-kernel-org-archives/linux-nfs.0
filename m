Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49960 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751004AbdJLM3P (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 12 Oct 2017 08:29:15 -0400
Date: Thu, 12 Oct 2017 13:08:14 +0100
From: Stefan Hajnoczi <stefanha@redhat.com>
To: Matt Benjamin <mbenjami@redhat.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        NFSv4 <nfsv4@ietf.org>
Subject: Re: Draft RFC for ONC RPC over AF_VSOCK
Message-ID: <20171012120814.GB5957@stefanha-x1.localdomain>
References: <20171005200835.GA31525@stefanha-x1.localdomain>
 <CAKOnarmreQp6c8qM7x=ohGf1sAoj53qbE0bNvKxzyWLiS=2zKw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAKOnarmreQp6c8qM7x=ohGf1sAoj53qbE0bNvKxzyWLiS=2zKw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 05, 2017 at 04:50:55PM -0400, Matt Benjamin wrote:
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
> I think this draft needs to be sent to the IETF NFSv4 working group
> alias, nfsv4@ietf.org.

Thanks.  Will send the next revision properly formatted to the NFSv4
working group.

Stefan

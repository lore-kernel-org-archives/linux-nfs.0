Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41296 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751480AbdJMKKe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 13 Oct 2017 06:10:34 -0400
Date: Fri, 13 Oct 2017 11:10:31 +0100
From: Stefan Hajnoczi <stefanha@redhat.com>
To: Chuck Lever <chucklever@gmail.com>
Cc: Matt Benjamin <mbenjami@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        NFSv4 <nfsv4@ietf.org>
Subject: Re: Draft RFC for ONC RPC over AF_VSOCK
Message-ID: <20171013101031.GE27308@stefanha-x1.localdomain>
References: <20171005200835.GA31525@stefanha-x1.localdomain>
 <CAKOnarmreQp6c8qM7x=ohGf1sAoj53qbE0bNvKxzyWLiS=2zKw@mail.gmail.com>
 <20171012120814.GB5957@stefanha-x1.localdomain>
 <D5A0AD89-0FA0-4057-849D-57BA54433710@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <D5A0AD89-0FA0-4057-849D-57BA54433710@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 12, 2017 at 12:40:20PM -0400, Chuck Lever wrote:
> 
> 
> > On Oct 12, 2017, at 8:08 AM, Stefan Hajnoczi <stefanha@redhat.com> wrote:
> > 
> >> On Thu, Oct 05, 2017 at 04:50:55PM -0400, Matt Benjamin wrote:
> >>> On Thu, Oct 5, 2017 at 4:08 PM, Stefan Hajnoczi <stefanha@redhat.com> wrote:
> >>> I have previously submitted patches that implement NFS client and nfsd
> >>> support for the AF_VSOCK address family.  In order for this to be
> >>> acceptable for merge the AF_VSOCK transport needs to be defined in an
> >>> IETF RFC.  Below is a draft RFC that defines ONC RPC over AF_VSOCK.
> >>> 
> >>> My patches use netid "vsock" but "tcpv" has also been suggested.  This draft
> >>> RFC still uses "vsock" but I'll update it to "tcpv" if there is consensus.
> >>> 
> >> 
> >> I think "vsock" is the appropriate netid, not "tcpv."  Stream
> >> orientation, if anything, is the general category containing TCP and
> >> VSOCK, not the reverse.  But really I think it's just more clear.
> >> 
> >> I think this draft needs to be sent to the IETF NFSv4 working group
> >> alias, nfsv4@ietf.org.
> > 
> > Thanks.  Will send the next revision properly formatted to the NFSv4
> > working group.
> 
> Don’t do that. Please submit a personal draft via:
> 
> https://datatracker.ietf.org/submit/
> 
> once you have appropriate permission from RH legal
> counsel to contribute to the IETF. Then approach the
> working group to introduce your submitted document.

Okay, thanks!

Stefan

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:33776 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751728AbeEOWGA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 15 May 2018 18:06:00 -0400
Date: Tue, 15 May 2018 18:05:59 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Andreas Gruenbacher <agruenba@redhat.com>
Cc: Lu Xinyu <luxy.fnst@cn.fujitsu.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        fnst-xmlinux@cn.fujitsu.com
Subject: Re: SGID loss with nfsv3
Message-ID: <20180515220559.GD8178@fieldses.org>
References: <f9f2d605-b930-7db8-ad1e-fd189e074e9c@cn.fujitsu.com>
 <20180430201623.GA3207@fieldses.org>
 <060c9d41-8772-80e1-e938-21ec7b6315ef@cn.fujitsu.com>
 <20180514143222.GA7160@fieldses.org>
 <5b6540f4-f744-5e51-c32f-c8809fbfed81@cn.fujitsu.com>
 <20180515204147.GA8178@fieldses.org>
 <20180515204244.GB8178@fieldses.org>
 <CAHc6FU5G2Y=H3C_YG7aASybzEfKrAuWRZFw-YoZuSw2i84qrag@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHc6FU5G2Y=H3C_YG7aASybzEfKrAuWRZFw-YoZuSw2i84qrag@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 15, 2018 at 11:47:10PM +0200, Andreas Gruenbacher wrote:
> Hi Bruce,
> 
> On 15 May 2018 at 22:42, J. Bruce Fields <bfields@fieldses.org> wrote:
> > Ugh, resending with Andreas's address spelled correctly.
> >
> > On Tue, May 15, 2018 at 04:41:47PM -0400, J. Bruce Fields wrote:
> >> Looking at the problem more closely....
> >>
> >> So the desired behavior is that the SGID bit gets cleared on an explicit
> >> set of the acl, but not when the acl is merely inherited as part of file
> >> creation?
> 
> ideally yes, but that's not achievable over NFSv3, only over NFSv4.
> 
> >> If I understand correctly, in the NFSv3 case default acl inheritance is
> >> done manually by the client, which queries the default acl, calculates
> >> the inherited acl itself, and applies the result to the new file using a
> >> setacl call to the server.
> >>
> >> The server isn't capable of distinguishing this setacl call from any
> >> other setacl call, so can't know that it should skip clearing the SGID
> >> bit.
> >>
> >> Andreas, do I have that right?  Is this fixable?
> 
> Yes, I believe that's exactly what's happening.

Well, we can't back out the CVE fix, so I think just living with this
behavior (the SGID being cleared sometimes when it didn't need to be) is
our least bad option.  NFSv4 has the protocol we need to get this right,
and doesn't have this bug.

--b.

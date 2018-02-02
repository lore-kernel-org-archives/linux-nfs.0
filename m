Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51318 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754330AbeBBTzv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 2 Feb 2018 14:55:51 -0500
Date: Fri, 2 Feb 2018 14:55:50 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Olga Kornievskaia <kolga@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v6 05/10] NFSD first draft of async copy
Message-ID: <20180202195550.GA7229@parsley.fieldses.org>
References: <20171024174752.74910-1-kolga@netapp.com>
 <20171024174752.74910-6-kolga@netapp.com>
 <20180126213405.GA7770@fieldses.org>
 <CAN-5tyE0j5xOyagWH+zgzFc9Hd00=k=3-J_Nuych_9OGG3-CyA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAN-5tyE0j5xOyagWH+zgzFc9Hd00=k=3-J_Nuych_9OGG3-CyA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 02, 2018 at 02:50:01PM -0500, Olga Kornievskaia wrote:
> On Fri, Jan 26, 2018 at 4:34 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > If I understand correctly (I may be wrong), once this patch is applied a
> > COPY may fail that previously worked--because we're switching over to
> > the asynchronous copy implementation before it's actually complete.
> 
> I will have to double check this with testing but I think after this
> patch the asynchronous copy is functional but doesn't comply with the
> spec (eg., doesn't generate the unique stateid).
> 
> > Of course, that's fixed by the end of this series.  But we try to avoid
> > that situation, where functionality is temporarily broken in the middle
> > of a patch series and then fixed later.
> >
> > Options might be to squash this patch together with some of the later
> > patches.  Or go ahead and add this code but don't actually enable it
> > till later.  (E.g. arrange that the "if (!copy->cp_synchronous)" case
> > won't be taken till the last patch.  Maybe it already works that way, I
> > can't tell.)  Or maybe there's some slicker way that I don't see right
> > now.
> 
> I could do if (!copy->cp_synchronous && 0) and then add a patch that removes 0.

OK.  I still don't see the "slick" solution, so let's go with that.

--b.

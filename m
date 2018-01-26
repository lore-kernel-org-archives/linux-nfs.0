Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:54096 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751249AbeAZVeF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 26 Jan 2018 16:34:05 -0500
Date: Fri, 26 Jan 2018 16:34:05 -0500
To: Olga Kornievskaia <kolga@netapp.com>
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v6 05/10] NFSD first draft of async copy
Message-ID: <20180126213405.GA7770@fieldses.org>
References: <20171024174752.74910-1-kolga@netapp.com>
 <20171024174752.74910-6-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20171024174752.74910-6-kolga@netapp.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If I understand correctly (I may be wrong), once this patch is applied a
COPY may fail that previously worked--because we're switching over to
the asynchronous copy implementation before it's actually complete.

Of course, that's fixed by the end of this series.  But we try to avoid
that situation, where functionality is temporarily broken in the middle
of a patch series and then fixed later.

Options might be to squash this patch together with some of the later
patches.  Or go ahead and add this code but don't actually enable it
till later.  (E.g. arrange that the "if (!copy->cp_synchronous)" case
won't be taken till the last patch.  Maybe it already works that way, I
can't tell.)  Or maybe there's some slicker way that I don't see right
now.

--b.

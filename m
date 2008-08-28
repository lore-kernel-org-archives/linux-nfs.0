From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Bug in NFSV3 ACCESS Procedure reply
Date: Thu, 28 Aug 2008 14:54:25 -0400
Message-ID: <20080828185425.GA6146@fieldses.org>
References: <9344d2ec0808271241x375a4d86r6cfa7c10beb905c8@mail.gmail.com> <20080828173424.GA3529@fieldses.org> <9344d2ec0808281041w15e2738ew546531398f80a312@mail.gmail.com> <20080828174917.GC3529@fieldses.org> <9344d2ec0808281052s71efeeebh81fea6805b6eef10@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Dilip Kumar <udilipkumar@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:40388 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752646AbYH1Sy1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Aug 2008 14:54:27 -0400
In-Reply-To: <9344d2ec0808281052s71efeeebh81fea6805b6eef10-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 28, 2008 at 10:52:07AM -0700, Dilip Kumar wrote:
> Do you see this issue on your version too? Not sure if there is a
> patch already addressing this issue.

Hm.  It looks like it may just be this:

static struct accessmap nfs3_diraccess[] = {
    {   NFS3_ACCESS_READ,       MAY_READ                        },
    {   NFS3_ACCESS_LOOKUP,     MAY_EXEC                        },
    {   NFS3_ACCESS_MODIFY,     MAY_EXEC|MAY_WRITE|MAY_TRUNC    },
    {   NFS3_ACCESS_EXTEND,     MAY_EXEC|MAY_WRITE              },
    {   NFS3_ACCESS_DELETE,     MAY_REMOVE                      },

    {   0,                      0                               }
};

So it doesn't claim write is allowed unless exec is also allowed.

I think that's actually how the local filesystem behaves--is there
any operation you can do locally with only write permissions?

Why is this behavior a problem for you, anyway?

--b.

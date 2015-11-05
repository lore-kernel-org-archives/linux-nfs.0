Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:32826 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161963AbbKEP5E (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Nov 2015 10:57:04 -0500
Received: by obbww6 with SMTP id ww6so43017656obb.0
        for <linux-nfs@vger.kernel.org>; Thu, 05 Nov 2015 07:57:04 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAHc6FU5xkjWJeGFR5mO8+OAEMwwU6yWK7H8CV1fn5dk-LS23-g@mail.gmail.com>
References: <1446563847-14005-1-git-send-email-agruenba@redhat.com>
	<1446563847-14005-46-git-send-email-agruenba@redhat.com>
	<CAHQdGtScoRb-722ES168O8tkp-Rbvwe6bZ=70WwgiXpCC3vsHw@mail.gmail.com>
	<CAHc6FU5xkjWJeGFR5mO8+OAEMwwU6yWK7H8CV1fn5dk-LS23-g@mail.gmail.com>
Date: Thu, 5 Nov 2015 10:57:04 -0500
Message-ID: <CAHQdGtQitLZq9fKHhzZbqS5ESRYNgNpw=M+y715mWMjFi-cgNQ@mail.gmail.com>
Subject: Re: [PATCH v13 45/51] sunrpc: Allow to demand-allocate pages to
 encode into
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Andreas Gruenbacher <agruenba@redhat.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Dave Chinner <david@fromorbit.com>,
        linux-ext4 <linux-ext4@vger.kernel.org>,
        XFS Developers <xfs@oss.sgi.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-cifs@vger.kernel.org,
        Linux API Mailing List <linux-api@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 5, 2015 at 6:07 AM, Andreas Gruenbacher <agruenba@redhat.com> wrote:
> Trond,
>
> On Tue, Nov 3, 2015 at 5:25 PM, Trond Myklebust
> <trond.myklebust@primarydata.com> wrote:
>> On Tue, Nov 3, 2015 at 10:17 AM, Andreas Gruenbacher
>> <agruenba@redhat.com> wrote:
>>> When encoding large, variable-length objects such as acls into xdr_bufs,
>>> it is easier to allocate buffer pages on demand rather than precomputing
>>> the required buffer size.
>>
>> NACK. We're not doing allocations from inside the XDR encoders. This
>> can and should be done before calling into the SUNRPC layer.
>
> an XDR-encoded ACL can be up to 64k (16 pages) in size. In practice,
> large ACLs like that will almost never occur and almost all ACLs will
> fit into a single page though.
>
> The XDR-encoded ACL contains strings for the user and group names
> which need to be looked up when the idmapper is used. Those lookups
> are somewhat expensive; in addition, the lookup results can change
> over time. When precomputing the size, allocating space, and then
> encoding the ACL, we could run out of space when encoding.
>
> So we could always allocate the maximum 16 pages, encode the acl, and
> free the unused pages. This would be rather wasteful though.
>
> Given how simple it is to allocate pages as we go, this seems the
> better choice here. This doesn't break any existing code either; NULL
> page pointers would have oopsed in xdr_get_next_encode_buffer before.
>
> From the memory management point of view, there is no difference in
> preallocating GFP_NOFS pages and allocating them on demand; the pages
> are allocated in the same task and locking context in both cases.
>
> So could you please explain why you object to this change?
>

Allocating memory deep in the bowels of the RPC code with the
expectation that it will be freed by the caller of the RPC request is
a layering violation of the ugliest sort. How is anyone who is
unfamiliar with the code going to be able to understand what is going
on without tracing through 1000 lines of code to spot where the
allocation is happening?

Aside from that, we do not want any non-critical blocking while
holding the RPC socket lock. Your allocation request will block all
further traffic to the server until it is satisfied. That includes
blocking page writeback, which might actually free up memory to
satisfy the allocation.

As I said above, there is no reason whatsoever to have to do all this
inside encode_setacl(). The entire ACL encoding into pages can be done
before even calling into the RPC layer, just like we do today.

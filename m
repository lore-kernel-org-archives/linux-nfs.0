Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47230 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752718Ab3FDOyP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Jun 2013 10:54:15 -0400
Date: Tue, 4 Jun 2013 10:53:22 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: "Stefan (metze) Metzmacher" <metze@samba.org>,
        Jeff Layton <jlayton@redhat.com>, viro@zeniv.linux.org.uk,
        matthew@wil.cx, linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        cluster-devel@redhat.com, sage@inktank.com,
        samba-technical@lists.samba.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, linux-afs@lists.infradead.org,
        dhowells@redhat.com, smfrench@gmail.com, linux-fsdevel@vger.kernel.org,
        ceph-devel@vger.kernel.org, akpm@linux-foundation.org,
        swhiteho@redhat.com
Subject: Re: [PATCH v1 11/11] locks: give the blocked_hash its own spinlock
Message-ID: <20130604145322.GH2109@fieldses.org>
References: <1370056054-25449-1-git-send-email-jlayton@redhat.com>
 <1370056054-25449-12-git-send-email-jlayton@redhat.com>
 <51ADF789.70906@samba.org>
 <20130604144640.GA7730@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130604144640.GA7730@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 04, 2013 at 07:46:40AM -0700, Christoph Hellwig wrote:
> Having RCU for modification mostly workloads never is a good idea, so
> I don't think it makes sense to mention it here.
> 
> If you care about the overhead it's worth trying to use per-cpu lists,
> though.

Yes.  The lock and unlock could happen on different CPU's--but I think
you can make the rule that the lock stays associated with the list it
was first put on, and then it's correct in general and hopefully quick
in the common case.

--b.

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:34606 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751317Ab3FDPvc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Jun 2013 11:51:32 -0400
Date: Tue, 4 Jun 2013 07:46:40 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "Stefan (metze) Metzmacher" <metze@samba.org>
Cc: Jeff Layton <jlayton@redhat.com>, viro@zeniv.linux.org.uk, matthew@wil.cx,
        bfields@fieldses.org, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, cluster-devel@redhat.com, sage@inktank.com,
        samba-technical@lists.samba.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, linux-afs@lists.infradead.org,
        dhowells@redhat.com, smfrench@gmail.com, linux-fsdevel@vger.kernel.org,
        ceph-devel@vger.kernel.org, akpm@linux-foundation.org,
        swhiteho@redhat.com
Subject: Re: [PATCH v1 11/11] locks: give the blocked_hash its own spinlock
Message-ID: <20130604144640.GA7730@infradead.org>
References: <1370056054-25449-1-git-send-email-jlayton@redhat.com>
 <1370056054-25449-12-git-send-email-jlayton@redhat.com>
 <51ADF789.70906@samba.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <51ADF789.70906@samba.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Having RCU for modification mostly workloads never is a good idea, so
I don't think it makes sense to mention it here.

If you care about the overhead it's worth trying to use per-cpu lists,
though.


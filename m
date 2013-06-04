Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:4522 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752908Ab3FDO5z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Jun 2013 10:57:55 -0400
Date: Tue, 4 Jun 2013 10:56:56 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: "Stefan (metze) Metzmacher" <metze@samba.org>, viro@zeniv.linux.org.uk,
        matthew@wil.cx, bfields@fieldses.org, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, cluster-devel@redhat.com, sage@inktank.com,
        samba-technical@lists.samba.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, linux-afs@lists.infradead.org,
        dhowells@redhat.com, smfrench@gmail.com, linux-fsdevel@vger.kernel.org,
        ceph-devel@vger.kernel.org, akpm@linux-foundation.org,
        swhiteho@redhat.com
Subject: Re: [PATCH v1 11/11] locks: give the blocked_hash its own spinlock
Message-ID: <20130604105656.18663efa@corrin.poochiereds.net>
In-Reply-To: <20130604144640.GA7730@infradead.org>
References: <1370056054-25449-1-git-send-email-jlayton@redhat.com>
	<1370056054-25449-12-git-send-email-jlayton@redhat.com>
	<51ADF789.70906@samba.org>
	<20130604144640.GA7730@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 4 Jun 2013 07:46:40 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> Having RCU for modification mostly workloads never is a good idea, so
> I don't think it makes sense to mention it here.
> 
> If you care about the overhead it's worth trying to use per-cpu lists,
> though.
> 

Yeah, I looked at those too in an earlier set and it did help some.
Moving to a hashtable for the blocked_list really seemed to help the
most there, but percpu lists with lglocks or something might help a lot
on the file_lock_list.

-- 
Jeff Layton <jlayton@redhat.com>

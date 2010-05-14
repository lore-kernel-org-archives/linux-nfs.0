Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fn.samba.org ([216.83.154.106]:48348 "EHLO lists.samba.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751277Ab0ENSYQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 May 2010 14:24:16 -0400
Date: Fri, 14 May 2010 11:16:43 -0700
From: Jeremy Allison <jra@samba.org>
To: Jamie Lokier <jamie@shareable.org>
Cc: Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trond.myklebust@fys.uio.no>,
        Mi Jinlong <mijinlong@cn.fujitsu.com>,
        NFSv3 list <linux-nfs@vger.kernel.org>, linux-fsdevel@vger.kernel.org,
        ebiederm@xmission.com, adobriyan@gmail.com, viro@ZenIV.linux.org.uk
Subject: Re: [PATCH] VFS: Unlink should revoke all outstanding leases on
	file
Message-ID: <20100514181643.GC9217@samba1>
Reply-To: Jeremy Allison <jra@samba.org>
References: <4BED195F.3070504@cn.fujitsu.com> <20100514055844.109d2fdc@tlielax.poochiereds.net> <1273857471.4732.7.camel@localhost.localdomain> <20100514133819.5e383485@tlielax.poochiereds.net> <20100514174653.GC10133@shareable.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100514174653.GC10133@shareable.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, May 14, 2010 at 06:46:53PM +0100, Jamie Lokier wrote:

> I think you can delete open files on Windows nowadays, if they are
> opened with a particular flag.

You can only mark them as "to be deleted" once the last opener
closes. They still exist in the namespace.

Jeremy.

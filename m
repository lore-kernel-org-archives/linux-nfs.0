Return-Path: linux-nfs-owner@vger.kernel.org
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:38057 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751239Ab3FCTE6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Jun 2013 15:04:58 -0400
Message-ID: <1370286292.15671.4.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH v1 00/11] locks: scalability improvements for file
 locking
From: Davidlohr Bueso <davidlohr.bueso@hp.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: viro@zeniv.linux.org.uk, matthew@wil.cx, bfields@fieldses.org,
        dhowells@redhat.com, sage@inktank.com, smfrench@gmail.com,
        swhiteho@redhat.com, Trond.Myklebust@netapp.com,
        akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
        linux-afs@lists.infradead.org, ceph-devel@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        cluster-devel@redhat.com, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, piastryyy@gmail.com
Date: Mon, 03 Jun 2013 12:04:52 -0700
In-Reply-To: <1370056054-25449-1-git-send-email-jlayton@redhat.com>
References: <1370056054-25449-1-git-send-email-jlayton@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2013-05-31 at 23:07 -0400, Jeff Layton wrote:
> This is not the first attempt at doing this. The conversion to the
> i_lock was originally attempted by Bruce Fields a few years ago. His
> approach was NAK'ed since it involved ripping out the deadlock
> detection. People also really seem to like /proc/locks for debugging, so
> keeping that in is probably worthwhile.

Yep, we need to keep this. FWIW, lslocks(8) relies on /proc/locks.

Thanks,
Davidlohr


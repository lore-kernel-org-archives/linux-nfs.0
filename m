Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:37540 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750971Ab2EIJWD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 May 2012 05:22:03 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20120509002420.GL5091@dastard>
References: <20120509002420.GL5091@dastard> <20120419140558.17272.74360.stgit@warthog.procyon.org.uk> <16281.1336508382@redhat.com>
To: Dave Chinner <david@fromorbit.com>
Cc: dhowells@redhat.com, adilger@dilger.ca, bfields@fieldses.org,
        smfrench@gmail.com, ben@decadent.org.uk, Trond.Myklebust@netapp.com,
        roland@hack.frob.com, jra@samba.org, bernd.schubert@itwm.fraunhofer.de,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-ext4@vger.kernel.org, linux-api@vger.kernel.org,
        libc-alpha@sourceware.org
Subject: Re: Extended file stat: Splitting file- and fs-specific info?
Date: Wed, 09 May 2012 10:21:14 +0100
Message-ID: <20170.1336555274@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Dave Chinner <david@fromorbit.com> wrote:

> I don't think we want to expose the inode generation numbers. It is
> trivial to construct NFS file handles (usually just fsid, inode
> number and generation) with that information and hence bypass
> security checks to access files.

I was asked for it by Bernd Schubert for userspace NFS servers and FUSE -
maybe he can say what he wants it for.

I also have a note that Jeremy Allison asked for it, but I can't find where or
why, so that might be an error.

It looks like FreeBSD do have an st_gen field in their stat struct, but it's
only filled in for root.  Maybe I could do something like that?

David

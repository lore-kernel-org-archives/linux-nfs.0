Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24704 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753603Ab0GVMPD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Jul 2010 08:15:03 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <alpine.LSU.2.01.1007221228260.6115@obet.zrqbmnf.qr>
References: <alpine.LSU.2.01.1007221228260.6115@obet.zrqbmnf.qr> <20100715021709.5544.64506.stgit@warthog.procyon.org.uk> <20100715021712.5544.44845.stgit@warthog.procyon.org.uk>
To: Jan Engelhardt <jengelh@medozas.de>
Cc: dhowells@redhat.com, viro@ZenIV.linux.org.uk,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-kernel@vger.kernel.org,
        samba-technical@lists.samba.org, linux-ext4@vger.kernel.org
Subject: Re: [PATCH 02/18] xstat: Add a pair of system calls to make extended file stats available [ver #6]
Date: Thu, 22 Jul 2010 13:14:47 +0100
Message-ID: <30448.1279800887@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Jan Engelhardt <jengelh@medozas.de> wrote:

> Linux already has a creation time field, it's called otime (there is no "b"
> in "creation"), and you will find scattered fragments of that all over the
> kernel (foremost, fs/jfs/, now btrfs, and I also notice sysvipc having
> something with that name).

It is?  It's called crtime in Ext4.  st_btime, however, would be compatible
with BSD's stat, and Samba would just use it by way of autoconf magic if it
appeared.

David

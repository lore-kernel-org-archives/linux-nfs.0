Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55825 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752811Ab0GZOUK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Jul 2010 10:20:10 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <1279944664.2944.8.camel@localhost>
References: <1279944664.2944.8.camel@localhost> <20100722175847.5552.11520.stgit@warthog.procyon.org.uk> <17723.1279897759@redhat.com>
To: Ian Kent <raven@themaw.net>
Cc: dhowells@redhat.com, viro@ZenIV.linux.org.uk,
        linux-fsdevel@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 1/6] Add a dentry op to handle automounting rather than abusing follow_link() [ver #2]
Date: Mon, 26 Jul 2010 15:19:57 +0100
Message-ID: <9168.1280153997@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0


Ian Kent <raven@themaw.net> wrote:

> >  (4) Stops pathwalk at the automount point and returns that point in the fs
> >      tree if it decides not to automount rather than reporting ELOOP (see its
> >      use of EXDEV for this).

Does it make autofs easier if d_op->d_automount() is allowed to return -EXDEV
to request this?  Then you can return it in Oz mode to allow the daemon to
see/use the underlying mountpoint without recursing back into d_automount().

Ideally, the daemon would use AT_NO_AUTOMOUNT, but there's no way to pass that
to sys_mount() or sys_umount().

David

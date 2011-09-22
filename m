Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3575 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751838Ab1IVMvU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Sep 2011 08:51:20 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20110922124608.7739.27750.stgit@warthog.procyon.org.uk>
References: <20110922124608.7739.27750.stgit@warthog.procyon.org.uk>
To: miklos@szeredi.hu, raven@themaw.net, viro@ZenIV.linux.org.uk
Cc: dhowells@redhat.com, jlayton@redhat.com, gregkh@suse.de,
        torvalds@linux-foundation.org, linux-nfs@vger.kernel.org,
        leonardo.lists@gmail.com
Subject: Re: [PATCH] NFS4: Revert commit to make the automount code ignore LOOKUP_FOLLOW
Date: Thu, 22 Sep 2011 13:50:37 +0100
Message-ID: <7857.1316695837@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

David Howells <dhowells@redhat.com> wrote:

> There are some alternatives:

 (5) Have stat(), getxattr(), etc. supply LOOKUP_NO_AUTOMOUNT unconditionally.

David

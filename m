Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42336 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752019Ab0GVSB3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Jul 2010 14:01:29 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20100722175913.5552.3905.stgit@warthog.procyon.org.uk>
References: <20100722175913.5552.3905.stgit@warthog.procyon.org.uk> <20100722175847.5552.11520.stgit@warthog.procyon.org.uk>
Cc: dhowells@redhat.com, viro@ZenIV.linux.org.uk,
        linux-fsdevel@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 6/6] Add an AT_NO_AUTOMOUNT flag to suppress terminal automount
Date: Thu, 22 Jul 2010 19:01:21 +0100
Message-ID: <11464.1279821681@redhat.com>
To: unlisted-recipients:; (no To-header on input)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

David Howells <dhowells@redhat.com> wrote:

> with follow_link semantics.  This can be used by fstatat()/xstat() users to

xstat() shouldn't be mentioned here.

David

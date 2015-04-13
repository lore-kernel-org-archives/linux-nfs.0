Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38016 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754074AbbDMLdt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Apr 2015 07:33:49 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <5527C9A0.6030502@gmail.com>
References: <5527C9A0.6030502@gmail.com>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] fscache: put reference of parent's usage and n_children
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Mon, 13 Apr 2015 12:33:42 +0100
Message-ID: <30571.1428924822@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Kinglong Mee <kinglongmee@gmail.com> wrote:

> If netfs exist, fscache must put the reference of parent's
> usage and n_children, otherwise, never be decreased.

Good catch.  Though it might be preferable to only increment the counters if
the list_add() is done.

David

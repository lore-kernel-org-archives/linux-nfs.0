Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36087 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932184AbbDMLgu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Apr 2015 07:36:50 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <5527D42A.800@gmail.com>
References: <5527D42A.800@gmail.com>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] fscache: Don't override netfs->primary_index if register failed
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Mon, 13 Apr 2015 12:36:44 +0100
Message-ID: <30686.1428925004@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Kinglong Mee <kinglongmee@gmail.com> wrote:

> Only override netfs->primary_index when registering success.

It shouldn't matter since the fscache_netfs struct being registered should not
be active when __fscache_register_netfs() is called upon it.  It does,
however, make things a bit more readable, so I'll take it.

David

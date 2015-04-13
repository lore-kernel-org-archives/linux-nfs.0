Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36834 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754101AbbDMNMn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Apr 2015 09:12:43 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <552BBE2E.5050903@gmail.com>
References: <552BBE2E.5050903@gmail.com> <552BB530.50405@gmail.com> <5527C9A0.6030502@gmail.com> <30571.1428924822@warthog.procyon.org.uk> <32264.1428929064@warthog.procyon.org.uk>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 1/2] FSCACHE: Increase reference of parent after registering netfs success
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Mon, 13 Apr 2015 14:12:39 +0100
Message-ID: <1961.1428930759@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Kinglong Mee <kinglongmee@gmail.com> wrote:

> -	netfs->primary_index->parent		= &fscache_fsdef_index;

fscache_fsdef_index is a static variable so leave this where it is.

David

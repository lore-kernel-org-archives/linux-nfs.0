Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45188 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751890AbdHIMzr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 9 Aug 2017 08:55:47 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20170807212355.29127-1-kolga@netapp.com>
References: <20170807212355.29127-1-kolga@netapp.com>
To: Olga Kornievskaia <kolga@netapp.com>
Cc: dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-api@vger.kernel.org
Subject: Re: [RFC v3 0/3] VFS/NFS support to destroy FS credentials
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Wed, 09 Aug 2017 13:55:45 +0100
Message-ID: <9674.1502283345@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

You may also want to flush any outstanding dirty data and wait for in-progress
operations.

David

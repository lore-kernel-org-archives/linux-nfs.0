Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:61785 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755241Ab2BHKdh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Feb 2012 05:33:37 -0500
From: David Howells <dhowells@redhat.com>
In-Reply-To: <1328619733-30859-1-git-send-email-steved@redhat.com>
References: <1328619733-30859-1-git-send-email-steved@redhat.com>
To: Steve Dickson <steved@redhat.com>
Cc: dhowells@redhat.com, James Morris <jmorris@namei.org>,
        Linux Keyring Mailing list <keyrings@linux-nfs.org>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [Keyrings] [PATCH] NFS: Make keys writable on the idmap keyring.
Date: Wed, 08 Feb 2012 10:33:29 +0000
Message-ID: <2075.1328697209@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Steve Dickson <steved@redhat.com> wrote:

> To take advantage of the "Allow special keyrings to be
> cleared" keyring patch the NFS keyring has to be writeable.

That's not true.

I'll push the "Allow special keyrings to be cleared" keyring patch to James
now.

David

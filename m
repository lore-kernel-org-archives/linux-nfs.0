Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:41674 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751168AbeBUWzs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 21 Feb 2018 17:55:48 -0500
Date: Wed, 21 Feb 2018 17:55:48 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kenneth Dsouza <kdsouza@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Add support for -R option in nfs4_getfacl so we can list
 the ACLs of all files and directories recursively.
Message-ID: <20180221225548.GC6535@fieldses.org>
References: <20180207213055.18211-1-kdsouza@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180207213055.18211-1-kdsouza@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

People have been request recursive operation and I keep not getting
around to it, thanks for doing this.

How are you testing this?

--b.

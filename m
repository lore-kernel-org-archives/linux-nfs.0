Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:56250 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750819Ab3KDV1M (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Nov 2013 16:27:12 -0500
Date: Mon, 4 Nov 2013 16:27:10 -0500
From: J Bruce Fields <bfields@fieldses.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Linux NFS <linux-nfs@vger.kernel.org>, Steve Dickson <steved@redhat.com>,
        Jeff Layton <jlayton@redhat.com>,
        David Quigley <dpquigl@davequigley.com>
Subject: Re: [PATCH 1/5] NFSv4.2: Fix a mismatch between Linux labeled NFS
 and the NFSv4.2 spec
Message-ID: <20131104212710.GA7458@fieldses.org>
References: <1383598272-17737-1-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1383598272-17737-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 04, 2013 at 03:51:08PM -0500, Trond Myklebust wrote:
> In the spec, the security label attribute id is '80', which means that
> it should be bit number 80-64 == 16 in the 3rd word of the bitmap.

And the same error got copied to wireshark.

	https://bugs.wireshark.org/bugzilla/show_bug.cgi?id=9383

--b.

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from [76.245.85.235] ([76.245.85.235]:51016 "EHLO cynthia.pants.nu"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751732Ab0CIHGe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Mar 2010 02:06:34 -0500
Date: Mon, 8 Mar 2010 23:04:44 -0800
From: Brad Boyer <flar@allandria.com>
To: Casey Schaufler <casey@schaufler-ca.com>
Cc: James Morris <jmorris@namei.org>, linux-nfs@vger.kernel.org,
        linux-security-module@vger.kernel.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 0/6][v4][RFC] NFSv3: implement extended attribute protocol (XATTR)
Message-ID: <20100309070444.GA18216@cynthia.pants.nu>
References: <alpine.LRH.2.00.1002261457420.25193@tundra.namei.org> <alpine.LRH.2.00.1003082122340.6314@tundra.namei.org> <20100309035932.GA14237@cynthia.pants.nu> <4B95E167.40306@schaufler-ca.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4B95E167.40306@schaufler-ca.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Mar 08, 2010 at 09:49:27PM -0800, Casey Schaufler wrote:
> Another is to NFS mount the filesystem back on to the server,
> in which case James' scheme works just dandy. It's a trick that
> I've used more than once in the Unix world for this exact purpose.
> Of course you have to arrange your mount points in advance with
> malice aforethought, but that's likely something you're used to
> by now.

That would definitely work, but it's not ideal. Obviously if it's
being accessed over NFS in one place it probably good enough
everywhere, but it's overhead that could be eliminated.

	Brad Boyer
	flar@allandria.com


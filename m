Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:35797 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752679AbbJWSZG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Oct 2015 14:25:06 -0400
Date: Fri, 23 Oct 2015 14:25:06 -0400
To: Pankaj Singh <psingh.ait@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Max connurent connections limit on nfsvs server.
Message-ID: <20151023182506.GB15564@fieldses.org>
References: <CAPrqf91BcyKjsHMK+fYm6cbxEkeU__2NYF=XZhL+TAmZ-LnzMw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAPrqf91BcyKjsHMK+fYm6cbxEkeU__2NYF=XZhL+TAmZ-LnzMw@mail.gmail.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 23, 2015 at 12:07:40PM +0530, Pankaj Singh wrote:
> I am new to nfs.
> What would be the max connurent connections an nfsv3 server can support?
> Even if we are an high end hardware and fastest(have high throughput)
> underlining file system.

I don't think we can give a single number, you may hit different limits
depending on your hardware and workload.

Note that there are max_connections tunables for both nfsd and nlm
(/porc/fs/nfsd/max_connections and
/sys/module/lockd/parameters/nlm_max_connections) which you may need to
adjust (but of course that doesn't solve all problems, it just controls
some code that causes the server to drop connections past those limits.)

--b.

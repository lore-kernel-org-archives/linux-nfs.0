Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([173.255.197.46]:41476 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751452AbbBJPpZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Feb 2015 10:45:25 -0500
Date: Tue, 10 Feb 2015 10:45:23 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: hang on xfstests generic/074
Message-ID: <20150210154523.GG28949@fieldses.org>
References: <20150210154306.GF28949@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150210154306.GF28949@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 10, 2015 at 10:43:06AM -0500, bfields wrote:
> I finally got around to running xfstests as part of my regular testing
> and ran across a reproduceable hang on generic/074:

By the way, running ./check -nfs -g auto, I also see failures on:

generic/005 generic/017 generic/031 generic/032 generic/033 generic/035
generic/037 generic/053 generic/062 generic/068 generic/088 generic/089
generic/105 generic/126 generic/133 generic/184 generic/225 generic/277
generic/294 generic/306

and another 94 tests were skipped.  I haven't looked into any of those
yet.

All of this is over 4.1.

--b.

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46782 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754047AbbAFTIE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Jan 2015 14:08:04 -0500
Date: Tue, 6 Jan 2015 14:08:00 -0500
To: Weston Andros Adamson <dros@primarydata.com>
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Trond Myklebust <Trond.Myklebust@primarydata.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/3] Remove function macros from nfs4_fs.h
Message-ID: <20150106190800.GB28003@fieldses.org>
References: <1420485444-20101-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1C602278-4A23-4975-8339-7AFF0606B154@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <1C602278-4A23-4975-8339-7AFF0606B154@primarydata.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 05, 2015 at 03:31:46PM -0500, Weston Andros Adamson wrote:
> These patches look good to me, but have you tested them? ;)
> 
> I mean, does anyone have a server that implements SP4_MACH_CRED to test against?
> When I originally developed this feature, I tested against a hacked nfsd…
> that code was really ugly (not ready for upstreaming), but allowed me to test the client
> feature.
> 
> IRRC the server side is difficult because the server has to keep stateid to credential
> mappings, so when the machine cred was used it could check access against the acting cred. 
> 
> If there aren’t any servers to test this against, maybe we remove this feature? It can always
> be revived once there is a server to test against.

The Linux server should support MACH_CRED as of
57266a6e916e2522ea61758a3ee5576b60156791 "nfsd4: implement minimal
SP4_MACH_CRED".  (Well, plus some later bugfixes.)  But I think anything
since 3.14 should be OK.

That said, I wouldn't be surprised if it has problems.  But please do
test against that and let me know....

--b.

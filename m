Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:48806 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750997AbcFCDin (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Jun 2016 23:38:43 -0400
Date: Fri, 3 Jun 2016 04:38:38 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Oleg Drokin <green@linuxhacker.ru>
Cc: Trond Myklebust <trondmy@primarydata.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "<linux-kernel@vger.kernel.org> Mailing List"
	<linux-kernel@vger.kernel.org>,
        "<linux-fsdevel@vger.kernel.org>" <linux-fsdevel@vger.kernel.org>
Subject: Re: NFS/d_splice_alias breakage
Message-ID: <20160603033838.GM14480@ZenIV.linux.org.uk>
References: <CF78E59B-F311-437B-9D1C-1F3FF6C22126@linuxhacker.ru>
 <F0790F28-A8F9-406E-8B1A-F3F3773DA28E@primarydata.com>
 <07EDB238-7EB6-48EC-8ECF-9D5A4B0986B2@linuxhacker.ru>
 <20160603032625.GJ14480@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20160603032625.GJ14480@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 03, 2016 at 04:26:25AM +0100, Al Viro wrote:
> On Thu, Jun 02, 2016 at 08:54:06PM -0400, Oleg Drokin wrote:
> 
> > > Al, I’ve been distracted by personal matters in the past 6 months. What is there to guarantee exclusion of the readdirplus dentry instantiation and the NFSv4 atomic open in the brave new world of VFS, June 2016 vintage?
> 
> d_alloc_parallel() use by all parties involved.

Grr...  That should've been a reply to Trond, obviously.

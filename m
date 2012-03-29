Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46804 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760074Ab2C2VRQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 29 Mar 2012 17:17:16 -0400
Date: Thu, 29 Mar 2012 17:17:13 -0400
From: Dr James Bruce Fields <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Orion Poplawski <orion@cora.nwra.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [nfsv4] open(O_CREAT) returns EEXISTS on symbolic link created
 on another system until stat()ed
Message-ID: <20120329211713.GD21493@fieldses.org>
References: <1333040091.5547.32.camel@lade.trondhjem.org>
 <4F749CCA.3000400@cora.nwra.com>
 <1333042863.5547.37.camel@lade.trondhjem.org>
 <4F74A4D5.1040802@cora.nwra.com>
 <20120329193100.GA20329@fieldses.org>
 <1333052170.10318.6.camel@lade.trondhjem.org>
 <1333053750.10318.15.camel@lade.trondhjem.org>
 <20120329205035.GB21493@fieldses.org>
 <1333054622.10318.19.camel@lade.trondhjem.org>
 <20120329210838.GC21493@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120329210838.GC21493@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 29, 2012 at 05:08:38PM -0400, Dr James Bruce Fields wrote:
> Anyway, something like the following (untested) should change v3 to
> return nfs_ok in this case, and v4 to return the same errors it would on
> a non-create open.

Looking at the history, I think the v3 behavior has been there from the
start.  I wonder why we've never gotten a bug report?

Looking at wireshark.... I guess the client always does a lookup first,
so we never hit this case (unless someone replaces the file by a
non-regular-file between a lookup and a create?)

--b.

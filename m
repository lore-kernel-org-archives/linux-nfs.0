Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e23smtp01.au.ibm.com ([202.81.31.143]:35568 "EHLO
	e23smtp01.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753179AbZIBRuM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Sep 2009 13:50:12 -0400
Received: from d23relay02.au.ibm.com (d23relay02.au.ibm.com [202.81.31.244])
	by e23smtp01.au.ibm.com (8.14.3/8.13.1) with ESMTP id n82Hn1VY006688
	for <linux-nfs@vger.kernel.org>; Thu, 3 Sep 2009 03:49:01 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay02.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n82HoEvb1278156
	for <linux-nfs@vger.kernel.org>; Thu, 3 Sep 2009 03:50:14 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n82HoDEg016914
	for <linux-nfs@vger.kernel.org>; Thu, 3 Sep 2009 03:50:14 +1000
Date: Wed, 2 Sep 2009 23:19:57 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: trond.myklebust@netapp.com, nfsv4@linux-nfs.org, ffilzlnx@us.ibm.com,
        agruen@suse.de, sfrench@us.ibm.com, linux-nfs@vger.kernel.org
Subject: Re: POSIX ACL support for NFSV4 (using sideband protocol)
Message-ID: <20090902174957.GA10701@skywalker.linux.vnet.ibm.com>
References: <1251894268-1555-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20090902164243.GA17126@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20090902164243.GA17126@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Sep 02, 2009 at 12:42:43PM -0400, J. Bruce Fields wrote:
> On Wed, Sep 02, 2009 at 05:54:20PM +0530, Aneesh Kumar K.V wrote:
> > This patch series implement POSIX ACL support for NFSV4 clients
> > using sideband protocol.
> 
> What motivates this?  Who exactly wants this and why?   What would be
> the advantages compared to other options, such as:
> 
> 	- native v4 support in filesystems, or
> 	- improved client-side acl tools that provided a user interface
> 	  for v4 acls closer to that for v3 acls, or
> 	- a v4.x extension to add support to the main protocol?
> 
> Is there interest in implementing this on any OS other than linux, or
> would this be a linux-only extension for the forseeable future?
> 
> What sideband protocol exactly?  If it's exactly the same protocol as
> the one used with v3, there must be some slight mismatches: e.g. v4
> filehandles are allowed to be longer.  How do you deal with these?
> 

It is similar to v3 with longer file handle. Also it doesn't support
attribute update as a part of the acl calls. I does zap cache and expect
the client to do another call to get the updated attribute values. Primary
motivation is to avoid side band rpc having to handle compound request so
that we can keep it simple.

-aneesh

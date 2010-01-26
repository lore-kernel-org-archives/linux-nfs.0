Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from tundra.namei.org ([65.99.196.166]:41197 "EHLO tundra.namei.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751710Ab0AZXG0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Jan 2010 18:06:26 -0500
Date: Wed, 27 Jan 2010 10:06:19 +1100 (EST)
From: James Morris <jmorris@namei.org>
To: Christoph Hellwig <hch@infradead.org>
cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/4][v2: minor update][RFC] NFSv3: implement extended attribute
 (XATTR)
Message-ID: <alpine.LRH.2.00.1001270952420.15158@tundra.namei.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

This is an updated version of the NFSv3 xattr patchset which I initially 
posted in Sept 2009:

http://marc.info/?l=linux-nfs&m=125337309409400&w=2

This version of the patchset is a simple rebase to the current devel 
branch of the upstream NFS tree.  Christoph was interested in seeing the 
updated NFS xattr handlers (following the flags API change), so I figured 
I'd post just the rebased patches.  Other than that, this will only be of 
interest to folk who wish to play with the code using a current kernel.

I'm still in the process of incorporating functional feedback, 
particularly following a discussion with Trond on using a private 
namespace on the server to allow simple storage of all kinds of xattrs.  
An updated patchset with this implemented should follow fairly soon.


- James
-- 
James Morris
<jmorris@namei.org>

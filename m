Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e35.co.us.ibm.com ([32.97.110.153]:37545 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750784Ab1KMSZg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 13 Nov 2011 13:25:36 -0500
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <treinish@linux.vnet.ibm.com>;
	Sun, 13 Nov 2011 11:25:36 -0700
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pADIPYVe150992
	for <linux-nfs@vger.kernel.org>; Sun, 13 Nov 2011 11:25:34 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pADIPWk0029559
	for <linux-nfs@vger.kernel.org>; Sun, 13 Nov 2011 11:25:33 -0700
Date: Sun, 13 Nov 2011 13:25:31 -0500
From: Matthew Treinish <treinish@linux.vnet.ibm.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: NeilBrown <neilb@suse.de>, Christoph Hellwig <hch@infradead.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH/RFC 0/7] Volatile Filehandle Client-side Support
Message-ID: <20111113182531.GB4084@Gelgoog.pok.ibm.com>
References: <1321052673-22171-1-git-send-email-treinish@linux.vnet.ibm.com>
 <1321056809.8733.2.camel@lade.trondhjem.org>
 <20111112144953.GA3740@infradead.org>
 <20111113145400.6c7a9be3@notabene.brown>
 <20111113164240.GB28574@fieldses.org>
 <20111113164536.GC28574@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20111113164536.GC28574@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Nov 13, 2011 at 11:45:36AM -0500, J. Bruce Fields wrote:
> 
> Also, could a re-looked-up file be considered sufficiently safe to use
> if all the attributes matched?
> 
> (I guess not: inode numbers, change attributes, etc., could agree by
> coincidence, so it would never be completely reliable.)
> 

We thought of doing something like that, but like you said it's not a 
guarantee. That was part of the reason why we went with the mount option.
By using it, the user will assume that whatever files the re-look-ups return
are safe/correct.

-Matt Treinish


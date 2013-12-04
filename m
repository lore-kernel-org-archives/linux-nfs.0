Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.pingtimeout.net ([194.187.214.64]:51182 "EHLO
	mx1.pingtimeout.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932073Ab3LDLPq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Dec 2013 06:15:46 -0500
Message-ID: <529F0EDD.1070403@pingtimeout.net>
Date: Wed, 04 Dec 2013 13:15:41 +0200
From: =?ISO-8859-1?Q?Antti_T=F6nkyr=E4?= <daedalus@pingtimeout.net>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>
CC: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: Patch for mapping EILSEQ into NFSERR_INVAL
References: <529CEBC3.8060505@pingtimeout.net> <20131204083118.GA30216@infradead.org>
In-Reply-To: <20131204083118.GA30216@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2013-12-04 10:31, Christoph Hellwig wrote:
> Please just fix ntfs to do the mapping for you, EILSEQ is not an
> error the VFS or applications expect either.
>
How would you propose the mapping to be done? Are you sure about EILSEQ 
not being an error that VFS/applications expect, my userspace tools seem 
to handle local filesystem returning EILSEQ just fine?

Moreover I think we really should see why nfs goes into permanent I/O 
error state when this is triggered. I don't really mind seeing nfs 
unhandled error codes in my kernel log and I/O error on the nfs client 
when trying to write badly named files but the fact we cannot recover 
from the situation (without closing all handles to the open share) is 
alarming.

- Antti

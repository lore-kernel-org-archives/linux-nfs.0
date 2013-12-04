Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.pingtimeout.net ([194.187.214.64]:51213 "EHLO
	mx1.pingtimeout.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932104Ab3LDLef (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Dec 2013 06:34:35 -0500
Message-ID: <529F1347.5000705@pingtimeout.net>
Date: Wed, 04 Dec 2013 13:34:31 +0200
From: =?ISO-8859-1?Q?Antti_T=F6nkyr=E4?= <daedalus@pingtimeout.net>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>
CC: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: Patch for mapping EILSEQ into NFSERR_INVAL
References: <529CEBC3.8060505@pingtimeout.net> <20131204083118.GA30216@infradead.org> <529F0EDD.1070403@pingtimeout.net> <20131204111933.GA20218@infradead.org>
In-Reply-To: <20131204111933.GA20218@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2013-12-04 13:19, Christoph Hellwig wrote:
> On Wed, Dec 04, 2013 at 01:15:41PM +0200, Antti T?nkyr? wrote:
>> >On 2013-12-04 10:31, Christoph Hellwig wrote:
>>> > >Please just fix ntfs to do the mapping for you, EILSEQ is not an
>>> > >error the VFS or applications expect either.
>>> > >
>> >How would you propose the mapping to be done? Are you sure about
>> >EILSEQ not being an error that VFS/applications expect, my userspace
>> >tools seem to handle local filesystem returning EILSEQ just fine?
> EILSEQ doesn't have a specified meaning for VFS operations.  Of course
> your app could handle it in some way, but that's your implementation
> specific way that has not base for it.
>
Okay, I understand your point. However, in this case I was referring to 
basic GNU/Linux userspace tools which I can hardly call my own apps :)

All in all I guess we could keep the current mapping path which 
eventually leads into I/O error. Next we should understand why the share 
fails when I/O error is emitted...

- Antti

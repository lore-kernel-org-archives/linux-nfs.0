Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from a.ns.miles-group.at ([95.130.255.143]:11949 "EHLO radon.swed.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932745AbcEKOK4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 May 2016 10:10:56 -0400
Subject: Re: Reconsidering exportable UBIFS
To: NeilBrown <nfbrown@novell.com>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>
References: <5702E7F5.1050807@nod.at>
 <871t5curbl.fsf@notabene.neil.brown.name>
Cc: "linux-mtd@lists.infradead.org" <linux-mtd@lists.infradead.org>,
        Artem Bityutskiy <dedekind1@gmail.com>,
        Christoph Hellwig <hch@infradead.org>,
        NFS List <linux-nfs@vger.kernel.org>
From: Richard Weinberger <richard@nod.at>
Message-ID: <57333D6D.3050601@nod.at>
Date: Wed, 11 May 2016 16:10:53 +0200
MIME-Version: 1.0
In-Reply-To: <871t5curbl.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=iso-8859-15
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Am 09.05.2016 um 00:18 schrieb NeilBrown:
>> The biggest problem I see is that UBIFS does not really support telldir()
>> and seekdir().
>> Directory offsets in UBIFS are plain hash values, so telldir()/seekdir() won't
>> correctly work if UBIFS faces hash collisions.
>> Currently UBIFS implements a hack which stores the UBIFS dent object into
>> file->private_data such that consecutive readdir()s are guaranteed to work.
>> A comment on UBIFS's readdir states:
>>  * This means that UBIFS cannot support NFS which requires full
>>  * 'seekdir()'/'telldir()' support.
>>
>> Is this still true? Maybe we can have NFS even if it is not perfect in
>> terms of performance.
> 
> How big are your hashes?
> ext3 messed up their readdir/telldir design too so they don't have
> guaranteed unique keys.
> When using 32bit hashes you can definitely get problems with
> collisions.  I have not heard of problems with 64bit hashes.
> 
> I may have the details slightly wrong, but as I recall non-uniqueness of
> cookies only causes a problem when the last cookie returned in a READDIR
> reply matches the first cookie returned in reply to the next readdir.
> So non-uniqueness is only a problem when it aligns badly.

UBIFS is using 32bit hashes, r5 hash from reiserfs. ;-\

Thanks,
//richard

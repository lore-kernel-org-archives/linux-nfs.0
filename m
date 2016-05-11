Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from a.ns.miles-group.at ([95.130.255.143]:11949 "EHLO radon.swed.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932841AbcEKOJj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 May 2016 10:09:39 -0400
Subject: Re: Reconsidering exportable UBIFS
To: NeilBrown <nfbrown@novell.com>, Al Viro <viro@ZenIV.linux.org.uk>
References: <5702E7F5.1050807@nod.at>
 <871t5curbl.fsf@notabene.neil.brown.name>
 <20160508232533.GH2694@ZenIV.linux.org.uk>
 <87y47ju8kk.fsf@notabene.neil.brown.name>
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        "linux-mtd@lists.infradead.org" <linux-mtd@lists.infradead.org>,
        Artem Bityutskiy <dedekind1@gmail.com>,
        Christoph Hellwig <hch@infradead.org>,
        NFS List <linux-nfs@vger.kernel.org>
From: Richard Weinberger <richard@nod.at>
Message-ID: <57333D1E.9090706@nod.at>
Date: Wed, 11 May 2016 16:09:34 +0200
MIME-Version: 1.0
In-Reply-To: <87y47ju8kk.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Am 09.05.2016 um 07:03 schrieb NeilBrown:
> On Mon, May 09 2016, Al Viro wrote:
> 
>> On Mon, May 09, 2016 at 08:18:22AM +1000, NeilBrown wrote:
>>
>>> Not puppies, just kittens.
>>>
>>> If you don't provide these functions, then exporting with
>>> "subtree_check" won't work.  That is no great loss except that people
>>> might find the failure confusing.
>>
>> 	OK, a client sends you a RENAME.  With fhandles of both parents +
>> old and new names in those.  Your task, should you choose to accept it, is
>> to figure out whether we should fail with nfserr_inval due to an attempt
>> to make a directory its own descendent.  Without being able to locate all
>> ancestors of a directory.
> 
> You are right, sorry.  I was thinking that get_parent() was for finding
> the parent of a non-directory, but it is for directories.  It does the
> equivalent of lookup("..").  So if you have a ".." link or something
> like it, it should be easy.  If you don't, it won't be easy at all.

Thanks for the detailed explanation.
UBIFS does not have ".." links in the on-flash layout.
So, we'd have to change this.

Thanks,
//richard

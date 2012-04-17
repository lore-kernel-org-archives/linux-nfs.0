Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f178.google.com ([209.85.212.178]:49498 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756030Ab2DQOCz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Apr 2012 10:02:55 -0400
Received: by wibhq7 with SMTP id hq7so687734wib.1
        for <linux-nfs@vger.kernel.org>; Tue, 17 Apr 2012 07:02:53 -0700 (PDT)
From: Miklos Szeredi <miklos@szeredi.hu>
To: Jeff Layton <jlayton@redhat.com>
Cc: "Myklebust\, Trond" <Trond.Myklebust@netapp.com>,
        Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>,
        Malahal Naineni <malahal@us.ibm.com>,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel\@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "pstaubach\@exagrid.com" <pstaubach@exagrid.com>,
        "viro\@ZenIV.linux.org.uk" <viro@ZenIV.linux.org.uk>,
        "hch\@infradead.org" <hch@infradead.org>,
        "michael.brantley\@deshaw.com" <michael.brantley@deshaw.com>,
        "sven.breuner\@itwm.fraunhofer.de" <sven.breuner@itwm.fraunhofer.de>
Subject: Re: [PATCH RFC] vfs: make fstatat retry on ESTALE errors from getattr call
References: <1334316311-22331-1-git-send-email-jlayton@redhat.com>
	<20120413150518.GA1987@us.ibm.com>
	<20120413114236.0e557e01@tlielax.poochiereds.net>
	<4F8B1B7B.3040304@itwm.fraunhofer.de>
	<20120416073655.7cdb90cf@corrin.poochiereds.net>
	<4F8C3036.2030702@itwm.fraunhofer.de>
	<20120416134642.1754cd3e@corrin.poochiereds.net>
	<1334604785.2879.23.camel@lade.trondhjem.org>
	<20120416154322.0d95e435@corrin.poochiereds.net>
	<1334607906.2879.36.camel@lade.trondhjem.org>
	<20120416190548.2463d1d0@corrin.poochiereds.net>
	<87sjg2o62z.fsf@tucsk.pomaz.szeredi.hu>
	<20120417093222.2ff5e1bd@corrin.poochiereds.net>
Date: Tue, 17 Apr 2012 16:03:06 +0200
In-Reply-To: <20120417093222.2ff5e1bd@corrin.poochiereds.net> (Jeff Layton's
	message of "Tue, 17 Apr 2012 09:32:22 -0400")
Message-ID: <87obqqo3qd.fsf@tucsk.pomaz.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jeff Layton <jlayton@redhat.com> writes:

>> The retry is needed when when we discover during ->getattr() that the
>> cached lookup returned a stale file handle.
>> 
>> If the lookup wasn't cached or if there was no lookup at all
>> (stat(".") and friends) then retrying will not gain anything.
>> 
>
> That's not necessarily the case, at least not with NFS. It's easily
> possible for you to do a full-fledged lookup over the wire, and then
> for that inode to be removed prior to issuing a call against the FH that
> you got back. 
>
>> And that also means that retrying multiple times is pointless, since
>> after the first retry we are sure to have up-to-date attributes.
>> 
>
> Again, it's not pointless. It's possible (though somewhat pathological)
> for you to hit the race above more than once in the same operation.
> Granted, it's an unlikely race but it is possible.

->lookup() should (and does AFAICS) leave a fully initialized inode with
up-to-date atributes in there and at that moment there's not a lot of
sense in fetching the attributes from the server *again*.

How that lookup is implemented is another question, I can see in
nfs3_proc_lookup() that it may or may not be atomic, and retrying (and
looping) there might make sense.  But it doesn't retry and doesn't loop,
so the fact is, it will either return ESTALE (and the path lookup will
retry once with LOOKUP_REVAL) or the inode *will* be up-to-date.

So I think I'm still right that it's pointless to do retry after a
non-cached lookup.

>> Unfortunately it's impossible for the filesystem to know whether a
>> ->getattr (or other inode operation) was perfromed after a cached or a
>> non-cached lookup.
>> 
>> I'm not sure what the right interface for this would be.  One would be
>> to just pass the "cached-or-not" information as a flag.  That works for
>> getattr() but not for other operations.
>> 
>> Another is to introduce atomic lookup+foo variants of these operations
>> just like for open.  E.g. the lookup+getattr is called if the cached
>> lookup fails or if the cached lookup succeeds and the plain ->getattr
>> call returns ESTALE.
>>
>
> To do that would require protocol support that we simply don't have. We
> don't have a way to (for instance) say via NFS "give me the attributes
> for this filename". Well, at least not for NFSv3...
>
> With v4 you could theoretically construct a compound that does that,
> but you'd have to assume that the server won't release the reference to
> the inode midway through the compound. That's a reasonably safe
> assumption.
>
> While it's nice to consider new atomic ops like this, it's not really
> possible with earlier versions of NFS.

It's just an interface question: where you put the retry logic for those
non-atomic protocols.  I think it's cleaner if the retry logic is in the
filesystem and not in the VFS.  Then NFS can do whatever it wants
without having to impose policy in the generic filesystem layer.

Thanks,
Miklos

Return-Path: <trond.myklebust@primarydata.com>
MIME-Version: 1.0
In-Reply-To: <alpine.OSX.2.19.9992.1512071423180.60717@planck.local>
References: <cover.1449503713.git.bcodding@redhat.com>
	<cc80e246ee323a21f3f318248bf38eda668e8eb9.1449503713.git.bcodding@redhat.com>
	<20151207184036.GA28959@infradead.org>
	<alpine.OSX.2.19.9992.1512071359370.60717@planck.local>
	<20151207192222.GA7938@infradead.org>
	<alpine.OSX.2.19.9992.1512071423180.60717@planck.local>
Date: Sat, 26 Dec 2015 22:13:56 -0500
Message-ID: <CAHQdGtT9Xw9kCA-9xw8tbwx8_4pucAzhMP_1N66xF=0gRCDUPQ@mail.gmail.com>
Subject: Re: [PATCH v2 02/10] NFS: Move the flock open mode check into nfs_flock()
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 7, 2015 at 2:24 PM, Benjamin Coddington <bcodding@redhat.com> wrote:
> On Mon, 7 Dec 2015, Christoph Hellwig wrote:
>
>> On Mon, Dec 07, 2015 at 02:13:47PM -0500, Benjamin Coddington wrote:
>> > I can fixup the comment for clarity as I just moved this chunk over.
>> >
>> > I'm not aware that flock() has ever had this check, but posix locks requires
>> > it.  My understanding is that since NFS may simulate flock() with posix
>> > locking, the check is necessary for NFS.
>>
>> Ah, right.  Maybe that's what should be in the comment here..
>
> Yes, good idea.  That's where someone is going to look when they investigate
> why their application breaks on NFS.
>

Should I expect a resend?

Cheers
  Trond

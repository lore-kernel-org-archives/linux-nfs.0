Return-Path: <trond.myklebust@primarydata.com>
MIME-Version: 1.0
In-Reply-To: <alpine.OSX.2.19.9992.1604011055480.20689@planck>
References: <20150210154306.GF28949@fieldses.org>
	<20150211123448.GA30174@infradead.org>
	<alpine.OSX.2.19.9992.1604011055480.20689@planck>
Date: Fri, 1 Apr 2016 11:26:31 -0400
Message-ID: <CAHQdGtQdJPMYVd+FXQdvRgPfm_uuR69ArZRiCmVAvPngOohgGg@mail.gmail.com>
Subject: Re: hang on xfstests generic/074
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Anna Schumaker <schumakeranna@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 1, 2016 at 10:57 AM, Benjamin Coddington
<bcodding@redhat.com> wrote:
> On Wed, 11 Feb 2015, Christoph Hellwig wrote:
>
>> On Tue, Feb 10, 2015 at 10:43:06AM -0500, J. Bruce Fields wrote:
>> > I finally got around to running xfstests as part of my regular testing
>> > and ran across a reproduceable hang on generic/074:
>>
>> Yes, I reported this about half a year ago.  It was caused (or at least
>> unhidden) by commit 2aca5b869ace67a63aab895659e5dc14c33a4d6e ("SUNRPC:
>> Add missing support for RPC_CLNT_CREATE_NO_RETRANS_TIMEOUT"). Reverting
>> that commit fixes the issue for me.
>
> I just ran into this.
>
> Now that we have SO_REUSEPORT, can we get rid of
> RPC_CLNT_CREATE_NO_RETRANS_TIMEOUT?

They are unrelated.

If you are hitting this hang, then you have borked server that is
dropping NFSv4 RPC requests. The old behaviour of having the client
break the connection is not actually sanctioned by the NFSv4 protocol.

Cheers
  Trond

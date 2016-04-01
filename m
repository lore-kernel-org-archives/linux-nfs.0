Return-Path: <trond.myklebust@primarydata.com>
MIME-Version: 1.0
In-Reply-To: <alpine.OSX.2.19.9992.1604011148030.18253@planck>
References: <cover.1459512819.git.bcodding@redhat.com>
	<CAHQdGtQ34HGqNLEh=mPPVhuOc9akkd9F--EdsA=y07isbO=KNg@mail.gmail.com>
	<alpine.OSX.2.19.9992.1604011148030.18253@planck>
Date: Fri, 1 Apr 2016 12:09:31 -0400
Message-ID: <CAHQdGtQKqs--JP6-OT6jjNh6JXTG6+cebL64t8OW8q771UL8FQ@mail.gmail.com>
Subject: Re: [PATCH 0/3] Include OFD lock owners when looking up state
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 1, 2016 at 11:48 AM, Benjamin Coddington
<bcodding@redhat.com> wrote:
> On Fri, 1 Apr 2016, Trond Myklebust wrote:
>
>> On Fri, Apr 1, 2016 at 11:34 AM, Benjamin Coddington
>> <bcodding@redhat.com> wrote:
>> > The client sends IO only under the open stateid when using OFD (and flock)
>> > locking instead of the appropriate lock stateid because the nfs_lock_context
>> > only tracks POSIX lockowners, which is the reference to the process' file
>> > table.
>> >
>> > This is a problem for two reasons.  The first is that rfc7530,
>> > section-9.1.4.5 states that IO sent by an entity corresponding to the
>> > lock-owner which holds a byte-range lock should be sent under the lock
>> > stateid for that lock.  Otherwise, a server enforcing mandatory byte-range
>> > locking might reject that operation.  Secondly, not tracking OFD lock owners
>> > means that accounting for IO sent under those owners is broken.  That
>> > creates a problem for some work to guarantee an unlock will be sent after
>> > operations scheduled under a lock complete.
>>
>> OK. Can we just kill this in the bud? No support for OFD locks in NFS:
>> this is nuts....
>
> Will you explain why it is nuts?  That would be helpful for me.

The point of the OFD crap was that they should work exactly like POSIX
locks except for the unlock-on-close, the latter being managed by the
VFS layer. If we have to make loads of changes to NFS in order to
change the tracking of lock owners, then the design itself is broken,
and needs to be fixed.

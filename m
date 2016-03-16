Return-Path: <trond.myklebust@primarydata.com>
MIME-Version: 1.0
In-Reply-To: <alpine.OSX.2.19.9992.1603161112440.11199@planck>
References: <79adfc63f33887475f6a0f0eeaacd8b52b2ed12c.1458119750.git.bcodding@redhat.com>
	<CAHQdGtS4pViRyWc+K+CLhmGrt1ar5PRcMpURap2_x2B5QpU2Fw@mail.gmail.com>
	<alpine.OSX.2.19.9992.1603161016560.11199@planck>
	<CAHQdGtThhkdmiYUgbWq1Jz00K8CKtOsgfxJUADhHXe5d3ygrSQ@mail.gmail.com>
	<alpine.OSX.2.19.9992.1603161050370.11199@planck>
	<alpine.OSX.2.19.9992.1603161112440.11199@planck>
Date: Wed, 16 Mar 2016 12:22:22 -0400
Message-ID: <CAHQdGtTMOjr8SMKOpM2tg0meAAgfLjgbMb5KjGDRoxt7LnEADw@mail.gmail.com>
Subject: Re: [PATCH] NFS: Retry a zero-length short read
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 16, 2016 at 11:20 AM, Benjamin Coddington
<bcodding@redhat.com> wrote:
> On Wed, 16 Mar 2016, Benjamin Coddington wrote:
>
>> On Wed, 16 Mar 2016, Trond Myklebust wrote:
>>
>> > On Wed, Mar 16, 2016 at 10:22 AM, Benjamin Coddington
>> > <bcodding@redhat.com> wrote:
>> > > On Wed, 16 Mar 2016, Trond Myklebust wrote:
>> > >
>> > >> On Wed, Mar 16, 2016 at 5:17 AM, Benjamin Coddington
>> > >> <bcodding@redhat.com> wrote:
>> > >> >
>> > >> > A zero-length short read without eof should be retried rather than sending
>> > >> > an error to the application.
>> > >>
>> > >>
>> > >> In what situation would returning a 0 length read not be a bug? If the
>> > >> server intended that we back off and retry, it has the alternative of
>> > >> sending a JUKEBOX/DELAY error.
>> > >
>> > > If the server completes a local read but then another writer comes in and
>> > > appends to the file before the server checks if it needs to set EOF, then
>> > > the response might be 0 length without EOF set.
>> >
>> > Why isn't that EOF check done atomically with the read itself? This
>> > still sounds like a server bug to me.
>>
>> I don't know -- I would guess because doing that atomically is harder than
>> not, and I don't know where the RFCs say that a zero length response without
>> eof is to be treated as an error or condition to be avoided.
>>
>> I'll look into that, and respond here.
>
> Indeed, it seems that it is more convenient for the linux server to send a
> zero-length response without eof when the file grows.  It would probably be
> more helpful if the server handled that case, but I think that 7530 states
> that it doesn't have to handle that case.

Here is what RFC5661 and RFC7530 say.

   If the READ ended at the end-of-file (formally, in a correctly formed
   READ request, if offset + count is equal to the size of the file), or
   the READ request extends beyond the size of the file (if offset +
   count is greater than the size of the file), eof is returned as TRUE;
   otherwise, it is FALSE.  A successful READ of an empty file will
   always return eof as TRUE.

Here is what RFC1813 says:

      eof
         If the read ended at the end-of-file (formally, in a
         correctly formed READ request, if READ3args.offset plus
         READ3resok.count is equal to the size of the file), eof
         is returned as TRUE; otherwise it is FALSE. A
         successful READ of an empty file will always return eof
         as TRUE.

Where does it say that the eof determination is allowed to be
non-atomic? Unlike structures such as change_info4, there isn't an
"atomic" flag to allow the server to communicate to the client that it
cannot rely on the eof flag. Since the determination is part of the
same READ operation, you can't point to the "COMPOUNDS are not atomic"
either.


>
> Ben
>
>> > > I'm also using https://tools.ietf.org/html/rfc7530#section-16.23.5 to guide
>> > > how I think the client should behave; it says that the client should retry
>> > > a short read without eof set.  I think that should include a response with
>> > > 0 length.
>>
>> Here's the verbatim from section 12.23.5:
>>
>>    If the server returns a "short read" (i.e., less data than requested
>>    and eof is set to FALSE), the client should send another READ to get
>>    the remaining data.  A server may return less data than requested
>>    under several circumstances.  The file may have been truncated by
>>    another client or perhaps on the server itself, changing the file
>>    size from what the requesting client believes to be the case.  This
>>    would reduce the actual amount of data available to the client.  It
>>    is possible that the server reduces the transfer size and so returns
>>    a short read result.  Server resource exhaustion may also result in a
>>    short read.
>>
>> Ben
>>
>> > >> > Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
>> > >> > ---
>> > >> >  fs/nfs/read.c |    5 -----
>> > >> >  1 files changed, 0 insertions(+), 5 deletions(-)
>> > >> >
>> > >> > diff --git a/fs/nfs/read.c b/fs/nfs/read.c
>> > >> > index eb31e23..7269d42 100644
>> > >> > --- a/fs/nfs/read.c
>> > >> > +++ b/fs/nfs/read.c
>> > >> > @@ -244,11 +244,6 @@ static void nfs_readpage_retry(struct rpc_task *task,
>> > >> >
>> > >> >         /* This is a short read! */
>> > >> >         nfs_inc_stats(hdr->inode, NFSIOS_SHORTREAD);
>> > >> > -       /* Has the server at least made some progress? */
>> > >> > -       if (resp->count == 0) {
>> > >> > -               nfs_set_pgio_error(hdr, -EIO, argp->offset);
>> > >> > -               return;
>> > >> > -       }
>> > >> >
>> > >> >         /* For non rpc-based layout drivers, retry-through-MDS */
>> > >> >         if (!task->tk_ops) {
>> > >> > --
>> > >> > 1.7.1
>> > >> >
>> > >>
>> >
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html

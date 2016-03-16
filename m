Return-Path: <bfields@fieldses.org>
Date: Wed, 16 Mar 2016 13:18:57 -0400
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Benjamin Coddington <bcodding@redhat.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: Retry a zero-length short read
Message-ID: <20160316171857.GA12992@fieldses.org>
References: <79adfc63f33887475f6a0f0eeaacd8b52b2ed12c.1458119750.git.bcodding@redhat.com>
 <CAHQdGtS4pViRyWc+K+CLhmGrt1ar5PRcMpURap2_x2B5QpU2Fw@mail.gmail.com>
 <alpine.OSX.2.19.9992.1603161016560.11199@planck>
 <CAHQdGtThhkdmiYUgbWq1Jz00K8CKtOsgfxJUADhHXe5d3ygrSQ@mail.gmail.com>
 <alpine.OSX.2.19.9992.1603161050370.11199@planck>
 <alpine.OSX.2.19.9992.1603161112440.11199@planck>
 <CAHQdGtTMOjr8SMKOpM2tg0meAAgfLjgbMb5KjGDRoxt7LnEADw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtTMOjr8SMKOpM2tg0meAAgfLjgbMb5KjGDRoxt7LnEADw@mail.gmail.com>
From: bfields@fieldses.org (J. Bruce Fields)
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 16, 2016 at 12:22:22PM -0400, Trond Myklebust wrote:
> On Wed, Mar 16, 2016 at 11:20 AM, Benjamin Coddington
> <bcodding@redhat.com> wrote:
> > On Wed, 16 Mar 2016, Benjamin Coddington wrote:
> >
> >> On Wed, 16 Mar 2016, Trond Myklebust wrote:
> >>
> >> > On Wed, Mar 16, 2016 at 10:22 AM, Benjamin Coddington
> >> > <bcodding@redhat.com> wrote:
> >> > > On Wed, 16 Mar 2016, Trond Myklebust wrote:
> >> > >
> >> > >> On Wed, Mar 16, 2016 at 5:17 AM, Benjamin Coddington
> >> > >> <bcodding@redhat.com> wrote:
> >> > >> >
> >> > >> > A zero-length short read without eof should be retried rather than sending
> >> > >> > an error to the application.
> >> > >>
> >> > >>
> >> > >> In what situation would returning a 0 length read not be a bug? If the
> >> > >> server intended that we back off and retry, it has the alternative of
> >> > >> sending a JUKEBOX/DELAY error.
> >> > >
> >> > > If the server completes a local read but then another writer comes in and
> >> > > appends to the file before the server checks if it needs to set EOF, then
> >> > > the response might be 0 length without EOF set.
> >> >
> >> > Why isn't that EOF check done atomically with the read itself? This
> >> > still sounds like a server bug to me.
> >>
> >> I don't know -- I would guess because doing that atomically is harder than
> >> not, and I don't know where the RFCs say that a zero length response without
> >> eof is to be treated as an error or condition to be avoided.
> >>
> >> I'll look into that, and respond here.
> >
> > Indeed, it seems that it is more convenient for the linux server to send a
> > zero-length response without eof when the file grows.  It would probably be
> > more helpful if the server handled that case, but I think that 7530 states
> > that it doesn't have to handle that case.
> 
> Here is what RFC5661 and RFC7530 say.
> 
>    If the READ ended at the end-of-file (formally, in a correctly formed
>    READ request, if offset + count is equal to the size of the file), or
>    the READ request extends beyond the size of the file (if offset +
>    count is greater than the size of the file), eof is returned as TRUE;
>    otherwise, it is FALSE.  A successful READ of an empty file will
>    always return eof as TRUE.
> 
> Here is what RFC1813 says:
> 
>       eof
>          If the read ended at the end-of-file (formally, in a
>          correctly formed READ request, if READ3args.offset plus
>          READ3resok.count is equal to the size of the file), eof
>          is returned as TRUE; otherwise it is FALSE. A
>          successful READ of an empty file will always return eof
>          as TRUE.
> 
> Where does it say that the eof determination is allowed to be
> non-atomic? Unlike structures such as change_info4, there isn't an
> "atomic" flag to allow the server to communicate to the client that it
> cannot rely on the eof flag. Since the determination is part of the
> same READ operation, you can't point to the "COMPOUNDS are not atomic"
> either.

I wonder why READ has eof at all, instead of adopting read()'s
convention that 0 means eof?

In any case, our server should be able to count on that convention
internally, so if getting a real "eof" out of the filesystem looks
daunting, why not for now just check for that case in
nfsd4_encode_readv()?:


-	eof = (read->rd_offset + maxcount >=
+	eof = (maxcount == 0) || (read->rd_offset + maxcount >=
 	       d_inode(read->rd_fhp->fh_dentry)->i_size);
 

(Actually, I'm not sure that's completely right: if 0-length read
requests are legal then we need to exclude that case.)

--b.

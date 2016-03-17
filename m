Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38135 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030487AbcCQNeH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Mar 2016 09:34:07 -0400
Date: Thu, 17 Mar 2016 09:34:03 -0400 (EDT)
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
cc: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: Retry a zero-length short read
In-Reply-To: <CAHQdGtSCVAyg4qJkGTwE4euWB3oXqmNFaYA54fjvwZjJWwZp1Q@mail.gmail.com>
Message-ID: <alpine.OSX.2.19.9992.1603170929390.11199@planck>
References: <CAHQdGtS4pViRyWc+K+CLhmGrt1ar5PRcMpURap2_x2B5QpU2Fw@mail.gmail.com> <CAHQdGtTMOjr8SMKOpM2tg0meAAgfLjgbMb5KjGDRoxt7LnEADw@mail.gmail.com> <20160316171857.GA12992@fieldses.org> <alpine.OSX.2.19.9992.1603161333260.11199@planck>
 <20160316191503.GB12992@fieldses.org> <alpine.OSX.2.19.9992.1603161532220.11199@planck> <20160316195644.GD12992@fieldses.org> <CAHQdGtTOqtZEFmatX9eMZSTjZ_goV_c4tv+gn7Rbs4A-YzfdHg@mail.gmail.com> <1264858678.4276945.1458180186182.JavaMail.zimbra@desy.de>
 <alpine.OSX.2.19.9992.1603170551530.11199@planck> <CAHQdGtSCVAyg4qJkGTwE4euWB3oXqmNFaYA54fjvwZjJWwZp1Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 17 Mar 2016, Trond Myklebust wrote:

> On Thu, Mar 17, 2016 at 6:11 AM, Benjamin Coddington
> <bcodding@redhat.com> wrote:
> > On Thu, 17 Mar 2016, Mkrtchyan, Tigran wrote:
> >> I agree with Trond, that returning zero bytes without setting eof
> >> with a high probability a server side issue. We had that situation
> >> with dCache server, where eof flag was set only if you read beyond
> >> file size, e.q. READ with count=0 at the offset=file size, we returned
> >> zero bytes with no eof set. The pynfs test, actually, do retry such
> >> request and there was an infinite loop.
> >
> > But that isn't a short read.. if the request is with count=0 and the
> > response is 0 without eof, there shouldn't be a retry, and the current
> > client won't retry in that case, nor fail with EIO.
> >
> >> I think, if we (you) add retry on zero byte short-reads
> >> without eof we may have applications/client hangs in case of
> >> misbehaving servers. But failing with EIO is not the best
> >> option. May be it makes sense to query file size in such
> >> situations? As this is a rare corner case, performance
> >> penalty will by negligible.
> >
> > I do see now that the resistance to this change is because it seems
> > important to ensure that we make forward progress.  This change would lose
> > that guarantee for a server that gets "stuck".  And to Trond's point: if the
> > zero-length short read really was due to eof at read time, then eof should
> > have been set.
> >
> > It seems tricky for the linux server to determine when to set eof.  The best
> > way might be to adopt the convention that a local short read means we should
> > set eof and accept the small penalty that a read that completes fully (not
> > short) up to the end of the file will require another read to detect eof.
> > That should be a fairly rare case except where file sizes end up being
> > multiples of rsize.
>
> It should be trivial for the linux server to determine when eof is to
> be set, because it is running in a POSIX environment. As I pointed out
> earlier, the POSIX spec says that all reads to a regular file that
> return less than the number of requested bytes are hitting eof.

I agree.  I meant to say it seems tricky to do it they way we are doing it
now: by checking i_size afterward.  So, thanks for pointing out how specific
POSIX is about this.  I'll send a patch for the server.

> >
> > Ben
> >
> >>
> >> Tigran.
> >>
> >> ----- Original Message -----
> >> > From: "Trond Myklebust" <trond.myklebust@primarydata.com>
> >> > To: "J. Bruce Fields" <bfields@fieldses.org>
> >> > Cc: "Benjamin Coddington" <bcodding@redhat.com>, "Anna Schumaker" <anna.schumaker@netapp.com>, "Linux NFS Mailing List"
> >> > <linux-nfs@vger.kernel.org>
> >> > Sent: Wednesday, March 16, 2016 9:02:49 PM
> >> > Subject: Re: [PATCH] NFS: Retry a zero-length short read
> >>
> >> > On Wed, Mar 16, 2016 at 3:56 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> >> >> On Wed, Mar 16, 2016 at 03:46:28PM -0400, Benjamin Coddington wrote:
> >> >>> So, sounds like fixing this is a good idea on the server. I hope Trond will
> >> >>> let us know if he still feels that the client ought not to be changed since
> >> >>> it seems an easy enough fix to avoid a similar problem on another server.
> >> >>> Perhaps there's a downside I'm not seeing on the client.
> >> >>
> >> >> My worry would just be ensuring forward progress--if the client gets
> >> >> some data back, then at least the next read can start at a later
> >> >> offset....  With zero reads, we can set a maximum number of retries, I
> >> >> guess, but that makes it little messy.
> >> >>
> >> >>> Or maybe the
> >> >>> convention of read() returning 0 meaning eof is global enough to cause it to
> >> >>> be acceptible behavior -- we really should treat a zero-length read response
> >> >>> without eof as an error.  My lack of experience is showing..  :)
> >> >>
> >> >> Eh, I think it's legitimately more confusing than it should be.
> >> >>
> >> >
> >> > POSIX is very specific about the cases where you are allowed to return
> >> > a short read:
> >> >
> >> > See http://pubs.opengroup.org/onlinepubs/9699919799/functions/read.html
> >> >
> >> > "The value returned may be less than nbyte if the number of bytes left
> >> > in the file is less than nbyte, if the read() request was interrupted
> >> > by a signal, or if the file is a pipe or FIFO or special file and has
> >> > fewer than nbyte bytes immediately available for reading. For example,
> >> > a read() from a file associated with a terminal may return one typed
> >> > line of data."
> >> >
> >> > So I'm guessing most POSIX based server implementations should have no
> >> > trouble working out exactly when to set the eof flag. However the
> >> > client has no clue as to what OS your server is based on, which is
> >> > presumably the main reason why NFS has an eof flag in the first place.
> >> > --
> >> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> >> > the body of a message to majordomo@vger.kernel.org
> >> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >>
>

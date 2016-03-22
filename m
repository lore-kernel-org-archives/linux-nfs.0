Return-Path: <bfields@fieldses.org>
Date: Tue, 22 Mar 2016 17:04:11 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Benjamin Coddington <bcodding@redhat.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: Retry a zero-length short read
Message-ID: <20160322210411.GI4083@fieldses.org>
References: <CAHQdGtThhkdmiYUgbWq1Jz00K8CKtOsgfxJUADhHXe5d3ygrSQ@mail.gmail.com>
 <alpine.OSX.2.19.9992.1603161050370.11199@planck>
 <alpine.OSX.2.19.9992.1603161112440.11199@planck>
 <CAHQdGtTMOjr8SMKOpM2tg0meAAgfLjgbMb5KjGDRoxt7LnEADw@mail.gmail.com>
 <20160316171857.GA12992@fieldses.org>
 <alpine.OSX.2.19.9992.1603161333260.11199@planck>
 <20160316191503.GB12992@fieldses.org>
 <alpine.OSX.2.19.9992.1603161532220.11199@planck>
 <20160316195644.GD12992@fieldses.org>
 <CAHQdGtTOqtZEFmatX9eMZSTjZ_goV_c4tv+gn7Rbs4A-YzfdHg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtTOqtZEFmatX9eMZSTjZ_goV_c4tv+gn7Rbs4A-YzfdHg@mail.gmail.com>
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 16, 2016 at 04:02:49PM -0400, Trond Myklebust wrote:
> On Wed, Mar 16, 2016 at 3:56 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > On Wed, Mar 16, 2016 at 03:46:28PM -0400, Benjamin Coddington wrote:
> >> So, sounds like fixing this is a good idea on the server. I hope Trond will
> >> let us know if he still feels that the client ought not to be changed since
> >> it seems an easy enough fix to avoid a similar problem on another server.
> >> Perhaps there's a downside I'm not seeing on the client.
> >
> > My worry would just be ensuring forward progress--if the client gets
> > some data back, then at least the next read can start at a later
> > offset....  With zero reads, we can set a maximum number of retries, I
> > guess, but that makes it little messy.
> >
> >> Or maybe the
> >> convention of read() returning 0 meaning eof is global enough to cause it to
> >> be acceptible behavior -- we really should treat a zero-length read response
> >> without eof as an error.  My lack of experience is showing..  :)
> >
> > Eh, I think it's legitimately more confusing than it should be.
> >
> 
> POSIX is very specific about the cases where you are allowed to return
> a short read:
> 
> See http://pubs.opengroup.org/onlinepubs/9699919799/functions/read.html
> 
> "The value returned may be less than nbyte if the number of bytes left
> in the file is less than nbyte, if the read() request was interrupted
> by a signal, or if the file is a pipe or FIFO or special file and has
> fewer than nbyte bytes immediately available for reading. For example,
> a read() from a file associated with a terminal may return one typed
> line of data."

It bothers me a bit that that's "if" and not "if and only if", but maybe
that's the posix style.  The linux man pages are even looser ("this may
happen for example because..." and then the above reasons).

--b.

> 
> So I'm guessing most POSIX based server implementations should have no
> trouble working out exactly when to set the eof flag. However the
> client has no clue as to what OS your server is based on, which is
> presumably the main reason why NFS has an eof flag in the first place.

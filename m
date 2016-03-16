Return-Path: <bfields@fieldses.org>
Date: Wed, 16 Mar 2016 15:56:44 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: Retry a zero-length short read
Message-ID: <20160316195644.GD12992@fieldses.org>
References: <CAHQdGtS4pViRyWc+K+CLhmGrt1ar5PRcMpURap2_x2B5QpU2Fw@mail.gmail.com>
 <alpine.OSX.2.19.9992.1603161016560.11199@planck>
 <CAHQdGtThhkdmiYUgbWq1Jz00K8CKtOsgfxJUADhHXe5d3ygrSQ@mail.gmail.com>
 <alpine.OSX.2.19.9992.1603161050370.11199@planck>
 <alpine.OSX.2.19.9992.1603161112440.11199@planck>
 <CAHQdGtTMOjr8SMKOpM2tg0meAAgfLjgbMb5KjGDRoxt7LnEADw@mail.gmail.com>
 <20160316171857.GA12992@fieldses.org>
 <alpine.OSX.2.19.9992.1603161333260.11199@planck>
 <20160316191503.GB12992@fieldses.org>
 <alpine.OSX.2.19.9992.1603161532220.11199@planck>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <alpine.OSX.2.19.9992.1603161532220.11199@planck>
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 16, 2016 at 03:46:28PM -0400, Benjamin Coddington wrote:
> So, sounds like fixing this is a good idea on the server. I hope Trond will
> let us know if he still feels that the client ought not to be changed since
> it seems an easy enough fix to avoid a similar problem on another server.
> Perhaps there's a downside I'm not seeing on the client.

My worry would just be ensuring forward progress--if the client gets
some data back, then at least the next read can start at a later
offset....  With zero reads, we can set a maximum number of retries, I
guess, but that makes it little messy.

> Or maybe the
> convention of read() returning 0 meaning eof is global enough to cause it to
> be acceptible behavior -- we really should treat a zero-length read response
> without eof as an error.  My lack of experience is showing..  :)

Eh, I think it's legitimately more confusing than it should be.

--b.

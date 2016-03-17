Return-Path: <tigran.mkrtchyan@desy.de>
Date: Thu, 17 Mar 2016 03:03:06 +0100 (CET)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Benjamin Coddington <bcodding@redhat.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-ID: <1264858678.4276945.1458180186182.JavaMail.zimbra@desy.de>
In-Reply-To: <CAHQdGtTOqtZEFmatX9eMZSTjZ_goV_c4tv+gn7Rbs4A-YzfdHg@mail.gmail.com>
References: <CAHQdGtS4pViRyWc+K+CLhmGrt1ar5PRcMpURap2_x2B5QpU2Fw@mail.gmail.com> <CAHQdGtTMOjr8SMKOpM2tg0meAAgfLjgbMb5KjGDRoxt7LnEADw@mail.gmail.com> <20160316171857.GA12992@fieldses.org> <alpine.OSX.2.19.9992.1603161333260.11199@planck> <20160316191503.GB12992@fieldses.org> <alpine.OSX.2.19.9992.1603161532220.11199@planck> <20160316195644.GD12992@fieldses.org> <CAHQdGtTOqtZEFmatX9eMZSTjZ_goV_c4tv+gn7Rbs4A-YzfdHg@mail.gmail.com>
Subject: Re: [PATCH] NFS: Retry a zero-length short read
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
List-ID: <linux-nfs.vger.kernel.org>


I agree with Trond, that returning zero bytes without setting eof
with a high probability a server side issue. We had that situation
with dCache server, where eof flag was set only if you read beyond
file size, e.q. READ with count=0 at the offset=file size, we returned
zero bytes with no eof set. The pynfs test, actually, do retry such
request and there was an infinite loop.

I think, if we (you) add retry on zero byte short-reads
without eof we may have applications/client hangs in case of
misbehaving servers. But failing with EIO is not the best
option. May be it makes sense to query file size in such
situations? As this is a rare corner case, performance
penalty will by negligible.

Tigran. 

----- Original Message -----
> From: "Trond Myklebust" <trond.myklebust@primarydata.com>
> To: "J. Bruce Fields" <bfields@fieldses.org>
> Cc: "Benjamin Coddington" <bcodding@redhat.com>, "Anna Schumaker" <anna.schumaker@netapp.com>, "Linux NFS Mailing List"
> <linux-nfs@vger.kernel.org>
> Sent: Wednesday, March 16, 2016 9:02:49 PM
> Subject: Re: [PATCH] NFS: Retry a zero-length short read

> On Wed, Mar 16, 2016 at 3:56 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
>> On Wed, Mar 16, 2016 at 03:46:28PM -0400, Benjamin Coddington wrote:
>>> So, sounds like fixing this is a good idea on the server. I hope Trond will
>>> let us know if he still feels that the client ought not to be changed since
>>> it seems an easy enough fix to avoid a similar problem on another server.
>>> Perhaps there's a downside I'm not seeing on the client.
>>
>> My worry would just be ensuring forward progress--if the client gets
>> some data back, then at least the next read can start at a later
>> offset....  With zero reads, we can set a maximum number of retries, I
>> guess, but that makes it little messy.
>>
>>> Or maybe the
>>> convention of read() returning 0 meaning eof is global enough to cause it to
>>> be acceptible behavior -- we really should treat a zero-length read response
>>> without eof as an error.  My lack of experience is showing..  :)
>>
>> Eh, I think it's legitimately more confusing than it should be.
>>
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
> 
> So I'm guessing most POSIX based server implementations should have no
> trouble working out exactly when to set the eof flag. However the
> client has no clue as to what OS your server is based on, which is
> presumably the main reason why NFS has an eof flag in the first place.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

From: Juan Gomez <juang@us.ibm.com>
Subject: Re: [NFS] Re: Non-blocking lock requests during the grace period
Date: Tue, 19 Nov 2002 10:06:11 -0800
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <OFB5AB2A91.F36007C8-ON87256C76.00632179@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: kupfer@athyra.eng.sun.com, linux-kernel@vger.kernel.org,
	nfs@lists.sourceforge.net, trond.myklebust@fys.uio.no
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: mike.kupfer@sun.com
List-ID: <nfs.lists.sourceforge.net>





Mike,

I agree with the F_GETLK part, as I pointed out to Trond earlier. However,
I feel it is odd to block a client for about one minutre when it issues
"non-blocking" lock requests. I have seen that Solaris code does so but
still feels odd and it may conflict with what most programmers expect,
though I see your point, perhaps if this was well documented in man pages
there would not be a problem. In Linux this is not the case.


Juan





|---------+---------------------------->
|         |           mike.kupfer@sun.c|
|         |           om               |
|         |           Sent by:         |
|         |           kupfer@athyra.eng|
|         |           .sun.com         |
|         |                            |
|         |                            |
|         |           11/18/02 05:04 PM|
|         |                            |
|---------+---------------------------->
  >-------------------------------------------------------------------------------------------------------------------------|
  |                                                                                                                         |
  |       To:       trond.myklebust@fys.uio.no                                                                              |
  |       cc:       Juan Gomez/Almaden/IBM@IBMUS, linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net                   |
  |       Subject:  Re: [NFS] Re: Non-blocking lock requests during the grace period                                        |
  |                                                                                                                         |
  |                                                                                                                         |
  >-------------------------------------------------------------------------------------------------------------------------|



>>>>> "Trond" == Trond Myklebust <trond.myklebust@fys.uio.no> writes:

>>>>> " " == Juan Gomez <juang@us.ibm.com> writes:

    >> (note that F_GETLK man page does not provide EAGAIN as a
    >> possible error code).

F_GETLK indicates a conflict by changing the arg struct to show the
conflicting lock.

As for the original topic, I would hesitate before changing the client
locking code to return EAGAIN just because the server is in its grace
period.  The "blocking" or "non-blocking" behavior is tied to what
happens when there is already a lock that conflicts with the requested
one.  When the server is in the grace period, it's unknown as to
whether there is already a lock that conflicts with the requested
one.

Mike Kupfer                                            mike.kupfer@sun.com
Solaris File Sharing                                   Speaking for myself,
not for Sun.

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtprelay0003.hostedemail.com ([216.40.44.3]:34266 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752296AbcGAXOi convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Jul 2016 19:14:38 -0400
Date: Fri, 1 Jul 2016 19:14:07 -0400
From: Steven Rostedt <rostedt@goodmis.org>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: LKML <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "Jeff Layton" <jlayton@poochiereds.net>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Schumaker Anna <anna.schumaker@netapp.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Fields Bruce <bfields@fieldses.org>,
        "Torvalds Linus" <torvalds@linux-foundation.org>
Subject: Re: Revert: SUNRPC: xs_sock_mark_closed() does not need to trigger
 socket autoclose
Message-ID: <20160701191407.795361d5@gandalf.local.home>
In-Reply-To: <0A51DE9E-81B2-474A-BA07-55C3BE19629A@primarydata.com>
References: <20160701172401.3ba89015@gandalf.local.home>
	<0A51DE9E-81B2-474A-BA07-55C3BE19629A@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 1 Jul 2016 22:34:02 +0000
Trond Myklebust <trondmy@primarydata.com> wrote:

> > On Jul 1, 2016, at 17:24, Steven Rostedt <rostedt@goodmis.org> wrote:
> > 
> > A while back, rkhunter reported a "hidden port" on my main server,
> > making me nervous that I had been hacked. Doing lots of debugging, I
> > found that it was happening from xprt code in NFS. I found a way to
> > trigger the bug, which happened because my wife's machine was NFS
> > mounting a directory of my main server. She does this to upload her
> > photos quickly to gallery2.
> > 
> >  "Warning: Hidden ports found:
> >         Port number: TCP:871"
> > 
> > A hidden port is one that has no socket connected to it. That is, it's
> > a dead resource. Nothing can ever use that port. It's not something
> > that is "reserved", it's just a leaked bit of info. rkhunter treats
> > this as a possible root kit attack.  

[ missed this part when replying last time ]
> 
> No, it’s not leaked at all; it is still being tracked by the RPC layer.

How so? I watched on wireshark and the port is closed (FIN/ACK are
sent, and I watch it go in "netstat -tapn" from ESTABLISHED to
TIME_WAIT to nothing at all), and then it is never reused. I kicked off
lots of copies to and from that mounted directory, and that port never
shows up.

> 
> Furthermore, you haven’t unmounted the NFS partition, so it is a port
> that can and SHOULD, according to the NFSv3 rules be reused by the
> same NFS client when it reconnects. 

It uses another port. Maybe I missed saying that. But there's two ports
that show up.

Not to mention, when I unmount that port still exists as unhidden. It's
not till I remount it that the port goes away until it goes into it
times out again.

> The server attaches a duplicate
> reply cache to the source IP address and port number and expects RPC
> calls that were lost by the server to be replayed through the same IP
> address and port number.
>

Is this what is expected?

[ from Wife's machine ]

 # mount /upload

[ from my server ]

 # netstat -tapn | grep '192.168.23.22'
tcp        0      0 192.168.23.9:931        192.168.23.22:42546     ESTABLISHED -                   
tcp        0      0 192.168.23.9:2049       192.168.23.22:879       ESTABLISHED -     


# while :; do if ! netstat -tapn |grep :931; then break; fi; sleep 1; done; netstat -tapn | grep '192.168.23.22'
tcp        0      0 192.168.23.9:931        192.168.23.22:42546     ESTABLISHED -                   
tcp        0      0 192.168.23.9:931        192.168.23.22:42546     ESTABLISHED -                   
tcp        0      0 192.168.23.9:931        192.168.23.22:42546     ESTABLISHED -                   
tcp        0      0 192.168.23.9:931        192.168.23.22:42546     ESTABLISHED -                   
tcp        0      0 192.168.23.9:931        192.168.23.22:42546     ESTABLISHED -         
[...]
tcp        0      0 192.168.23.9:931        192.168.23.22:42546     ESTABLISHED -                   
tcp        0      0 192.168.23.9:931        192.168.23.22:42546     ESTABLISHED -                   
tcp        0      0 192.168.23.9:931        192.168.23.22:42546     ESTABLISHED -                   
tcp        0      0 192.168.23.9:931        192.168.23.22:42546     ESTABLISHED -                   
tcp        0      0 192.168.23.9:931        192.168.23.22:42546     TIME_WAIT   -                   
tcp        0      0 192.168.23.9:931        192.168.23.22:42546     TIME_WAIT   -                   
tcp        0      0 192.168.23.9:931        192.168.23.22:42546     TIME_WAIT   -                   
tcp        0      0 192.168.23.9:931        192.168.23.22:42546     TIME_WAIT   -       
[...]
tcp        0      0 192.168.23.9:931        192.168.23.22:42546     TIME_WAIT   -                   
tcp        0      0 192.168.23.9:931        192.168.23.22:42546     TIME_WAIT   -                   
tcp        0      0 192.168.23.9:931        192.168.23.22:42546     TIME_WAIT   -                   
# netstat -tapn | grep '192.168.23.22'
tcp        0      0 192.168.23.9:2049       192.168.23.22:879       ESTABLISHED -             

At this point port 931 is hidden and never shows up again. All
connection (according to wireshark) goes through port 2049 from this
point on.

I unmount, and the port is still hidden, but if I remount, the port
goes away and another two ports are connect (2049 along with another
one)

[ form Wife's machine ]

 # umount /upload
 # mount /upload

[ from my server ]

# netstat -tapn | grep '192.168.23.22'
tcp        0      0 192.168.23.9:2049       192.168.23.22:859       ESTABLISHED -                   
tcp        0      0 192.168.23.9:975        192.168.23.22:39281     ESTABLISHED -         

Is this expected?

-- Steve

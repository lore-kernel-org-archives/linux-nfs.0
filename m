From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: more nfsv4 lockups w/ nexenta
Date: Fri, 19 Dec 2008 13:19:46 -0500
Message-ID: <1229710786.7789.138.camel@heimdal.trondhjem.org>
References: <9ef864c50812110940o7ab17a2dvc83ac7653ad6dd21@mail.gmail.com>
	 <1229018528.6463.23.camel@heimdal.trondhjem.org>
	 <9ef864c50812111330v1c9dc200s49dacb5504bbfeca@mail.gmail.com>
	 <9ef864c50812190834p7a63d572s3bd99f964254cc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Thomas Garner <thomas536@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:47519 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751707AbYLSSTw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Dec 2008 13:19:52 -0500
In-Reply-To: <9ef864c50812190834p7a63d572s3bd99f964254cc-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Fri, 2008-12-19 at 11:34 -0500, Thomas Garner wrote:
> This has happened twice since I wrote last.  More debugging from the
> last occurrence:
> 
> http://s120158928.onlinehome.us/messages.7.gz
> http://s120158928.onlinehome.us/nfs_dump_argento7
> 

It's the same thing. The WRITE requests are waiting for NFSv4 state
recovery to finish.

As far as I can see from your tcpdump, there is no NFS network activity
at all, so the recovery thread is obviously hung. What does
'echo t > /proc/sysrq-trigger' tell you that the thread is doing?


> Thomas
> 
> On Thu, Dec 11, 2008 at 4:30 PM, Thomas Garner <thomas536@gmail.com> wrote:
> > The logs in particular are from Nov, but a lockup today prompted the
> > email.  Today's event does not appear to have been due to a reboot or
> > server restart (though I'm not as familiar with the intricacies of
> > Sun's daemon management), as both seem to have been up since Dec 2:
> >
> > [root@filer0 ~]# uptime
> >  4:25pm  up 9 day(s), 12:23,  2 users,  load average: 0.26, 0.26, 0.27
> > [root@filer0 ~]# svcs nfs/server
> > STATE          STIME    FMRI
> > online         Dec_02   svc:/network/nfs/server:default
> >
> > I can provide specific info from today (though I'll need to gather
> > it).  Just let me know.
> >
> > Thomas
> >
> > On Thu, Dec 11, 2008 at 1:02 PM, Trond Myklebust
> > <trond.myklebust@fys.uio.no> wrote:
> >> On Thu, 2008-12-11 at 12:40 -0500, Thomas Garner wrote:
> >>> I have a Debian client running 2.6.27.5 connecting over nfsv4 to a
> >>> Nexenta nfs server running b85 (and even with b103) that is
> >>> experiencing nfs lockups.  The symptoms are basically that nfs stops
> >>> working (usually first noticed as Firefox locking up, but trying to
> >>> log in as a user w/ an nfs mounted home dir hangs as well, as does
> >>> trying to list said nfs mounted home directory).  Trying a `umount -f`
> >>> doesn't usually resolve the issue.  Unfortunately there are no logs
> >>> indicating what the issue is, so I've done some preliminary dumps.
> >>> Here is the relevant portion of the process list:
> >>>
> >>>  3295 ?        S<    24:55  \_ [rpciod/0]
> >>>  3296 ?        S<    46:14  \_ [rpciod/1]
> >>>  3297 ?        S<    55:17  \_ [rpciod/2]
> >>>  3298 ?        S<    19:01  \_ [rpciod/3]
> >>>  3315 ?        R<   185:15  \_ [nfsiod]
> >>>  4464 ?        D<     0:00  \_ [nfsv4-svc]
> >>> 25203 ?        S      0:00  \_ [pdflush]
> >>> 26618 ?        S      0:00  \_ [pdflush]
> >>> 27343 ?        R<   252:35  \_ [192.168.0.10-re]
> >>> 27344 ?        D      0:00  \_ [nfsv4-delegretu]
> >>>
> >>> I've also put up a /var/log/messages with `rpcdebug -m rpc -s all` and
> >>> `rpcdebug -m nfs -s all` turned on:
> >>>
> >>> http://s120158928.onlinehome.us/messages.2.gz
> >>>
> >>> And a `tcpdump -s 0 -w nfs_dump_argento5 -x -i eth0`:
> >>
> >> >From the logs, it looks like it is recovery related. Did the server
> >> reboot just before the hang?
> >>
> >> Cheers
> >>  Trond
> >>
> >>
> >


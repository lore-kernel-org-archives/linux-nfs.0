From: Jens Beyer <jbe@webde.de>
Subject: Re: linux nfs client tcp timeout
Date: Tue, 17 Apr 2007 17:30:43 +0200
Message-ID: <20070417153043.GA9616@pcnocjb.dlan.cinetic.de>
References: <4cf2912c0704060910n33a269f3xcce6967a3abafc92@mail.gmail.com>
	<1175980671.20878.7.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hdpfo-0000d1-EB
	for nfs@lists.sourceforge.net; Tue, 17 Apr 2007 08:32:52 -0700
Received: from mailgate01.web.de ([217.72.192.251])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hdpfn-0006Pa-Bc
	for nfs@lists.sourceforge.net; Tue, 17 Apr 2007 08:32:55 -0700
Received: from web.de by mailgate01.web.de (Postfix) with ESMTP id
	0DF9117B2943 for <nfs@lists.sourceforge.net>;
	Tue, 17 Apr 2007 17:30:43 +0200 (CEST) (R101)
In-Reply-To: <1175980671.20878.7.camel@heimdal.trondhjem.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


Hi,

I am trying to figure this out by myself, so...

On Sat, Apr 07, 2007 at 05:17:51PM -0400, Trond Myklebust wrote:
> On Fri, 2007-04-06 at 21:40 +0530, Venkatesh KS wrote:
> > Hi,
> > =

> > I lost trace of a machine which was hung for 2 hours. The only
> > culprits I can see are nfs write requests.
> > The mount is for tcp, soft, retrans=3D4. Unfortunately I couldnt gather
> > much information.
> > =

...
> > =

> > When I ran tests against a dead server, I saw timeouts of about 3
> > minutes consistently.
> > Only the first request took about 18mins to timeout.
> > =

> > So what is the timeout characteristics for tcp in linux nfs client and
> > what parameters =

> > can influence it?
>
> man 5 nfs. You'll find a description of the 'timeo' and 'retrans'
> options.
>
 =

Looking at my manpage it tells me:

 timeo=3Dn        The  value  in  tenths  of  a second before sending the f=
irst
                retransmission after an RPC timeout.  The default value is =
 7
                tenths  of a second.  After the first timeout, the timeout =
is
                doubled after each successive timeout until a maximum timeo=
ut
                of  60  seconds is reached or the enough retransmissions ha=
ve
                occured to cause a major timeout.
                (Removed text related to 'hard' mounts)
                The  maximum  timeout is always 60 seconds.
                ...

 retrans=3Dn      The number of minor timeouts and  retransmissions  that  =
must
                occur  before a major timeout occurs.  The default is 3 tim=
e=AD
                outs.  When a major timeout occurs,  the  file  operation  =
is
                either  aborted  or  a  "server  not  responding"  message =
is
                printed on the console.

Thus in the mentioned case (retrans=3D4) I have to expect 4 minor timeouts
based on 'timeo=3D7 (default)' values. If I get an RPC timeout (first minor
timeout) retransmission starts after .7 s, again an RPC timeout (2nd minor
timeout) results in retransmission after 1.4 s and so on.

This would lead to an major timeout after 4 * RPC-timeout + 10.5 s, for
retrans=3D4.  (I thought the retrans and timeo values are those rpc-timeouts
but I am unsure for now).

(Btw: it seems that the timeo is in units of seconds - at least on my
machine)

What I do not understand is how timeouts are coupled for one mount and
different progs accessing this (failed) nfs-mount:
I start 2 progs with an open() with a time shift of 10 s and they both
fail at the same time after a time out of (x) and (x - 10 s). Anyone can
explain this ?

Doing consecutive open() with one program on a failed mount I get
timeouts (retrans=3D3,timeo=3D1) :
  run | timeout [s]
 -----+------------
   1  |    6
   2  |   12
   3  |   24
   4  |   48
   5  |   60
   6  |    6
   7  |   12
     ...
after a while (??) the timeout stabilizes at 60 s.

If i open() a file (nfs-mount working) waiting a moment while the mount
fails I get after some write() on close() an I/O error after 3 s. This value
seems to change depending how many calls (open, write, close etc) at which
packetsize (writesize <> wsize) where made to the failed mount; after a
while (cache flush ?) calls seems to get near to the above timeout table.

Last mentioned a recovered nfs-mount takes a while to be recognized as
recovered - depending on similar timeout-cascades as above.

I would appreciate it, if someone could explain me the above behaviour to
get a more deterministic view....

Kind regards,
Jens

PS: my tests where made on 2.6.20.2/6


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

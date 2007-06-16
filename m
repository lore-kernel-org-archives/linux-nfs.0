From: mike <mike503@gmail.com>
Subject: Re: Trying to determine why my NFS connection goes away
Date: Fri, 15 Jun 2007 21:28:18 -0700
Message-ID: <bd9320b30706152128xecae052u26bf9cca568f6fd7@mail.gmail.com>
References: <bd9320b30706141625l6ceb9c73j22a46cf115ca78cd@mail.gmail.com>
	<1181874951.15174.15.camel@heimdal.trondhjem.org>
	<bd9320b30706142333h539215b4jd3c062c4ed666e8f@mail.gmail.com>
	<1181915360.6135.7.camel@heimdal.trondhjem.org>
	<bd9320b30706151532uaa16444q55b58d5c109b7c21@mail.gmail.com>
	<1181966629.6135.27.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HzPtY-0002Kv-04
	for nfs@lists.sourceforge.net; Fri, 15 Jun 2007 21:28:16 -0700
Received: from py-out-1112.google.com ([64.233.166.183])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HzPtb-0004JU-15
	for nfs@lists.sourceforge.net; Fri, 15 Jun 2007 21:28:19 -0700
Received: by py-out-1112.google.com with SMTP id u77so2180546pyb
	for <nfs@lists.sourceforge.net>; Fri, 15 Jun 2007 21:28:18 -0700 (PDT)
In-Reply-To: <1181966629.6135.27.camel@heimdal.trondhjem.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

[root@web03 ~]# cat /proc/mounts

raid01:/home /local/home nfs
rw,nodev,noatime,vers=3,rsize=16384,wsize=16384,hard,intr,nolock,proto=tcp,timeo=10,retrans=2,sec=sys,addr=raid01
0 0

okay, it did not accept the timeo... do you see any other parameters
in there i should tune at the same time?

on another client, CentOS 2.6.9 kernel this is /proc/mounts:
raid01:/home /home nfs
rw,noatime,v3,rsize=16384,wsize=16384,hard,intr,tcp,lock,addr=raid01 0
0

it does not seem to suffer from this specific issue. i am not sure if
it is running as well as it can, but it definately does not report
this nfs server going away stuff. i am running nhfsstone on it right
now and it is not reporting any nfs disconnections at all.

other than the timeo= being left out (and i guess the default of 600
kicking in) do you see anything else i should do? i am open for any
suggestions to have the most optimized solution i can.

thanks again.
- mike

On 6/15/07, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> On Fri, 2007-06-15 at 15:32 -0700, mike wrote:
> > On 6/15/07, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> > > Then why on earth are you using timeo=10? Use the default timeo=600 and
> > > it will all work.
> > >
> > > Using overly short timeouts on TCP is completely unnecessary: TCP
> > > provides reliable delivery of data. Furthermore, a timeout forces the
> > > client to keep disconnecting and reconnecting, and that is why you are
> > > seeing those messages.
> >
> > I think that was one of the suggestions (I've Googled a lot, tried
> > different things, etc.) when looking at tuning NFS and such.
> >
> > I have now mounted it as such:
> >
> > raid01:/home on /local/home type nfs
> > (rw,nodev,_netdev,noatime,nfsvers=3,tcp,rsize=16384,wsize=16384,hard,intr,nolock,timeo=600,addr=192.168.1.151)
> >
> > I still consistently and easily get the
> >
> > [root@web03 ~]# dmesg -c
> > nfs: server raid01 not responding, still trying
> > nfs: server raid01 OK
> > nfs: server raid01 not responding, still trying
> > nfs: server raid01 OK
> >
> > After only a minute or two of nhfsstone (with default parameters)
> >
> > Any other suggestions? Increasing/decreasing wsize/rsize? Changing
> > hard to soft? I'm willing to try anything.
>
> Did you check that the above parameters are indeed set in /proc/mounts?
>
> Trond
>
>

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

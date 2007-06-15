From: mike <mike503@gmail.com>
Subject: Re: Trying to determine why my NFS connection goes away
Date: Fri, 15 Jun 2007 02:56:57 -0700
Message-ID: <bd9320b30706150256u4301a532ya30c9b563e4640ff@mail.gmail.com>
References: <bd9320b30706141625l6ceb9c73j22a46cf115ca78cd@mail.gmail.com>
	<1181874951.15174.15.camel@heimdal.trondhjem.org>
	<bd9320b30706142333h539215b4jd3c062c4ed666e8f@mail.gmail.com>
	<200706151141.44300.bs@q-leap.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hz8Y5-0007zu-1z
	for nfs@lists.sourceforge.net; Fri, 15 Jun 2007 02:56:57 -0700
Received: from wr-out-0506.google.com ([64.233.184.225])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hz8Y6-00061e-61
	for nfs@lists.sourceforge.net; Fri, 15 Jun 2007 02:57:00 -0700
Received: by wr-out-0506.google.com with SMTP id 76so746583wra
	for <nfs@lists.sourceforge.net>; Fri, 15 Jun 2007 02:56:57 -0700 (PDT)
In-Reply-To: <200706151141.44300.bs@q-leap.de>
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

okay, wow - i guess this is from my nfs4 setup when i didn't have to
explicitly define it.

i am trying to lsof | grep TCP | grep raid01 and UDP and not seeing
anything so maybe i don't know how to trace it the simplest way, but i
will remount it with tcp and see if it happens again.

if it does... i will surely be embarrased :)


On 6/15/07, Bernd Schubert <bs@q-leap.de> wrote:
> On Friday 15 June 2007 08:33:17 mike wrote:
> > no - if you look at the mount parameters i am explicitly stating TCP.
>
> Sure?
>
> On Friday 15 June 2007 01:25:31 mike wrote:
> > THE SPECS:
> >
> > Client mounts server:
> > raid01:/home on /local/home type nfs
> > (rw,noatime,nfsvers=3,rsize=16384,wsize=16384,hard,intr,timeo=10,addr=192.1
> >68.1.151)
> >
>
> I don't see tcp here.
>
>
> Cheers,
> Bernd
>
> -------------------------------------------------------------------------
> This SF.net email is sponsored by DB2 Express
> Download DB2 Express C - the FREE version of DB2 express and take
> control of your XML. No limits. Just data. Click to get it now.
> http://sourceforge.net/powerbar/db2/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

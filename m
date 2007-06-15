From: mike <mike503@gmail.com>
Subject: Re: Trying to determine why my NFS connection goes away
Date: Fri, 15 Jun 2007 15:32:48 -0700
Message-ID: <bd9320b30706151532uaa16444q55b58d5c109b7c21@mail.gmail.com>
References: <bd9320b30706141625l6ceb9c73j22a46cf115ca78cd@mail.gmail.com>
	<1181874951.15174.15.camel@heimdal.trondhjem.org>
	<bd9320b30706142333h539215b4jd3c062c4ed666e8f@mail.gmail.com>
	<1181915360.6135.7.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HzKLV-0002hc-NN
	for nfs@lists.sourceforge.net; Fri, 15 Jun 2007 15:32:45 -0700
Received: from nz-out-0506.google.com ([64.233.162.236])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HzKLY-0007Gr-S0
	for nfs@lists.sourceforge.net; Fri, 15 Jun 2007 15:32:49 -0700
Received: by nz-out-0506.google.com with SMTP id 18so2864938nzp
	for <nfs@lists.sourceforge.net>; Fri, 15 Jun 2007 15:32:48 -0700 (PDT)
In-Reply-To: <1181915360.6135.7.camel@heimdal.trondhjem.org>
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

On 6/15/07, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> Then why on earth are you using timeo=10? Use the default timeo=600 and
> it will all work.
>
> Using overly short timeouts on TCP is completely unnecessary: TCP
> provides reliable delivery of data. Furthermore, a timeout forces the
> client to keep disconnecting and reconnecting, and that is why you are
> seeing those messages.

I think that was one of the suggestions (I've Googled a lot, tried
different things, etc.) when looking at tuning NFS and such.

I have now mounted it as such:

raid01:/home on /local/home type nfs
(rw,nodev,_netdev,noatime,nfsvers=3,tcp,rsize=16384,wsize=16384,hard,intr,nolock,timeo=600,addr=192.168.1.151)

I still consistently and easily get the

[root@web03 ~]# dmesg -c
nfs: server raid01 not responding, still trying
nfs: server raid01 OK
nfs: server raid01 not responding, still trying
nfs: server raid01 OK

After only a minute or two of nhfsstone (with default parameters)

Any other suggestions? Increasing/decreasing wsize/rsize? Changing
hard to soft? I'm willing to try anything.

Thanks.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

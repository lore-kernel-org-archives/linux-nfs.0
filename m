From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Questions about NFS over TCP
Date: 23 Apr 2003 14:25:33 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsznmhtn7m.fsf@charged.uio.no>
References: <3EA66B58.2B1E4A45@moving-picture.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 198JK6-0000oW-00
	for <nfs@lists.sourceforge.net>; Wed, 23 Apr 2003 05:26:02 -0700
To: James Pearson <james-p@moving-picture.com>
In-Reply-To: <3EA66B58.2B1E4A45@moving-picture.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

>>>>> " " == James Pearson <james-p@moving-picture.com> writes:

    >> The disadvantage of using TCP is that it is not a stateless
    >> protocol like UDP. If your server crashes in the middle of a
    >> packet transmission, the client will hang and any shares will
    >> need to be unmounted and remounted.

This is not really true. If the connection is broken, the client
should detect it, and automatically attempt to reconnect. It may be
that there are still bugs (I hope not) but the machinery is already
there.

     > What is the 'best' way to get mount to try an TCP mount first -
     > if that fails, then try a UDP mount - I had a look at the mount
     > source and hacked in something to do this if the options -o
     > tcp,udp are given - my hack is very simple, if the TCP mount
     > fails (for whatever reason), the try a UDP mount - however, I
     > don't know how 'safe' this is ...

It should be fairly safe: after all this is what most NFS clients do
anyway. I've had a patch available for quite some time on
 
  http://www.fys.uio.no/~trondmy/src/util-linux-2.11n.dif.gz

that makes this easy. Just go to the function 'proto_probelist()' and
swap the order of UDP and TCP.

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Christian Robottom Reis <kiko@async.com.br>
Subject: Performance expectations of NFS
Date: Thu, 25 Jan 2007 17:31:21 -0200
Message-ID: <20070125193121.GA7267@anthem.async.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Johan Dahlin <jdahlin@async.com.br>
To: NFS@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
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

Hello there,

    I run a small (10-node) diskless network in our company, and I've
been a user of Linux as server and client in it for many years now.
Most of the time my users are very happy with the system, and it
performs very reliably; however, I do get complaints that the network is
slow, and I always want to advocate that diskless should be as fast
enough as local disks (even though it really isn't!)

So a user today presented me with a real-world benchmark of an operation
that he does regularly. It's basically issueing a copy of a code checkout:

    % cp -r gazpacho gazpacho-new

This is a 33MB tree with 2674 files. Network is a switched 100Mbit/s,
and you can netcat a file over HTTP at about 10MB/s from the server; I
think that suggests the network is fine.

Unscientific average times for variations of this benchmark are as
follows:

  0:05  - Server: locally on RAID-5
  0:06  - Client: copying from NFS mount to tmpfs
  2:31  - Client: Copying from NFS mount to NFS mount
          (i.e., the simple command above)
  3:30  - Client: Copying from NFS mount to NFS mount over an existing
          tree.
  5:08  - Client: Copying from tmpfs to NFS mount
  0:48  - Client: Deleting copy of tree on NFS mount

Now I know that file creation is synchronous, and that because of this,
the NFS copy will /always/ run significantly slower. But I was amazed at
just how much faster reading was than writing, and at how fast reading
actually is -- it's much faster than I expected NFS could be.

I also found it interesting that copying from NFS mount to NFS mount was
faster than copying from local filesystem to NFS mount; I imagine there
is a protocol optimization for that common scenario.

But what I'd really like to know if there is a way of making the
above operation run in significantly less time than it is today, or if
our expectations are just unrealistic given the complexity of network
filesystems. I'd be pretty happy with an operation that ran in, say, 40
seconds -- but 2:30 is a pretty long time. I've tried toying with rsize
and wsize, async and sync, and tcp rmem and wmem proc settings. None of
those changes makes a real difference. So my questions are:

    Are there practical ways of speeding the operation up?

    Would people with better hardware see significantly reduced times?

I appreciate any advice and discussion on the topic. Thanks!
-- 
Christian Robottom Reis | http://async.com.br/~kiko/ | [+55 16] 3376 0125

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

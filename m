From: "Steve Wolfe" <sn@codon.com>
Subject: Re: Question on NFS server timing out
Date: Tue, 24 Jun 2003 17:35:41 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <001301c33aa9$56d01f70$88693fd1@WEASEL>
References: <001101c33a76$77b37f30$88693fd1@WEASEL> <16120.56873.142665.95413@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from codon.com ([209.63.105.132])
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19UxHU-0005c5-00
	for <nfs@lists.sourceforge.net>; Tue, 24 Jun 2003 16:32:56 -0700
To: <nfs@lists.sourceforge.net>
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

> If you are getting I/O errors from cat then you are presumably
> mounting with the "soft" option.  This is almost always wrong.  Use
> hard,intr.

  The reason I used soft was because when the NFS server would have a
hiccup, CGI apps would pile up on all of the web servers, and never exit.
But I guess I'll have to live with that and use hard. : )

> I'm guessing that the high load during the days is a read-mostly load.
> moving the log files in a write-mostly load.  Presumably your nfs
> server isn't coping with writes as fast as you would like.
>
> You are probably using the "sync" export option.  This is normally a
> good thing.  However if you are happy to risk loosing recently written
data if
> the fileserver crashes (which you might be in your situation) you
> could replace "sync" with "async" and get faster writes.

  No 'sync', the options have been:

exec,nodev,nosuid,rw,soft,rsize=8192,wsize=8192,intr

and replaced with:

exec,nodev,nosuid,rw,hard,rsize=8192,wsize=8192,intr

> What filesystem?  How is it configured?
> If you are using ext3, then data=journal will speed up nfs writes.
> If you are using data=journal, how big is the journal and how big are
> the log files that you write?

   It's ext3 with the defaults.  "data=journal" is on my "todo" list.  The
array can write 70 MB/s with ease, so I'm *hoping* that it's not the
bottleneck.

> It doesn't hurt to add a few more threads, though I cannot promise it
> will help.
> If all seven clients are busy they will only get about threads each,
> they can probably make use of more than that.  I would probably try 60
> and see what happens.

  I'll give it a shot.  Thanks again for the tips.

steve



-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

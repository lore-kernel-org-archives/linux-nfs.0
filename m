From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS Performance with sync or async
Date: Sat, 28 May 2005 13:51:59 -0700
Message-ID: <1117313519.10746.20.camel@lade.trondhjem.org>
References: <482A3FA0050D21419C269D13989C611308539BBA@lavender-fe.eng.netapp.com>
	 <20050528125343.GY4944@inxservices.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Dc8I7-0006sU-E7
	for nfs@lists.sourceforge.net; Sat, 28 May 2005 13:52:19 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1Dc8I5-0007Lm-9d
	for nfs@lists.sourceforge.net; Sat, 28 May 2005 13:52:18 -0700
To: George Garvey <tmwg-nfs@inxservices.com>
In-Reply-To: <20050528125343.GY4944@inxservices.com>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

lau den 28.05.2005 Klokka 05:53 (-0700) skreiv George Garvey:
> On Fri, May 27, 2005 at 07:45:12PM -0700, Lever, Charles wrote:
> > to clarify, you are using the "sync" mount option on your NFS clients?
>    Yes.
> > why did you initially decide to use "sync"?
>    Reading urgings from some of the NFS authors ...

Note that there are two "sync" options: one affects the server behaviour
causing it to always make sure that the data reaches the disk if/when
the client requests it (see 'man 5 exports') and the other affects the
client (and is a mount option).

You almost always want to set the "sync" option in /etc/exports (unless
you really don't care about losing data if the server crashes and/or
reboots). Are you sure that the urgings you mentioned above didn't
concern this option?

Conversely, you almost never want to set the sync mount option on the
client. Any application that needs synchronous read/write behaviour and
that doesn't want to use fcntl() or flock() locking will usually want to
be rewritten to use the O_DIRECT mode for uncached file access.

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by Yahoo.
Introducing Yahoo! Search Developer Network - Create apps using Yahoo!
Search APIs Find out how you can build Yahoo! directly into your own
Applications - visit http://developer.yahoo.net/?fr=offad-ysdn-ostg-q22005
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

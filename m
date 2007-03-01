From: "Jesper Juhl" <jesper.juhl@gmail.com>
Subject: Re: nfs_update_inode: inode 309229856 mode changed,
	0100644 to 0040755 - kernel 2.6.13.4
Date: Thu, 1 Mar 2007 10:17:46 +0100
Message-ID: <9a8748490703010117m552221cfs85ddcf5f29de5305@mail.gmail.com>
References: <9a8748490702260531h45a91113o611c272c0fe7b39f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HMhQK-0008M4-GY
	for nfs@lists.sourceforge.net; Thu, 01 Mar 2007 01:18:04 -0800
Received: from wr-out-0506.google.com ([64.233.184.226])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HMhQL-0003jo-9s
	for nfs@lists.sourceforge.net; Thu, 01 Mar 2007 01:18:06 -0800
Received: by wr-out-0506.google.com with SMTP id i30so571796wra
	for <nfs@lists.sourceforge.net>; Thu, 01 Mar 2007 01:18:04 -0800 (PST)
In-Reply-To: <9a8748490702260531h45a91113o611c272c0fe7b39f@mail.gmail.com>
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

On 26/02/07, Jesper Juhl <jesper.juhl@gmail.com> wrote:
> I have a webserver running a rather old 2.6.13.4 kernel that a few
> minutes ago surprised me by logging the following message :
>
>  kernel: nfs_update_inode: inode 309229856 mode changed, 0100644 to 0040755
>
I just got one more of these (well, slightly different, but same basic
issue). This time it was one of my mailservers, also running 2.6.13.4.

  kernel: nfs_update_inode: inode -1073741693 mode changed, 0040700 to 0100644

> The server exporting the filesystem is running 2.6.18.1 (knfsd) -
> nothing is logged on the server...
>
This time it's a different NFS server (still using knfsd), this one is
running kernel 2.6.20. Still nothing logged at the server side.

> So a file changed type and permissions out of the blue.  A few
> questions about that:
>
> Any way I can identify the file (or is it a dir now ;) ?
> Does anyone know if this is a known bug that's been fixed? I couldn't
> find anything via google or git that looked like a fix.
>
These questions still apply :-)

-- 
Jesper Juhl <jesper.juhl@gmail.com>
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please      http://www.expita.com/nomime.html

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: "Jesper Juhl" <jesper.juhl@gmail.com>
Subject: Re: 2.6.17.8 - do_vfs_lock: VFS is out of sync with lock
	manager!
Date: Thu, 17 Aug 2006 11:58:07 +0200
Message-ID: <9a8748490608170258s32df0272r60c8c540e5871485@mail.gmail.com>
References: <9a8748490608080739w2e14e5ceg44a7bf0a3b475704@mail.gmail.com>
	<17636.4462.975774.528003@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GDede-0002IW-FC
	for nfs@lists.sourceforge.net; Thu, 17 Aug 2006 02:58:10 -0700
Received: from nf-out-0910.google.com ([64.233.182.187])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GDedd-0002Au-Mc
	for nfs@lists.sourceforge.net; Thu, 17 Aug 2006 02:58:11 -0700
Received: by nf-out-0910.google.com with SMTP id m19so1023630nfc
	for <nfs@lists.sourceforge.net>; Thu, 17 Aug 2006 02:58:08 -0700 (PDT)
To: "Neil Brown" <neilb@suse.de>
In-Reply-To: <17636.4462.975774.528003@cse.unsw.edu.au>
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

On 17/08/06, Neil Brown <neilb@suse.de> wrote:
> On Tuesday August 8, jesper.juhl@gmail.com wrote:
> > I have some webservers that have recently started reporting the
> > following message in their logs :
> >
> >   do_vfs_lock: VFS is out of sync with lock manager!
>
>
> I can imagine that happening if you mount with '-o nolocks'.
> Then a non-blocking lock could cause that message (I think).
> Can you conform that you aren't using 'nolocks'.
>
Confirmed.

All my webservers (the ones that generate this message) are identical
and this is the filesystems they have and their mount options:

/ is on a local scsi disk, ext3 fs, mounted with (rw)
/boot is on a local scsi disk, ext3 fs, mounted with (rw)
users homedirs (where the DocumentRoots are) are NFS mounted with
mount options (rw,rsize=8192,wsize=8192,hard,intr,addr=xxx.xxx.xxx.xxx)

-- 
Jesper Juhl <jesper.juhl@gmail.com>
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please      http://www.expita.com/nomime.html

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 0 / 1] Move NFS mount code from util-linux to
 nfs-utils - take2
Date: Fri, 16 Jun 2006 13:50:41 +1000
Message-ID: <17554.10897.749701.712542@cse.unsw.edu.au>
References: <448DF279.8090005@redhat.com>
	<17554.9694.465446.422126@cse.unsw.edu.au>
	<44922954.7070101@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fr5MH-00015a-J7
	for nfs@lists.sourceforge.net; Thu, 15 Jun 2006 20:51:00 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Fr5MH-0005oh-91
	for nfs@lists.sourceforge.net; Thu, 15 Jun 2006 20:50:57 -0700
To: Amit Gud <agud@redhat.com>
In-Reply-To: message from Amit Gud on Thursday June 15
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

On Thursday June 15, agud@redhat.com wrote:
> > 
> > Also, it seems really odd that you need
> >    ./configure --without-mount
> > it you want it to compile the mount client.
> > Surely it should be --with-mount!!!
> > What is the reasoning there?
> 
> I went with the GNU Autoconf Manual ;), 
> http://www.gnu.org/software/autoconf/manual/autoconf-2.57/html_mono/autoconf.html#SEC130, 
> which says --with-foo, when external program foo is to be used, and 
> --without-foo otherwise. But I know, it sounds rather odd. I think, I'II 
> change it to --with-mount.
> 

Ahh... I see what you were thinking, and it does seem to make sense in
a way...

I think the '--with-foo' is when you want the package you are using to
make use of some other program.
In this case nfs-utils doesn't have the option of using mount.  It is
the sysadmin who may use mount, or may use nfs-utils/mount.

I think you should make it an enable/disable feature.
Default to --enable-mount, but allow --disable-mount.

NeilBrown


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Scott Mcdermott <smcdermott@questra.com>
Subject: Re: Re: broken umount -f
Date: Wed, 15 Jan 2003 11:32:37 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030115163237.GD30598@questra.com>
References: <6440EA1A6AA1D5118C6900902745938E07D551F9@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ns1.questra.com ([64.132.48.186])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18YqT0-00046v-00
	for <nfs@lists.sourceforge.net>; Wed, 15 Jan 2003 08:32:38 -0800
Received: from questra.com (hades.roc.questra.com [64.132.48.226])
	by ns1.questra.com (Postfix) with SMTP id 8B43EAB5B5
	for <nfs@lists.sourceforge.net>; Wed, 15 Jan 2003 11:32:37 -0500 (EST)
To: nfs@lists.sourceforge.net
In-Reply-To: <6440EA1A6AA1D5118C6900902745938E07D551F9@black.eng.netapp.com>
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

Lever, Charles on Wed 15/01 06:45 -0800:
> what if you try it again with the intr mount option?

I'm sure it *will* work with the `intr' mount option.  But I don't want
my users to be able to corrupt their own data just because I decided to
bounce to server for whatever reason.  Their IO to that filesystem
should hang, uninterruptibly, as is the conventional wisdom (that hard,
nointr is the Right Way), and I agree with.

"pick one or the other" doesn't work because there are situtations where
the filesystem IO will never complete and a umount *has* to be forced or
there is never any recovery option.

> if that doesn't help, enable rpc level debugging and send me the
> kernel log contents.

if you'd like I can still do this, but it probably works fine with intr,
that's not what the problem is.  The problem is having a system that one
cannot even reboot without using "reboot -f" just because the server is
down and the client mounts with hard,intr.


-------------------------------------------------------
This SF.NET email is sponsored by: Take your first step towards giving 
your online business a competitive advantage. Test-drive a Thawte SSL 
certificate - our easy online guide will show you how. Click here to get 
started: http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0027en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

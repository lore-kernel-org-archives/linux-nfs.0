Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2720 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755315Ab1CVIVX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Mar 2011 04:21:23 -0400
Date: Tue, 22 Mar 2011 09:21:23 +0100
From: Karel Zak <kzak@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: Re: mount.nfs libmount support (v3)
Message-ID: <20110322082123.GA30453@nb.net.home>
References: <1300111108-13137-1-git-send-email-kzak@redhat.com> <4D87A12A.60209@RedHat.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4D87A12A.60209@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Mar 21, 2011 at 03:04:10PM -0400, Steve Dickson wrote:
> On 03/14/2011 09:58 AM, Karel Zak wrote:
> > This is the third version of the mount.nfs with libmount support. The code
> > depends on util-linux >= v2.19 (e.g. Fedora 15).
> > 
> > v3:
> >   - call umount_error() on mount(2) error
> > 
> > v2:
> >   - move nfs_umount_do_umnt() to network.c
> >   - use union nfs_sockaddr
> >   - add missing GPL address paragraph
> >   - use abstract function the storing and retrieval mount options
> >   - use "static const" for struct option
> >   - use "strncmp() == 0" everywhere
> > 
> > 
> Looking at unmounting a non-existent fs I get:
> 
> # umount.nfs /mnt/home
> umount.nfs: remote share not in 'host:dir' format
> umount.nfs: /mnt/home: not mounted

 hmm..

> The message is being generated because nfs_umount23() is
> is passed an invalid devname ('/mnt/home' in my case).
> The reason the message was not being generated before
> is because nfs_umount23() was not called when the devname
> did not exist in the mtab.

 right

> I also notice that the libmount code does indeed  know the devname 
> is not in the mtab. The lookup_umount_fs() call fails which is in 
> the mnt_context_prepare_umount() call... But, rightly so, you continue 
> to process the umount. Plus the umount(2) is done during the 
> mnt_context_do_umount() call which ends up generating the correct
> "not mounted" message.
> 
> So my question is, is there some why I can tell, using the libmount
> API, that the fs was not in either /proc/mounts or /etc/mtab?

 That's simple, entries from mtab or /proc have always defined some
 mount options (at least rw/ro). This heuristic is already used in
 umount_main()

      if (!mnt_context_is_lazy(cxt)) {
          if (opts) {
             ....
          } else
              /* strange, no entry in mtab or /proc not mounted */
              nfs_umount23(spec, "tcp,v3");
      }

 If I good understand the 'else nfs_umount23(spec, "tcp,v3")' should be
 removed from the code. If I remove this line, then:

   # umount.nfs /mnt/home
   umount.nfs: /mnt/home: not found


 There is also mnt_fs_is_kernel() to check that the FS description is
 from /proc, maybe I can also add mnt_fs_is_mtab() to the API.

> Basically I do not want to call nfs_umount23() but I do want
> to call mnt_context_do_umount() when the file system is not
> in the mtab, similar to how it worked in the previous code.

 Yep, the "umount.nfs server://foo" should be evaluated and converted
 to the valid FS description by libmount (mnt_context_prepare_umount),
 any other fallback solution is unnecessary.

 It seems we need v4 of the patch... 
 
 Thanks for review!

    Karel


-- 
 Karel Zak  <kzak@redhat.com>
 http://karelzak.blogspot.com

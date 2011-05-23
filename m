Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:33637 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753727Ab1EWOCW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 May 2011 10:02:22 -0400
Date: Mon, 23 May 2011 10:02:19 -0400
To: Jeff Layton <jlayton@redhat.com>
Cc: Sid Moore <learnmost@gmail.com>, linux-nfs@vger.kernel.org
Subject: Re: Report bug: space not released when file deleted.
Message-ID: <20110523140219.GA25334@fieldses.org>
References: <BANLkTikCdr6P-WFBdshPwiBQ5_LK-qobLQ@mail.gmail.com>
 <20110523073027.271cb61f@corrin.poochiereds.net>
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20110523073027.271cb61f@corrin.poochiereds.net>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, May 23, 2011 at 07:30:27AM -0400, Jeff Layton wrote:
> On Mon, 23 May 2011 13:42:41 +0800
> Sid Moore <learnmost@gmail.com> wrote:
> 
> > Hi,
> > 
> > On Linux NFS, I found a file deleted but its space not released in
> > NFSv3. It is on 2.6.32.
> > 
> > The steps for reproducing are listed below.
> > 1) create a ext3 filesystem on a device, mount it to local dir
> > /exports/fs1_ext3/, export /exports/fs1_ext3/ with no_subtree_check to
> > a NFS client. this client mount this exported dir with infinite
> > retrans.
> > 2) on the ext3 fs, create a large regular file  (say: 600MB)
> > 3) on NFS client, starts several processes who reading this file in 2)
> > in parallel
> > 4) during step 3), kill all nfsd threads, umount this ext3 fs; then
> > mount this ext3 to /exports/fs1_ext3; start 8 nfsd threads.
> > 5) after processes finished reading, delete this file. then, I found
> > the space occupied but this file not released.
> > 
> > during step 4), I think an anonymous dentry of this file was created
> > after fh_verify(). in step 5), a named dentry of this file also
> > created. So, there are two dentry on this inode. but when deleting,
> > only the named dentry deleted. only restart this ext3 fs or dcache
> > shrinked, the anonymous dentry will not be released and it referenced
> > the inode of this file. so its space not freed.
> > 
> > is my analysis correct?  anyone has encountered this issue before? or,
> > this issue was fixed by someone? Thanks.
> > 
> 
> You may want to test a more recent kernel on the server before you dig
> in too deeply. I know that Bruce has fixed a number of these sorts of
> problems recently.

Yes, this should be fixed by d891eedbc3b1b0fade8a9ce60cc0eba1cccb59e5,
in 2.6.38.

--b.

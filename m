From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] mount: enable retry for nfs23 to set the correct protocol for mount.
Date: Mon, 21 Jul 2008 12:55:59 +1000
Message-ID: <18563.64191.468427.481673@notabene.brown>
References: <18556.40594.897682.204554@notabene.brown>
	<76bd70e30807150811p56feb02bo6e4a366d5577b398@mail.gmail.com>
	<18559.53893.95829.499988@notabene.brown>
	<76bd70e30807190909n12b9f70an87ccb62198c3a7d@mail.gmail.com>
	<18562.57287.656749.540603@notabene.brown>
	<76bd70e30807201828t70d5b1d0m4c242c5c8864c3bb@mail.gmail.com>
	<18563.63821.501053.402741@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "Chuck Lever" <chucklever@gmail.com>,
	"Steve Dickson" <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:33443 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760141AbYGUC4H (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 20 Jul 2008 22:56:07 -0400
In-Reply-To: message from Neil Brown on Monday July 21
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Monday July 21, neilb@suse.de wrote:
> 
> How about this?

BTW, this and two other patches are in my git.

The first is the sm-notify fix, as modified, and with another fix
since Steve's last post.  There was a "return" which should have been
inside and 'if' but was outside it.

The second causes portmap lookup to use connected UDP ports.

The third is the one I just posted.

BTW Steve, it is a small thing, but when you apply patches to git you
often seem to lose the subject line.  This causes the first line of
the description to be using as the one line summary, which sometimes
looks rather strange.

Thanks,
NeilBrown

The following changes since commit ba8dd9533e647b70d6e46beed3dcd8d8036b02af:
  Neil Brown (1):
        If portmap is not listening on UDP (as apparently happens with

are available in the git repository at:

  git://neil.brown.name/nfs-utils/ for-steved

Neil Brown (3):
      sm-notify: perform DNS lookup in the background.
      Use connected socket when probing portmap with UDP.
      Check nfs options (vers/protocol) before trying mount.

 utils/mount/network.c   |   41 +++++++++++++++++++++++++----------------
 utils/mount/network.h   |    2 +-
 utils/mount/nfsmount.c  |    2 +-
 utils/mount/stropts.c   |   18 +++++++-----------
 utils/statd/sm-notify.c |   39 +++++++++++++++++++++++++--------------
 5 files changed, 59 insertions(+), 43 deletions(-)

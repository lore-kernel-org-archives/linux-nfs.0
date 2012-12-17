Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:18673 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752559Ab2LQPOb convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Dec 2012 10:14:31 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Jeff Layton <jlayton@redhat.com>
CC: Al Viro <viro@ZenIV.linux.org.uk>, Ricky Ng-Adam <rngadam@lophilo.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "neilb@suse.de" <neilb@suse.de>
Subject: Re: WARNING: at linux/fs/inode.c:280 drop_nlink
Date: Mon, 17 Dec 2012 15:14:29 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA91194763C@sacexcmbx05-prd.hq.netapp.com>
References: <CAOAMTYQ_9bPjCtobC9kfUJrgiT8hx7FsMXoi5ZgWo+P1qjDb0g@mail.gmail.com>
	 <20121112095255.5c7babcc@tlielax.poochiereds.net>
	 <20121213063147.44b1cf73@tlielax.poochiereds.net>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA91192A83F@SACEXCMBX04-PRD.hq.netapp.com>
	 <20121213210753.GQ4939@ZenIV.linux.org.uk>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA91192CBB6@SACEXCMBX04-PRD.hq.netapp.com>
	 <20121213220636.4c70ec28@corrin.poochiereds.net>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA91192D34B@SACEXCMBX04-PRD.hq.netapp.com>
	 <20121214075138.7ab828da@tlielax.poochiereds.net>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA91192E5BE@SACEXCMBX04-PRD.hq.netapp.com>
	 <20121217080802.5168393a@tlielax.poochiereds.net>
In-Reply-To: <20121217080802.5168393a@tlielax.poochiereds.net>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2012-12-17 at 08:08 -0500, Jeff Layton wrote:
+AD4- On Fri, 14 Dec 2012 18:22:27 +-0000
+AD4- +ACI-Myklebust, Trond+ACI- +ADw-Trond.Myklebust+AEA-netapp.com+AD4- wrote:
+AD4- 
+AD4- +AD4- On Fri, 2012-12-14 at 07:51 -0500, Jeff Layton wrote:
+AD4- +AD4- +AD4- OTOH, there is at least a minor problem here with letting i+AF8-nlink
+AD4- +AD4- +AD4- underflow. When we finally get around to iput+AF8-final, generic+AF8-drop+AF8-inode
+AD4- +AD4- +AD4- is going to return false and we're going to end up with the inode
+AD4- +AD4- +AD4- lingering in the cache longer than it really should. Presumably memory
+AD4- +AD4- +AD4- pressure will eventually push it out, but it would be better not to
+AD4- +AD4- +AD4- have to wait for that.
+AD4- +AD4- 
+AD4- +AD4- As I said, the whole nlink test thing is a heuristic on NFS. Just
+AD4- +AD4- because we think we've successfully sent a REMOVE to the server, it
+AD4- +AD4- doesn't mean that file has actually been deleted. REMOVE refers to the
+AD4- +AD4- file by name, so there is plenty of opportunity for the server to play
+AD4- +AD4- tricks on us. I'm assuming that is what is happening in your Fedora bug
+AD4- +AD4- reports.
+AD4- +AD4- 
+AD4- +AD4- As far as we're concerned, the only reliable indicator that a file has
+AD4- +AD4- been deleted is when the server starts replying ESTALE to that
+AD4- +AD4- filehandle.
+AD4- +AD4- 
+AD4- +AD4- +AD4- I'll also note that we call nfs+AF8-drop+AF8-nlink to decrement i+AF8-nlink
+AD4- +AD4- +AD4- everywhere else aside from this call site. What makes nfs+AF8-dentry+AF8-iput
+AD4- +AD4- +AD4- special in this regard?
+AD4- +AD4- 
+AD4- +AD4- nfs+AF8-dentry+AF8-iput() is not special, but the test in nfs+AF8-drop+AF8-nlink() is.
+AD4- +AD4- If we're not able to track inode-+AD4-i+AF8-nlink, then why is forcing an inode
+AD4- +AD4- eviction more correct than not doing so?
+AD4- +AD4- 
+AD4- 
+AD4- The patchset you sent after the above seems basically correct to me,
+AD4- but since you asked...
+AD4- 
+AD4- It's hard to generalize on server behavior, but if a server sends us an
+AD4- attributes with i+AF8-nlink +AD0APQ- 0, it seems unlikely to go positive again.
+AD4- For most servers, that means that the inode is now unreachable via
+AD4- LOOKUP. Therefore, once d+AF8-iput is called we won't have a way to get to
+AD4- the inode again. Forcing it out of the cache seems like the right
+AD4- thing to do in that case.

We don't know what the server's idea of inode-+AD4-i+AF8-nlink is. The REMOVE
operation doesn't return any information about the target inode, so we
were just manipulating our cached values.

+AD4- A negative i+AF8-nlink OTOH makes no sense at all. If our actions are going
+AD4- to make that happen then we ought to take steps to prevent it.

We now only manipulate the cached value if we want the VFS to forget the
inode. Otherwise, we just mark the inode attributes for revalidation.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com

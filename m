Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zeniv.linux.org.uk ([195.92.253.2]:42416 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753286Ab1LACMy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Nov 2011 21:12:54 -0500
Date: Thu, 1 Dec 2011 02:12:51 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: NeilBrown <neilb@suse.de>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS <linux-nfs@vger.kernel.org>
Subject: Re: Rename dir on server can cause client to get ESTALE - this time
 with PATCH
Message-ID: <20111201021251.GY2203@ZenIV.linux.org.uk>
References: <20111114131929.7b341444@notabene.brown>
 <20111201124922.22e7d72f@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20111201124922.22e7d72f@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 01, 2011 at 12:49:22PM +1100, NeilBrown wrote:

> If the path was "/some/long/path/.", then the final component ("path" in
> this case) has already been revalidated and there is no particular
> need to do it again.
> 
> If we change nd->last_type to refer to "the last component looked at"
> rather than just "the last component", then these cases can be
> detected by "nd->last_type != LAST_NORM".

This is just plain wrong.  Let's *not* bring more dependencies on
nameidata into ->d_revalidate().  The goal is to get rid of it there...

FWIW, if you want a really nasty bug in that area, consider this:

mkdir /tmp/a
mkdir /tmp/b
echo "local file" >/tmp/x
mount -t nfs4 $SOMETHING /tmp/a
mount -t nfs4 $SOMETHING /tmp/b
echo "NFS file" >/tmp/a/x
mount --bind /tmp/x /tmp/a/x

now try opening /tmp/b/x.  And watch the NFS traffic; there won't be OPEN
request for x on server.  Why?  Because NFS sees that x is a mountpoint in
*some* instance of that filesystem.  And decides that opening it would be
wrong.  And so it would, if we were asked to open /tmp/a/x.  Alas, in this
case, while dentry is the same, it does *not* have anything mounted on it.
What we get is ->d_revalidate() returning without issuing OPEN and ->open()
being called - again, without issuing OPEN, since it assumes that ->lookup()
or ->d_revalidate() had done it for us.

Plain IO on resulting descriptor will work and work correcly (you'll get
"NFS file\n" read from it), but try to do F_SETLK on it and it'll fail
since that requires the server to have seen an OPEN.

As far as I can tell, the idea of open done in ->d_revalidate() is
unsalvagable.  It's simply the wrong place for that.  Note that NFS
is the only filesystem trying to do atomic open stuff in its ->d_revalidate()
and it's not succeeding.

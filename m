Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zeniv.linux.org.uk ([195.92.253.2]:57111 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751303Ab2K3CAu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Nov 2012 21:00:50 -0500
Date: Fri, 30 Nov 2012 02:00:48 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Patrick McLean <patrick@cim.mcgill.ca>
Cc: Patrick McLean <patrickm@gaikai.com>, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: Re: Regression with initramfs and nfsroot (appears to be in the
 dcache)
Message-ID: <20121130020047.GA4939@ZenIV.linux.org.uk>
References: <20121129213316.GU4939@ZenIV.linux.org.uk>
 <CAE2NFgWCnmgSCsw7MzRkqBLTHgRDG-FvKKcbTHN6UqePK6Ef+Q@mail.gmail.com>
 <20121129222109.GW4939@ZenIV.linux.org.uk>
 <50B7E759.9070007@gaikai.com>
 <20121129234326.GX4939@ZenIV.linux.org.uk>
 <50B7FBA7.2030300@gaikai.com>
 <20121130003502.GY4939@ZenIV.linux.org.uk>
 <50B8046F.7030308@cim.mcgill.ca>
 <20121130013628.GZ4939@ZenIV.linux.org.uk>
 <50B811BA.6070503@cim.mcgill.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <50B811BA.6070503@cim.mcgill.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 29, 2012 at 05:54:02PM -0800, Patrick McLean wrote:
> > 	Very interesting.  Do you have anything mounted on the corresponding
> > directories on server?  The picture looks like you are getting empty
> > fhandles in readdir+ respons for exactly the same directories that happen
> > to be mountpoints on client.  In any case, we shouldn't do that blind
> > d_drop() - empty fhandles can happen.  The only remaining question is
> > why do they happen on that set of entries.  From my reading of
> > encode_entryplus_baggage() it looks like we have compose_entry_fh()
> > failing for those entries and those entries alone.  One possible cause
> > would be d_mountpoint(dchild) being true on server.  If it is true, we
> > can declare the case closed; if not, I really wonder what's going on.
> 
> Those directories do have the server's own copies of the said directories bind mounted at the moment in a separate mount namespace.
> 
> Unmounting those directories on the server does appear to stop the WARN_ON from triggering.

OK, that settles it.  WARN_ON() and printks in the area can be dropped;
the right fix is below.  However, there's a similar place in cifs that
also needs to be dealt with and I really, really wonder why the hell do
we do d_drop() in nfs_revalidate_lookup().  It's not relevant in this
bug, but I would like to understand what's wrong with simply returning
0 from ->d_revalidate() and letting the caller (in fs/namei.c) take care
of unhashing, etc. itself.  Would make have_submounts() in there pointless
as well - we could just return 0 and let d_invalidate() take care of the
checks...  Trond?

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -450,7 +450,8 @@ void nfs_prime_dcache(struct dentry *parent, struct nfs_entry *entry)
 			nfs_refresh_inode(dentry->d_inode, entry->fattr);
 			goto out;
 		} else {
-			d_drop(dentry);
+			if (d_invalidate(dentry) != 0)
+				goto out;
 			dput(dentry);
 		}
 	}

From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [PATCH][RFC] NFS: Improving the access cache
Date: Tue, 25 Apr 2006 19:31:36 -0600
Message-ID: <20060426013136.GF32505@parisc-linux.org>
References: <444EC96B.80400@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <444EC96B.80400@RedHat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Tue, Apr 25, 2006 at 09:14:19PM -0400, Steve Dickson wrote:
> The attached patch used a hash table to store the nfs_access_entry
> entires which cause the ACCESS request to only happen when the
> attributes timeout.. The table is indexed by the addition of the
> nfs_inode pointer and the cr_uid in the cred structure which should
> spread things out nicely for some decent scalability (although the
> locking scheme may need to be reworked a bit). The table has 256 entries
> of struct list_head giving it a total size of 2k.

Seems to me like you could use an hlist instead, saving you 1k.


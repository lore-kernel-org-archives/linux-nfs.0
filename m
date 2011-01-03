From: "Kirill A. Shutemov" <kas@openvz.org>
Subject: Re: [PATCH v2 00/12] make rpc_pipefs be mountable multiple time
Date: Mon, 3 Jan 2011 18:53:57 +0200
Message-ID: <20110103165357.GA32196@shutemov.name>
References: <AANLkTi=AXz21wDeE1vPVD-6cEtj6faXN9x09eHDCsTkB@mail.gmail.com>
 <20101230085139.GA29697@shutemov.name>
 <4D1C4C7C.6050606@parallels.com>
 <20101230094433.GB29697@shutemov.name>
 <4D1C5953.6020200@parallels.com>
 <20101230104416.GA31824@shutemov.name>
 <AANLkTim2QrkSW0HufD5wp=-8ikwydN5SUS+fdWK6JHqb@mail.gmail.com>
 <20101230114514.GA31976@shutemov.name>
 <4D1C809B.30405@parallels.com>
 <20101231130329.GA3610@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rob Landley <rlandley@parallels.com>,
	Rob Landley <rob@landley.net>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>,
	Pavel Emelyanov <xemul@parallels.com>,
	linux-nfs@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Kirill A. Shutemov" <kas@openvz.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101231130329.GA3610@shutemov.name>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 31, 2010 at 03:03:29PM +0200, Kirill A. Shutemov wrote:
> On Thu, Dec 30, 2010 at 06:52:43AM -0600, Rob Landley wrote:
> > On 12/30/2010 05:45 AM, Kirill A. Shutemov wrote:
> > > Currently, there is no association between rpc_pipefs and mount namespace,
> > 
> > There is in that the root context doesn't need to have this mounted, and 
> > new namespaces do.  So there's an existing association between a LACK of 
> > a namespace and a different default behavior.
> >
> > My understanding (correct me if I'm wrong) is that the historical 
> > behavior is that there's only one, and it doesn't actually live anywhere 
> > in the filesystem tree.  You're adding a special location.  I'm 
> > wondering if there's any way for that location not to be special.
> 
> /var/lib/net/rpc_pipefs is default path where userspace part of NFS stack
> (gssd, idmapd) want to see rpc_pipefs
> 
> > > so I don't see simple way to restrict number of rpc_pipefs per mount
> > > namespace. Associating mount namespace with rpc_pipefs is not a good idea,
> > > I think.
> > 
> > I'm talking about associating a default rpc_pipefs instance with a 
> > namespace, which it seems to me you're already doing by emulating the 
> > legacy behavior.  Before you CLONE_NEWNS you get a magic default mount 
> > that doesn't exist in the tree.  After you CLONE_NEWNS you get something 
> > like -EINVAL unless you supply your own default.
> 
> Root namespace is special. In case of nfsroot you need rpc_pipefs before
> root available.
> 
> > (I'm actually not sure 
> > why new namespaces don't fall back to the magic global one...)
> 
> It breaks isolation. Container should not use host's rpc_pipefs without
> host's permission.
>  
> > I'm suggesting that if the user doesn't specify -o rpcmount then the 
> > default could be the first rpc_pipefs mount visible to the current 
> > process context, rather than a specific path.  Logic to do that exists 
> > in the proc/self/mounts code (which I'm reading through now...).
> 
> static int check_rpc_pipefs(struct vfsmount *mnt, void *arg)
> {
>         struct vfsmount **rpcmount = arg;
>         struct path path = {
>                 .mnt = mnt,
>                 .dentry = mnt->mnt_root,
>         };
> 
>         if (!mnt->mnt_sb)
>                 return 0;
>         if (mnt->mnt_sb->s_magic != RPCAUTH_GSSMAGIC)
>                 return 0;
> 
>         if (!path_is_under(&path, &current->fs->root))
>                 return 0;
> 
>         *rpcmount = mntget(mnt);
>         return 1;
> }
> 
> struct vfsmount *get_rpc_pipefs(const char *p)
> {
>         int error;
>         struct vfsmount *rpcmount = ERR_PTR(-EINVAL);
>         struct path path;
> 
>         if (!p) {
>                 iterate_mounts(check_rpc_pipefs, &rpcmount,
>                                 current->nsproxy->mnt_ns->root);
> 
>                 if (IS_ERR(rpcmount) && (current->nsproxy->mnt_ns ==
>                                         init_task.nsproxy->mnt_ns))
>                         return mntget(init_rpc_pipefs);
> 
>                 return rpcmount;
>         }
> 
>         error = kern_path(p, LOOKUP_FOLLOW | LOOKUP_DIRECTORY, &path);
>         if (error)
>                 return ERR_PTR(error);
> 
>         check_rpc_pipefs(path.mnt, &rpcmount);
>         path_put(&path);
> 
>         return rpcmount;
> }
> EXPORT_SYMBOL_GPL(get_rpc_pipefs);
> 
> Something like this? Patch to replace patch #10 attached.

Any comments?

-- 
 Kirill A. Shutemov

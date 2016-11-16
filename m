Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43972 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751953AbcKPNzf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 16 Nov 2016 08:55:35 -0500
Date: Wed, 16 Nov 2016 08:55:33 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: Schumaker Anna <anna.schumaker@netapp.com>,
        List Linux NFS Mailing <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2] nfs: only show mountproto in /proc/mounts if set
Message-ID: <20161116135533.fytzlidwltjpz67e@tonberry.usersys.redhat.com>
References: <1479243592-38858-1-git-send-email-smayhew@redhat.com>
 <56E2C0D6-40A3-45E9-815C-A50A94A3A95C@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <56E2C0D6-40A3-45E9-815C-A50A94A3A95C@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 15 Nov 2016, Trond Myklebust wrote:

> 
> > On Nov 15, 2016, at 15:59, Scott Mayhew <smayhew@redhat.com> wrote:
> > 
> > The nfs_server->mountd_protocol field doesn't get set when a v3 submount
> > is created, causing /proc/mounts to show 'mountproto=' without a netid.
> > This in turn causes umount.nfs to emit the error message "Failed to find
> > '' protocol" if you manually unmount the submount.
> > 
> > Signed-off-by: Scott Mayhew <smayhew@redhat.com>
> > ---
> > fs/nfs/super.c | 3 ++-
> > 1 file changed, 2 insertions(+), 1 deletion(-)
> > 
> > diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> > index 001796b..b60946d 100644
> > --- a/fs/nfs/super.c
> > +++ b/fs/nfs/super.c
> > @@ -532,7 +532,8 @@ static void nfs_show_mountd_netid(struct seq_file *m, struct nfs_server *nfss,
> > {
> > 	struct sockaddr *sap = (struct sockaddr *) &nfss->mountd_address;
> > 
> > -	seq_printf(m, ",mountproto=");
> > +	if (nfss->mountd_protocol || showdefaults)
> > +		seq_printf(m, ",mountproto=");
> > 	switch (sap->sa_family) {
> > 	case AF_INET:
> > 		switch (nfss->mountd_protocol) {
> 
> Does it make sense to call nfs_show_mountd_options() at all for the case of a v3 submount?
> 
Probably not, but I don't see a way to positively identify that it's a
submount if all you have is the nfs_server struct (I don't see a way to
backtrack to the mount struct).  Or are you suggesting to just check one
of the mountd-related fields (say mountd_addrlen) before calling
nfs_show_mount_options() and skip it altogether if appropriate?

-Scott

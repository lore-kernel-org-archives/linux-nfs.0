Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.12.86]:45514 "EHLO
	tombraider.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1030608Ab2CBUqH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Mar 2012 15:46:07 -0500
Date: Fri, 2 Mar 2012 15:46:03 -0500
From: Jim Rees <rees@umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/3] NFS: Ensure we display the minor version correctly
 in /proc/mounts etc.
Message-ID: <20120302204603.GA1807@umich.edu>
References: <1330715086-13871-1-git-send-email-Trond.Myklebust@netapp.com>
 <1330715086-13871-2-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1330715086-13871-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:

  The 'minorversion' mount option is now deprecated, so we need to display
  the minor version number in the 'vers=' format.
  
  Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
  ---
   fs/nfs/super.c |   12 ++++++++++--
   1 files changed, 10 insertions(+), 2 deletions(-)
  
  diff --git a/fs/nfs/super.c b/fs/nfs/super.c
  index ab58bb9..7f0c93f 100644
  --- a/fs/nfs/super.c
  +++ b/fs/nfs/super.c
  @@ -640,7 +640,6 @@ static void nfs_show_nfsv4_options(struct seq_file *m, struct nfs_server *nfss,
   	struct nfs_client *clp = nfss->nfs_client;
   
   	seq_printf(m, ",clientaddr=%s", clp->cl_ipaddr);
  -	seq_printf(m, ",minorversion=%u", clp->cl_minorversion);
   }
   #else
   static void nfs_show_nfsv4_options(struct seq_file *m, struct nfs_server *nfss,
  @@ -649,6 +648,15 @@ static void nfs_show_nfsv4_options(struct seq_file *m, struct nfs_server *nfss,
   }
   #endif
   
  +static void nfs_show_nfs_version(struct seq_file *m,
  +		unsigned int version,
  +		unsigned int minorversion)
  +{
  +	seq_printf(m, ",vers=%u", version);

Isn't "nfsvers=" preferred?  That's what the man page implies.

  +	if (version == 4)

Should this be "version >= 4"?  (only half serious)

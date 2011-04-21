Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from lvps87-230-0-242.dedicated.hosteurope.de ([87.230.0.242]:47134
	"EHLO lvps87-230-0-242.dedicated.hosteurope.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751248Ab1DUGYt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Apr 2011 02:24:49 -0400
Date: Thu, 21 Apr 2011 08:24:39 +0200
From: Michael Guntsche <mike@it-loops.com>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>, kwc@umich.edu
Subject: Re: [BUG] supported_krb5_enctypes not available if GSS support
 compiled as a module
Message-ID: <20110421082106@it-loops.com>
References: <20110420224241@it-loops.com>
 <20110420213906.GB24503@pad.home.fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110420213906.GB24503@pad.home.fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 20 Apr 11 17:39, J. Bruce Fields wrote:
> On Wed, Apr 20, 2011 at 10:49:51PM +0200, Michael Guntsche wrote:
> > Hello Bruce,
> > 
> > Commit 0a5e5f122c nfsd: fix compile error fixed a compile error by
> > putting the code between an #ifdef CONFIG_SUNRPC_GSS.
> > 
> > In my case this is compiled as a module so CONFIG_SUNRPC_GSS_MODULE is
> > defined but not CONFIG_SUNRPC_GSS. I do not know if this was on purpose
> > but as it is now "supported_krb5_enctypes" is only available if GSS
> > support is compiled in the kernel.
> 
> Ugh, fuzzy thinking on my part.
> 
> So I guess to do this right we want modules to be able to dynamically
> add files to the nfsd filesystem at module load time?

Good morning,

A little bit more sleep and taking a look at other modules I came up
with the following patch which looks ok for me.
I think you find a better wording for this commit though.
___________________________________

Fix supported_krb5_enctypes proc entry when compiled as module

The GSS module can also be compiled as a module so check for this
configuration as well. 

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 1f5eae4..33660ca 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -189,7 +189,7 @@ static struct file_operations export_features_operations = {
 	.release	= single_release,
 };
 
-#ifdef CONFIG_SUNRPC_GSS
+#if defined(CONFIG_SUNRPC_GSS) || defined(CONFIG_SUNRPC_GSS_MODULE)
 static int supported_enctypes_show(struct seq_file *m, void *v)
 {
 	struct gss_api_mech *k5mech;
@@ -1427,7 +1427,7 @@ static int nfsd_fill_super(struct super_block * sb, void * data, int silent)
 		[NFSD_Versions] = {"versions", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Ports] = {"portlist", &transaction_ops, S_IWUSR|S_IRUGO},
 		[NFSD_MaxBlkSize] = {"max_block_size", &transaction_ops, S_IWUSR|S_IRUGO},
-#ifdef CONFIG_SUNRPC_GSS
+#if defined(CONFIG_SUNRPC_GSS) || defined(CONFIG_SUNRPC_GSS_MODULE)
 		[NFSD_SupportedEnctypes] = {"supported_krb5_enctypes", &supported_enctypes_ops, S_IRUGO},
 #endif /* CONFIG_SUNRPC_GSS */
 #ifdef CONFIG_NFSD_V4

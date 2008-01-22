From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/2] NLM failover unlock commands
Date: Tue, 22 Jan 2008 17:53:12 -0500
Message-ID: <20080122225312.GO24697@fieldses.org>
References: <4781BB0D.90706@redhat.com> <20080108170220.GA21401@infradead.org> <20080108174958.GA25025@infradead.org> <4783E3C9.3040803@redhat.com> <20080109180214.GA31071@infradead.org> <20080110075959.GA9623@infradead.org> <4788665B.4020405@redhat.com> <20080114230742.GA16975@fieldses.org> <18315.61638.14133.308991@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wendy Cheng <wcheng@redhat.com>,
	Christoph Hellwig <hch@infradead.org>,
	NFS list <linux-nfs@vger.kernel.org>, cluster-devel@redhat.com
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:56085 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753883AbYAVWxR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Jan 2008 17:53:17 -0500
In-Reply-To: <18315.61638.14133.308991-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 15, 2008 at 10:31:18AM +1100, Neil Brown wrote:
> On Monday January 14, bfields@fieldses.org wrote:
> > >  
> > > +static ssize_t failover_unlock_ip(struct file *file, char *buf, size_t size)
> > > +{
> > > +	__be32 server_ip;
> > > +	char *fo_path;
> > > +	char *mesg;
> > > +
> > > +	/* sanity check */
> > > +	if (size <= 0)
> > > +		return -EINVAL;
> > 
> > Not only is size never negative, it's actually an unsigned type here, so
> > this is a no-op.
> 
> No,  It it equivalent to
>           if (size == 0)
> 
> which alternative is clearer and more maintainable is debatable.
> 
> > 
> > > +
> > > +	if (buf[size-1] == '\n')
> > > +		buf[size-1] = 0;
> > 
> > The other write methods in this file actually just do
> > 
> > 	if (buf[size-1] != '\n')
> > 		return -EINVAL;
> 
> and those which don't check for size == 0 are underflowing an array.
> That should probably be fixed.

?

--b.

commit 6685389d610950126f700d25f3d010c7049441c3
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Tue Jan 22 17:40:42 2008 -0500

    nfsd: more careful input validation in nfsctl write methods
    
    Neil Brown points out that we're checking buf[size-1] in a couple places
    without first checking whether size is zero.
    
    Actually, given the implementation of simple_transaction_get(), buf[-1]
    is zero, so in both of these cases the subsequent check of the value of
    buf[size-1] will catch this case.
    
    But it seems fragile to depend on that, so add explicit checks for this
    case.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
    Cc: Neil Brown <neilb@suse.de>

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 61015cf..9ed2a2b 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -304,6 +304,9 @@ static ssize_t write_filehandle(struct file *file, char *buf, size_t size)
 	struct auth_domain *dom;
 	struct knfsd_fh fh;
 
+	if (size == 0)
+		return -EINVAL;
+
 	if (buf[size-1] != '\n')
 		return -EINVAL;
 	buf[size-1] = 0;
@@ -663,7 +666,7 @@ static ssize_t write_recoverydir(struct file *file, char *buf, size_t size)
 	char *recdir;
 	int len, status;
 
-	if (size > PATH_MAX || buf[size-1] != '\n')
+	if (size == 0 || size > PATH_MAX || buf[size-1] != '\n')
 		return -EINVAL;
 	buf[size-1] = 0;
 

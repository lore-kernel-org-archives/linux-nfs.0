From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 013 of 20] knfsd: nfsd: factor out code
	from	show_expflags
Date: Thu, 19 Jul 2007 10:16:14 +1000
Message-ID: <18078.44366.961344.428533@notabene.brown>
References: <20070710121949.12548.patches@notabene>
	<1070710022737.13509@suse.de>
	<20070713002933.f15724a7.akpm@linux-foundation.org>
	<20070718230555.GN7111@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Morton <akpm@linux-foundation.org>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IBJgx-0002cz-CL
	for nfs@lists.sourceforge.net; Wed, 18 Jul 2007 17:16:27 -0700
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IBJh0-0005Hc-QD
	for nfs@lists.sourceforge.net; Wed, 18 Jul 2007 17:16:31 -0700
In-Reply-To: message from J. Bruce Fields on Wednesday July 18
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Wednesday July 18, bfields@fieldses.org wrote:
> On Fri, Jul 13, 2007 at 12:29:33AM -0700, Andrew Morton wrote:
> > On Tue, 10 Jul 2007 12:27:37 +1000 NeilBrown <neilb@suse.de> wrote:
> > 
> > > +static void exp_flags(struct seq_file *m, int flag, int fsid,
> > > +		uid_t anonu, uid_t anong, struct nfsd4_fs_locations *fsloc)
> > > +{
> > > +	show_expflags(m, flag, NFSEXP_ALLFLAGS);
> > >  	if (flag & NFSEXP_FSID)
> > > -		seq_printf(m, "%sfsid=%d", first++?",":"", fsid);
> > > +		seq_printf(m, ",fsid=%d", fsid);
> > >  	if (anonu != (uid_t)-2 && anonu != (0x10000-2))
> > > -		seq_printf(m, "%sanonuid=%d", first++?",":"", anonu);
> > > +		seq_printf(m, ",sanonuid=%d", anonu);
> > 
> > It's a bit presumptuous to print a uid_t with "%d".  Fortunately it
> > will work OK with all the present architectures.
> > 
> > But in general: be cautious when feeding opaque types to printk.
> 
> OK, here I'm still confused--what should we be doing instead?

Cast the variable to a type that printf knows about.
       seq_printf(m, ",anonuid=%d", (int)anonu);

Or maybe cast it to (long) and use %ld, just in case...

Note the stray 's' in the current patch, after the comma!

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:53434 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756605Ab3KNQkq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Nov 2013 11:40:46 -0500
Date: Thu, 14 Nov 2013 08:40:46 -0800
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: sharing protocol defintions between client and server?
Message-ID: <20131114164046.GA32275@infradead.org>
References: <20131113162116.GA14577@infradead.org>
 <20131114150546.GA21152@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131114150546.GA21152@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 14, 2013 at 10:05:46AM -0500, J. Bruce Fields wrote:
> On Wed, Nov 13, 2013 at 08:21:16AM -0800, Christoph Hellwig wrote:
> > >From a lot of the recent work it seems like there's basically no
> > sharing of protocol definitions between the Linux NFS client and
> > server, which seems fairly annoying to me.
> 
> What are you thinking of exactly?
> 
> I suspect that there could be more sharing.

To make it easy I'll just quote from the SEEK patches.

client:

+struct nfs42_seek_args {
+	struct nfs4_sequence_args	seq_args;
+
+	struct nfs_fh			*sa_fh;
+	nfs4_stateid			*sa_stateid;
+	u64				sa_offset;
+	u32				sa_what;
+};
+
+struct nfs42_seek_res {
+	struct nfs4_sequence_res	seq_res;
+	unsigned int			status;
+
+	u32	sr_eof;
+	u32	sr_whence;
+	u64	sr_offset;
+	u64	sr_length;
+	u32	sr_allocated;
+};
+#endif

server:

+struct nfsd4_seek {
+	/* request */
+	stateid_t	seek_stateid;
+	loff_t		seek_offset;
+	u32		seek_whence;
+
+	/* response */
+	u64		seek_pos;
+	u32		seek_eof;
+	u64		seek_length;
+	u32		seek_allocated;
+};

note that a lot of server operations also seem to have separate
args and result substrutures.  In general I'd love to have one
structure for the actual on-the wire operation in a header, and then
client and server could build in-memory versions around them.

Of course just generating those from the XDR would be even better.

Maybe I'll play around with doing a krpcgen that we can initially
just use for producing the structures, for which it should be
pretty clear benefit.  If we're lucky we might be to also move
some marshalling/unmarshalling over to it later.

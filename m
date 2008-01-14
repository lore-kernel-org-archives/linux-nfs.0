From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 1/2] NLM failover unlock commands
Date: Tue, 15 Jan 2008 10:31:18 +1100
Message-ID: <18315.61638.14133.308991@notabene.brown>
References: <4781BB0D.90706@redhat.com>
	<20080108170220.GA21401@infradead.org>
	<20080108174958.GA25025@infradead.org>
	<4783E3C9.3040803@redhat.com>
	<20080109180214.GA31071@infradead.org>
	<20080110075959.GA9623@infradead.org>
	<4788665B.4020405@redhat.com>
	<20080114230742.GA16975@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wendy Cheng <wcheng@redhat.com>,
	Christoph Hellwig <hch@infradead.org>,
	NFS list <linux-nfs@vger.kernel.org>, cluster-devel@redhat.com
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.suse.de ([195.135.220.2]:48211 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751667AbYANXbZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Jan 2008 18:31:25 -0500
In-Reply-To: message from J. Bruce Fields on Monday January 14
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Monday January 14, bfields@fieldses.org wrote:
> >  
> > +static ssize_t failover_unlock_ip(struct file *file, char *buf, size_t size)
> > +{
> > +	__be32 server_ip;
> > +	char *fo_path;
> > +	char *mesg;
> > +
> > +	/* sanity check */
> > +	if (size <= 0)
> > +		return -EINVAL;
> 
> Not only is size never negative, it's actually an unsigned type here, so
> this is a no-op.

No,  It it equivalent to
          if (size == 0)

which alternative is clearer and more maintainable is debatable.

> 
> > +
> > +	if (buf[size-1] == '\n')
> > +		buf[size-1] = 0;
> 
> The other write methods in this file actually just do
> 
> 	if (buf[size-1] != '\n')
> 		return -EINVAL;

and those which don't check for size == 0 are underflowing an array.
That should probably be fixed.

> 
> I don't know why.  But absent some reason, I'd rather these two new
> files behaved the same as existing ones.
> 
> > +
> > +	fo_path = mesg = buf;
> > +	if (qword_get(&mesg, fo_path, size) < 0)
> > +		return -EINVAL;
> 
> "mesg" is unneeded here, right?  You can just do:
> 
> 	fo_path = buf;
> 	if (qword_get(&buf, buf, size) < 0)
> 
> > +
> > +	server_ip = in_aton(fo_path);
> 
> It'd be nice if we could sanity-check this.  (Is there code already in
> the kernel someplace to do this?)

In ip_map_parse we do:

	if (sscanf(buf, "%u.%u.%u.%u%c", &b1, &b2, &b3, &b4, &c) != 4)
		return -EINVAL;
	...
	addr.s_addr =
		htonl((((((b1<<8)|b2)<<8)|b3)<<8)|b4);

I suspect that would fit in an inline function somewhere quite
nicely. but where?


NeilBrown

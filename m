From: "Brian J. Murrell" <brian-SquOHqY54CVWr29BmMi2cA@public.gmane.org>
Subject: Re: gssapi and nfs4
Date: Tue, 04 Nov 2008 13:53:17 -0500
Message-ID: <1225824797.2247.345.camel@brian-laptop>
References: <1225813410.2247.279.camel@brian-laptop>
	 <89c397150811041000l93b9831w1e8dce2175c6d51f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from server.klug.on.ca ([205.189.48.131]:2996 "EHLO
	server.klug.on.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752237AbYKDSxU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Nov 2008 13:53:20 -0500
Received: from linux.interlinx.bc.ca (d193-213-184.home3.cgocable.net [67.193.213.184])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by server.klug.on.ca (Postfix) with ESMTP id 20A142803
	for <linux-nfs@vger.kernel.org>; Tue,  4 Nov 2008 13:53:19 -0500 (EST)
Received: from [10.75.22.172] (brian-laptop.ilinx [10.75.22.172])
	by linux.interlinx.bc.ca (Postfix) with ESMTP id 645FE800A
	for <linux-nfs@vger.kernel.org>; Tue,  4 Nov 2008 13:53:17 -0500 (EST)
In-Reply-To: <89c397150811041000l93b9831w1e8dce2175c6d51f-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2008-11-04 at 13:00 -0500, William A. (Andy) Adamson wrote:
> Hi

Hello,

> In general, the instructions at the CITI web site will be useful.
> 
> From http://www.citi.umich.edu/projects/nfsv4/linux/using-nfsv4.html:
> 
> Mounting and exporting krb5
> 
> To mount a filesystem using krb5, provide the "-osec=krb5" option to mount.

Indeed.

> To export a filesystem using krb5, add the export option "sec=krb5".
> (Note: if your kernel is older than 2.6.23, or nfs-utils older than
> 1.1.1, you will instead need to export to a special client named
> "gss/krb5".)

Ahhh.  This, I did not know.

> So instead of using the old "gss/krb5" which indeed did replace the
> ip/netmasks list, you can now specify the use of gssapi with an export
> option, and still set ip/netmasks.

Cool.  I think it's still useful to be able to provide some exports as
ro (i.e. forced ro by the server) to some machines (and rw to others)
even with gssapi, yes?

I did notice the bit of text about the single pseudo filesystem.  Given
that on my server, I exported a number of filesystems, including / to
privileged (I'm in a very small and trusted environment) clients, it
seemed natural to just set / to fsid 0.  I also exported the few other
exports I wanted some nfs4 clients to mount as such:

/               gss/krb5i(rw,insecure,sync,wdelay,no_subtree_check,no_root_squash,fsid=0,crossmnt,anonuid=65534,anongid=65534)
/home           gss/krb5i(rw,no_root_squash,sync,subtree_check,anonuid=65534,anongid=65534)
/mnt/data       gss/krb5i(rw,sync,subtree_check,crossmnt,anonuid=65534,anongid=65534)
/mnt/data/photos gss/krb5i(rw,sync,subtree_check,anonuid=65534,anongid=65534)

where those are all on different filesystems on the server.  I'm
starting to feel like this is not how it's supposed to be done.

b.



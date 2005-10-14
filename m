From: Neil Brown <neilb@suse.de>
Subject: Re: block dev minor > 255 and exporting fs
Date: Fri, 14 Oct 2005 17:41:54 +1000
Message-ID: <17231.24898.845106.533665@cse.unsw.edu.au>
References: <20051007094532.GW6490@levanta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EQKCl-0008QC-5Q
	for nfs@lists.sourceforge.net; Fri, 14 Oct 2005 00:42:15 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EQKCf-0001im-AY
	for nfs@lists.sourceforge.net; Fri, 14 Oct 2005 00:42:12 -0700
To: Richard Hirst <rhirst@levanta.com>
In-Reply-To: message from Richard Hirst on Friday October 7
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Friday October 7, rhirst@levanta.com wrote:
> > Hi.  I've noticed that an NFS mount times out when I export a
> > filesystem residing on a block device with a "large" minor number,
> > i.e. beyond the old limit of 255 from when there were only eight bits
> > for the minor number of devices.
> 
> When I looked in to this I decided the problem lay in userland not
> kernel land.  Once you get to minor numbers greater than 255, this
> kernel code:
> 
> +++ linux-2.6.10/fs/nfsd/nfsfh.c        2005-08-05 17:35:12.128552514 +0100
> @@ -351,8 +351,13 @@
> 
>         if (!old_valid_dev(ex_dev) && ref_fh_fsid_type == 0) {
>                 /* for newer device numbers, we must use a newer fsid format */
>                 ref_fh_version = 1;
>                 ref_fh_fsid_type = 3;
>         }
> 
> 
> switches from using a type 0 fsid to a type 3 fsid.
> 
> Then somewhere in mountd it reads that fsid and tries to interpret
> it.  Trouble is nfs-utils only understands fsid types 0 and 1.  I'm
> a bit vague about this .. it was while ago I looked at it, but IIRC
> the nfs-utils code was here:
> 
> nfs-utils-1.0.6/utils/mountd/cache.c round line 122:
> 
>         if (fsidtype < 0 || fsidtype > 1)
>                 goto out; /* unknown type */

Oh yes, user-land hasn't kept up with the kernel very well, has it.
I've just committed a change to the nfs-utils CVS which makes it
understand types 2 and 3.

I guess it might be nearly time for a new nfs-utils release...

> 
> 
> Anyway, the fsid type 0 can actually handle up to 16 bits for major
> and minor and 16 bits was enough for me, so I hacked my kernel to
> use fsid type 0 for minors up to 64K.

Sounds like a sensible approach.

> 
> Obviously things might have moved on since I looked at those code
> versions.

They hadn't, until now.  Thanks.

NeilBrown


-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

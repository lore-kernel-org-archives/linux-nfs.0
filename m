From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: [PATCH] Makes nfs mount warning less frequent and more valuable
Date: Thu, 17 Mar 2005 09:48:52 +1100
Message-ID: <16952.47061.256295.475877@cse.unsw.edu.au>
References: <4237178A.5030003@dgreaves.com>
	<Pine.LNX.4.61.0503151439250.22235@guppy.limebrokerage.com>
	<42384B59.3060408@dgreaves.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Ion Badulescu <ionut@badula.org>, Erez Zadok <ezk@cs.sunysb.edu>,
	am-utils@fsl.cs.sunysb.edu, nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DBhKG-0003sU-SU
	for nfs@lists.sourceforge.net; Wed, 16 Mar 2005 14:49:16 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DBhKF-0003mb-5B
	for nfs@lists.sourceforge.net; Wed, 16 Mar 2005 14:49:16 -0800
To: David Greaves <david@dgreaves.com>
In-Reply-To: message from David Greaves on Wednesday March 16
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

On Wednesday March 16, david@dgreaves.com wrote:
> Neil,

That should be "Trond,.."
It's client-side code, so it belongs to him.  I vaguely recall this
being suggested before, but I don't remember what the issues were.

NeilBrown


> 
> This is in response to an ongoing quest to shut the kernel up when it 
> whines:
>    kernel: nfs warning: mount version older than kernel
> incessantly and uselessly, I spoke to the am-utils people and eventually 
> got some help tracking it down.
> 
> Googling around the error reveals many, many confused souls and no 
> obvious reason for the message.
> 
> Ion Badulescu wrote:
> 
> > David,
> >
> > The basic answer is: don't worry about it, it's not harmful in any way.
> >
> > Until amd supports NFSv4, it will continue to cause the kernel to 
> > print out this message. I've always questioned the usefulness of this 
> > message, given that v2 and v3 clients (and mount programs) are fully 
> > supported and will continue to be for the foreseeable future, but it 
> > never bothered me enough to do something about it.
> 
> So is this the logic to produce a potentially useful warning?
> patch is against 2.6.11
> 
> (This code is only executed at mount time so I assume the minor 
> additional logic for a mere warning is acceptable)
> 
> It certainly makes life quieter with heavily automounted systems.
> 
> 
> Signed-off-by: David Greaves <david@dgreaves.com>
> 
> --- fs/nfs/inode.c.orig	2005-03-15 16:12:07.000000000 +0000
> +++ fs/nfs/inode.c	2005-03-16 13:42:13.000000000 +0000
> @@ -1385,9 +1385,19 @@ static struct super_block *nfs_get_sb(st
>  	/* Zero out the NFS state stuff */
>  	init_nfsv4_state(server);
>  
> +	/* NFS v2 and v3 are interoperable and will continue to be so..
> +	 * This should be reviewed when NFS_MOUNT_VERSION increments */
> +	if ((data->version <2 ||
> +	     data->version >6 ||
> +	     NFS_MOUNT_VERSION < 2 ||
> +	     NFS_MOUNT_VERSION > 6)
> +	    && data->version != NFS_MOUNT_VERSION) {
> +		printk("nfs warning: possibly dangerous mount version incompatibility: mount(v%d) %s than kernel(v%d)\n",
> +		       data->version, data->version < NFS_MOUNT_VERSION ? "older" : "newer", NFS_MOUNT_VERSION);
> +	}
> +	
> +	/* All <> values of NFS_MOUNT_VERSION 2..6 are handled */
>  	if (data->version != NFS_MOUNT_VERSION) {
> -		printk("nfs warning: mount version %s than kernel\n",
> -			data->version < NFS_MOUNT_VERSION ? "older" : "newer");
>  		if (data->version < 2)
>  			data->namlen = 0;
>  		if (data->version < 3)


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

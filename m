From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: async vs. sync
Date: Thu, 25 Nov 2004 10:34:53 +1100
Message-ID: <16805.6813.832366.526243@cse.unsw.edu.au>
References: <482A3FA0050D21419C269D13989C611307CF4B56@lavender-fe.eng.netapp.com>
	<41A3AFC4.6080404@int-evry.fr>
	<41A4D6C5.2060902@int-evry.fr>
	<16805.2572.79895.275921@cse.unsw.edu.au>
	<41A515DC.7010408@int-evry.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Lever, Charles" <Charles.Lever@netapp.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CX6fU-0005GN-Gk
	for nfs@lists.sourceforge.net; Wed, 24 Nov 2004 15:35:24 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CX6fT-0008M6-Bf
	for nfs@lists.sourceforge.net; Wed, 24 Nov 2004 15:35:24 -0800
To: jehan procaccia <jehan.procaccia@int-evry.fr>
In-Reply-To: message from jehan procaccia on Thursday November 25
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

On Thursday November 25, jehan.procaccia@int-evry.fr wrote:
> 
> So it seem to be a very good advice to echo   30 500 0 0 100 500 60 20 0 
>  > /proc/sys/vm/bdflush  :-)
> however this is a general configuration, will it disturb other devices ? 
> what means every figures here ? why where they set to an non optimal 
> value iin the 1st place ?

The values are fairly optimal for most usages.  They just happen to be
not so good for an NFS server using ext3 with data=journal....

The effect of the change is that data is flushed to disc more
quickly.  This provides fewer opportunities to coalesce nearby data into
large blocks, and means that blocks that are being changed frequently
get written out more often.  So it could cause a bit more disk IO, but
I doubt that it would be much.

As for the meanings of the numbers: fs/buffer.c contains:
/* The dummy values in this structure are left in there for compatibility
 * with old programs that play with the /proc entries.
 */
union bdflush_param {
	struct {
		int nfract;	/* Percentage of buffer cache dirty to 
				   activate bdflush */
		int ndirty;	/* Maximum number of dirty blocks to write out per
				   wake-cycle */
		int dummy2;	/* old "nrefill" */
		int dummy3;	/* unused */
		int interval;	/* jiffies delay between kupdate flushes */
		int age_buffer;	/* Time for normal buffer to age before we flush it */
		int nfract_sync;/* Percentage of buffer cache dirty to 
				   activate bdflush synchronously */
		int nfract_stop_bdflush; /* Percetange of buffer cache dirty to stop bdflush */
		int dummy5;	/* unused */
	} b_un;
	unsigned int data[N_PARAM];
} bdf_prm = {{30, 500, 0, 0, 5*HZ, 30*HZ, 60, 20, 0}};

/* These are the min and max parameter values that we will allow to be assigned */
int bdflush_min[N_PARAM] = {  0,  1,    0,   0,  0,   1*HZ,   0, 0, 0};
int bdflush_max[N_PARAM] = {100,50000, 20000, 20000,10000*HZ, 10000*HZ, 100, 100, 0};

so a lot of them don't mean anything.  The key ones for this exercise
are "age_buffer" which we set to 500 (5 seconds) and "interval" which
needs to be less than age_buffer.


> 
> PS:  different optimisation:
> I've read this "the maximum block size is
> defined by the value of the kernel constant *NFSSVC_MAXBLKSIZE*,
> found in the Linux kernel source file ./include/linux/nfsd/const.h"
> is there a way to change my actual 8K buffer size to 32 K without 
> recompiling the kernel ?

No, and you probably shouldn't.  knfsd in 2.4 is unlikely to handle
requests larger than a couple of pages very well, which is why the
size if set to 2 pages by default.  2.6 handles larger requests much
better and so sets a larger page size.

NeilBrown


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

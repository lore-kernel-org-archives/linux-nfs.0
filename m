From: Ian Kent <raven@themaw.net>
Subject: RE: mtab and procs not in sync?
Date: Thu, 10 Jun 2004 09:03:26 +0800 (WST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.58.0406100901220.6687@wombat.indigo.net.au>
References: <482A3FA0050D21419C269D13989C61130435E236@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: James Pearson <james-p@moving-picture.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BYDoh-0004w8-Q0
	for nfs@lists.sourceforge.net; Wed, 09 Jun 2004 17:53:15 -0700
Received: from wombat.indigo.net.au ([202.0.185.19])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1BYDoh-0007mS-31
	for nfs@lists.sourceforge.net; Wed, 09 Jun 2004 17:53:15 -0700
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C61130435E236@lavender-fe.eng.netapp.com>
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

On Wed, 9 Jun 2004, Lever, Charles wrote:

> i would guess that if seq_file is used, then /proc/mounts should be OK.
> 
> i was looking at a RHEL AS 2.1 system last week that used the single
> page I/O model for /proc/mounts, and it was definitely busted.

We probably need to start talking versions, back ports and vendor kernels 
to get a clear picture of the situation here.

Ian

> 
> > -----Original Message-----
> > From: James Pearson [mailto:james-p@moving-picture.com] 
> > Sent: Wednesday, June 09, 2004 11:05 AM
> > To: Lever, Charles
> > Cc: nfs@lists.sourceforge.net
> > Subject: Re: [NFS] mtab and procs not in sync?
> > 
> > 
> > On a 2.4.26 kernel on x86 I can get /proc/mounts to go over 
> > 4K (over 8K 
> > with about 100 automounted file systems).
> > 
> > Having a quick look through the kernel code I can see 
> > seq_file used in 
> > relation to proc_mounts_operations (fs/proc/base.c) - however 
> > as I don't 
> > pretend to understand the code, I can't say this is the case ...
> > 
> > If 2.4.X does use seq_file, then is it safe to say 
> > /proc/mounts doesn't 
> > suffer from a truncation problem?
> > 



-------------------------------------------------------
This SF.Net email is sponsored by: GNOME Foundation
Hackers Unite!  GUADEC: The world's #1 Open Source Desktop Event.
GNOME Users and Developers European Conference, 28-30th June in Norway
http://2004/guadec.org
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

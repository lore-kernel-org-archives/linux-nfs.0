From: Steve Wampler <swampler@noao.edu>
Subject: Re: Problem with nfs data caching?
Date: Wed, 25 Feb 2004 14:45:08 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1077745507.1064.5.camel@weaver.tuc.noao.edu>
References: <403D158B.124C2469@mainframe.ca>
Reply-To: swampler@noao.edu
Mime-Version: 1.0
Content-Type: text/plain
Cc: Linux NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Aw6ra-0001jy-2K
	for nfs@lists.sourceforge.net; Wed, 25 Feb 2004 13:46:42 -0800
Received: from noao.edu ([140.252.1.54])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1Aw6cs-0001Uw-NR
	for nfs@lists.sourceforge.net; Wed, 25 Feb 2004 13:31:30 -0800
To: Terry Bates <tbates@mainframe.ca>
In-Reply-To: <403D158B.124C2469@mainframe.ca>
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

On Wed, 2004-02-25 at 14:37, Terry Bates wrote:
> We are experiencing a problem which seems to be related to data caching
> on our linux nfs clients;
> 
> Using Mental Ray, we render picture to an NFS mounted filesystem (I have
> tried both SGI and Auspex file servers).  We have an inhouse application
> which we use to view the rendered pictures.  If you attempt to view a
> picture which has not completely finished rendering, you get a plain
> grey window.  Once that situation has happened, you cannot view that
> picture from that machine until you umount and mount that filesystem
> again.  You can view it from other machines however.
> 
> Most of our machines are running RedHat 7.2 with a 2.4.7-10 kernel and
> nfs-utils-0.3.1-13.

I wonder if this is the same problem we see?  What does 'dmesg'
on that client show when this happens.  If it reports:

   NFS: Buggy server - nlink == 0!
   __nfs_fhget: iget failed

(or something similar), then it's probably the same problem.
If so, I haven't seen a solution posted yet...

-- 
Steve Wampler -- swampler@noao.edu
The gods that smiled on your birth are now laughing out loud.


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

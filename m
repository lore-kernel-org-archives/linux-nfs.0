From: <Taousif_Ansari-G5Y5guI6XLZWk0Htik3J/w@public.gmane.org>
Subject: RE: Performance Issue with multiple dataserver
Date: Thu, 19 May 2011 19:39:23 +0530
Message-ID: <A1A98FD909DC5248811A65C5D18E9C761DF69B247B@BLRX7MCDC202.AMER.DELL.COM>
References: <4DD2A084.1040905@moving-picture.com>
 <20110518080106.1159c5b8@notabene.brown>
 <4DD39D39.7010805@moving-picture.com>
 <A1A98FD909DC5248811A65C5D18E9C761DF69B1F18@BLRX7MCDC202.AMER.DELL.COM>
 <20110518161239.GA16835@fieldses.org>
 <A1A98FD909DC5248811A65C5D18E9C761DF69B2188@BLRX7MCDC202.AMER.DELL.COM>
 <20110519115018.GA31978@fieldses.org>
 <A1A98FD909DC5248811A65C5D18E9C761DF69B2432@BLRX7MCDC202.AMER.DELL.COM>
 <20110519131236.GA32648@fieldses.org>
 <A1A98FD909DC5248811A65C5D18E9C761DF69B244C@BLRX7MCDC202.AMER.DELL.COM>
 <20110519134356.GB32648@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <linux-nfs@vger.kernel.org>
To: <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ausxipps301.us.dell.com ([143.166.148.223]:34785 "EHLO
	ausxipps301.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933215Ab1ESOJ3 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 May 2011 10:09:29 -0400
In-Reply-To: <20110519134356.GB32648@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Can you please elaborate GFS2-setup a bit more...

-----Original Message-----
From: J. Bruce Fields [mailto:bfields@fieldses.org] 
Sent: Thursday, May 19, 2011 7:14 PM
To: Ansari, Taousif - Dell Team
Cc: linux-nfs@vger.kernel.org
Subject: Re: Performance Issue with multiple dataserver

On Thu, May 19, 2011 at 06:44:59PM +0530, Taousif_Ansari-G5Y5guI6XLZWk0Htik3J/w@public.gmane.org wrote:
> Then what should I follow, and what details are needed....

There isn't really any supported server-side pNFS.

The closest is the GFS2-based code, for which you need to install
Benny's latest tree, configure a shared block device, create a GFS2
filesystem on it, mount it across all DS's and the MDS, and export it
from all of them--but I don't believe anyone has written step-by-step
instructions for that.

--b.

> 
> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of J. Bruce Fields
> Sent: Thursday, May 19, 2011 6:43 PM
> To: Ansari, Taousif - Dell Team
> Cc: linux-nfs@vger.kernel.org
> Subject: Re: Performance Issue with multiple dataserver
> 
> On Thu, May 19, 2011 at 06:09:21PM +0530, Taousif_Ansari-G5Y5guI6XLZWk0Htik3J/w@public.gmane.org wrote:
> > I have followed the way given on http://wiki.linux-nfs.org/wiki/index.php/Configuring_pNFS/spnfsd .
> 
> Oh.  As noted there, spnfs is unmaintained.
> 
> And, in any case, we'd need many more details about your setup.
> 
> --b.
> 
> > 
> > -Taousif
> > 
> > -----Original Message-----
> > From: J. Bruce Fields [mailto:bfields@fieldses.org] 
> > Sent: Thursday, May 19, 2011 5:20 PM
> > To: Ansari, Taousif - Dell Team
> > Cc: linux-nfs@vger.kernel.org
> > Subject: Re: Performance Issue with multiple dataserver
> > 
> > On Thu, May 19, 2011 at 10:56:44AM +0530, Taousif_Ansari-G5Y5guI6XLZWk0Htik3J/w@public.gmane.org wrote:
> > > Hi,
> > > 
> > > I am using on Server linux-pnfs-2.6.38(linux-pnfs-ae7441f.tar) and on client also linux-pnfs-2.6.38(linux-pnfs-ae7441f.tar) downloaded from http://git.linux-nfs.org/?p=bhalevy/linux-pnfs.git;a=summary on Fedora 14.
> > 
> > So you're using GFS2 on the server?  With what sort of storage?
> > 
> > --b.
> > 
> > > 
> > > Extremely sorry for causing confusing .
> > > -----Original Message-----
> > > From: J. Bruce Fields [mailto:bfields@fieldses.org] 
> > > Sent: Wednesday, May 18, 2011 9:43 PM
> > > To: Ansari, Taousif - Dell Team
> > > Cc: linux-nfs@vger.kernel.org
> > > Subject: Re: Performance Issue with multiple dataserver
> > > 
> > > You sent this message as a reply to an unrelated message, which is
> > > confusing to those of us with threaded mail readers.
> > > 
> > > On Wed, May 18, 2011 at 05:24:45PM +0530, Taousif_Ansari-G5Y5guI6XLZWk0Htik3J/w@public.gmane.org wrote:
> > > > I have done pNFS setup with single Dataserver and Two Dataserver and ran the IOzone tool on both, I found that the performance with multiple dataservers is less than the performance with single dataservers.
> > > 
> > > What are you using as the server, and what as the client?
> > > 
> > > --b.
> > > 
> > > > 
> > > > Here are some numbers, which were captured by the IOzone tool.
> > > > 
> > > > 
> > > > 							  4	  8	 16	 32	 64	 128	 256	 512	1024	<== Record Length in KB
> > > > With Single Dataserver:
> > > > Read operation for file size 1 MB-		66415	66359	63630	70358	86223	70256	66047	66068	68489	<== IO kB/sec
> > > > Write operation for file size 1 MB-		18827	16920	18846	17039	18896	17009	17173	19206	17947	<== IO kB/sec
> > > > 
> > > > With Two Dataservers :
> > > > Read operation for file size 1 MB-		36882	381198	38150	38084	38749	33663	34398	37313	37847	<== IO kB/sec
> > > > Write operation for file size 1 MB-		5461	4661	5586	4870	5227	4922	4214	5572	4658	<== IO kB/sec
> > > > 
> > > > 
> > > > Can somebody tell me What could be the issue....
> > > > --
> > > > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > > > the body of a message to majordomo@vger.kernel.org
> > > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

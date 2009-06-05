Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:56803 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751478AbZFENDO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Jun 2009 09:03:14 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n55D1JgS018102
	for <linux-nfs@vger.kernel.org>; Fri, 5 Jun 2009 07:01:19 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n55D3Gf6153740
	for <linux-nfs@vger.kernel.org>; Fri, 5 Jun 2009 07:03:16 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n55D3EpV016437
	for <linux-nfs@vger.kernel.org>; Fri, 5 Jun 2009 07:03:16 -0600
In-Reply-To: <1244205998.5410.25.camel@heimdal.trondhjem.org>
References: <OF3EBF546E.60A83A8F-ON852575A8.006EBB38-852575A8.006EFDE6@us.ibm.com>	 <1243615595.7155.48.camel@heimdal.trondhjem.org>
	 <OF0EEDB635.561D17D4-ON852575C5.005CBABA-852575C5.005FAD0D@us.ibm.com>	 <1243618500.7155.56.camel@heimdal.trondhjem.org>
	 <ac442c870905291722x1ec811b2sda997d464898fcda@mail.gmail.com>	 <1243686363.5209.16.camel@heimdal.trondhjem.org>
	 <ac442c870905300602v6950ec42y5195d2d6ea7dd4c@mail.gmail.com>	 <BA67D2A4-1752-4789-ADB9-D1B3C6D197F6@oracle.com>
	 <1243963631.4868.124.camel@heimdal.trondhjem.org>	 <18982.41770.293636.786518@fisica.ufpr.br>
	 <1244049027.5603.5.camel@heimdal.trondhjem.org>	 <OFB53BFCCB.0CEC7A7E-ON852575C
 <1244138698.5203.59.camel@heimdal.trondhjem.org>	 <OF37FCED66.33F08949-ON852575CB
 <1244205998.5410.25.camel@heimdal.trondhjem.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: Greg Banks <gnb@fmeh.org>, linux-nfs@vger.kernel.org,
        Neil Brown <neilb@suse.de>, Steve Dickson <SteveD@redhat.com>
Subject: Re: Link performance over NFS degraded in RHEL5. -- was : Read/Write NFS I/O
 performance degraded by FLUSH_STABLE page flushing
From: Brian R Cowan <brcowan@us.ibm.com>
Message-ID: <OFD00F6B6E.D5317464-ON852575CC.00472CC3-852575CC.0047B4D7@us.ibm.com>
Date: Fri, 5 Jun 2009 09:03:13 -0400
Content-Type: text/plain; charset="US-ASCII"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Personally, I would leave the default export options alone. Simply because 
they more or less match the defaults for the other NFS servers. 

Also, there may be negative impacts of changing the default export option 
to no_wdelay on really busy servers. One possible result is that more CPU 
time gets spent waiting on writes to disk. 

I'm a bit paranoid when it comes to tuning *server* settings, since they 
impact all clients all at once, where client tuning generally only impacts 
the one client.

=================================================================
Brian Cowan
Advisory Software Engineer
ClearCase Customer Advocacy Group (CAG)
Rational Software
IBM Software Group
81 Hartwell Ave
Lexington, MA
 
Phone: 1.781.372.3580
Web: http://www.ibm.com/software/rational/support/
 

Please be sure to update your PMR using ESR at 
http://www-306.ibm.com/software/support/probsub.html or cc all 
correspondence to sw_support@us.ibm.com to be sure your PMR is updated in 
case I am not available.



From:
Trond Myklebust <trond.myklebust@fys.uio.no>
To:
Steve Dickson <SteveD@redhat.com>
Cc:
Neil Brown <neilb@suse.de>, Greg Banks <gnb@fmeh.org>, Brian R 
Cowan/Cupertino/IBM@IBMUS, linux-nfs@vger.kernel.org
Date:
06/05/2009 08:48 AM
Subject:
Re: Link performance over NFS degraded in RHEL5. -- was : Read/Write NFS 
I/O performance degraded by FLUSH_STABLE page flushing



On Fri, 2009-06-05 at 07:35 -0400, Steve Dickson wrote:
> Brian R Cowan wrote:
> > Trond Myklebust <trond.myklebust@fys.uio.no> wrote on 06/04/2009 
02:04:58 
> > PM:
> > 
> >> Did you try turning off write gathering on the server (i.e. add the
> >> 'no_wdelay' export option)? As I said earlier, that forces a delay of
> >> 10ms per RPC call, which might explain the FILE_SYNC slowness.
> > 
> > Just tried it, this seems to be a very useful workaround as well. The 
> > FILE_SYNC write calls come back in about the same amount of time as 
the 
> > write+commit pairs... Speeds up building regardless of the network 
> > filesystem (ClearCase MVFS or straight NFS).
> 
> Does anybody had the history as to why 'no_wdelay' is an 
> export default? As Brian mentioned later in this thread
> it only helps Linux servers, but that's good thing, IMHO. ;-)
> 
> So I would have no problem changing the default export
> options in nfs-utils, but it would be nice to know why 
> it was there in the first place...

It dates back to the days when most Linux clients in use in the field
were NFSv2 only. After all, it has only been 15 years...

  Trond




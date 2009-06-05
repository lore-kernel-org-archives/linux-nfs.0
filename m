Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:60944 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751988AbZFEN4g (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Jun 2009 09:56:36 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n55DpoKE017145
	for <linux-nfs@vger.kernel.org>; Fri, 5 Jun 2009 09:51:50 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n55Dua0A182764
	for <linux-nfs@vger.kernel.org>; Fri, 5 Jun 2009 09:56:36 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n55DuZHY030819
	for <linux-nfs@vger.kernel.org>; Fri, 5 Jun 2009 09:56:35 -0400
In-Reply-To: <4A2902E6.2080006@RedHat.com>
References: <OF3EBF546E.60A83A8F-ON852575A8.006EBB38-852575A8.006EFDE6@us.ibm.com>	 <1243615595.7155.48.camel@heimdal.trondhjem.org>
	 <OF0EEDB635.561D17D4-ON852575C5.005CBABA-852575C5.005FAD0D@us.ibm.com>	 <1243618500.7155.56.camel@heimdal.trondhjem.org>
	 <ac442c870905291722x1ec811b2sda997d464898fcda@mail.gmail.com>	 <1243686363.5209.16.camel@heimdal.trondhjem.org>
	 <ac442c870905300602v6950ec42y5195d2d6ea7dd4c@mail.gmail.com>	 <BA67D2A4-1752-4789-ADB9-D1B3C6D197F6@oracle.com>
	 <1243963631.4868.124.camel@heimdal.trondhjem.org>	 <18982.41770.293636.786518@fisica.ufpr.br>
	 <1244049027.5603.5.camel@heimdal.trondhjem.org>	 <OFB53BFCCB.0CEC7A7E-ON852575C
 <1244138698.5203.59.camel@heimdal.trondhjem.org> <OF37FCED66.33F08949-ON852575CB. <4A2902E6.2080006@RedHat.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: Greg Banks <gnb@fmeh.org>, linux-nfs@vger.kernel.org,
        Neil Brown <neilb@suse.de>
Subject: Re: Link performance over NFS degraded in RHEL5. -- was : Read/Write NFS I/O
 performance degraded by FLUSH_STABLE page flushing
From: Brian R Cowan <brcowan@us.ibm.com>
Message-ID: <OF4FF73096.4AB6C016-ON852575CC.00401943-852575CC.004C96EC@us.ibm.com>
Date: Fri, 5 Jun 2009 09:56:33 -0400
Content-Type: text/plain; charset="US-ASCII"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Actually wdelay is the export default, and I recall the man page saying 
something along the lines of doing this to allow the server to coalesce 
writes. Somewhere else (I think in another part of this thread) it's 
mentioned that the server will sit for up to 10ms waiting for other writes 
to this export. The reality is that wdelay+FILE_SYNC = up to a 10ms delay 
waiting for the write RPC to come back. That being said, I would rather 
leave this alone so that we don't accidentally impact something else. 
After all, the no_wdelay export option will work around it nicely in an 
all-Linux environment, and file pages don't flush with FILE_SYNC on 
2.6.29.

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
Steve Dickson <SteveD@redhat.com>
To:
Neil Brown <neilb@suse.de>, Greg Banks <gnb@fmeh.org>
Cc:
Brian R Cowan/Cupertino/IBM@IBMUS, linux-nfs@vger.kernel.org
Date:
06/05/2009 07:38 AM
Subject:
Re: Link performance over NFS degraded in RHEL5. -- was : Read/Write NFS 
I/O performance degraded by FLUSH_STABLE page flushing



Brian R Cowan wrote:
> Trond Myklebust <trond.myklebust@fys.uio.no> wrote on 06/04/2009 
02:04:58 
> PM:
> 
>> Did you try turning off write gathering on the server (i.e. add the
>> 'no_wdelay' export option)? As I said earlier, that forces a delay of
>> 10ms per RPC call, which might explain the FILE_SYNC slowness.
> 
> Just tried it, this seems to be a very useful workaround as well. The 
> FILE_SYNC write calls come back in about the same amount of time as the 
> write+commit pairs... Speeds up building regardless of the network 
> filesystem (ClearCase MVFS or straight NFS).

Does anybody had the history as to why 'no_wdelay' is an 
export default? As Brian mentioned later in this thread
it only helps Linux servers, but that's good thing, IMHO. ;-)

So I would have no problem changing the default export
options in nfs-utils, but it would be nice to know why 
it was there in the first place...

Neil, Greg?? 

steved.



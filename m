Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:50861 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751308AbZFDVtF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Jun 2009 17:49:05 -0400
References: <OF3EBF546E.60A83A8F-ON852575A8.006EBB38-852575A8.006EFDE6@us.ibm.com>	 <1243615595.7155.48.camel@heimdal.trondhjem.org> <OF0EEDB635.561D17D4-ON852575C5.005CBABA-852575C5.005FAD0D@us.ibm.com>	 <1243618500.7155.56.camel@heimdal.trondhjem.org> <ac442c870905291722x1ec811b2sda997d464898fcda@mail.gmail.com>	 <1243686363.5209.16.camel@heimdal.trondhjem.org> <ac442c870905300602v6950ec42y5195d2d6ea7dd4c@mail.gmail.com>	 <BA67D2A4-1752-4789-ADB9-D1B3C6D197F6@oracle.com> <1243963631.4868.124.camel@heimdal.trondhjem.org>	 <18982.41770.293636.786518@fisica.ufpr.br> <1244049027.5603.5.camel@heimdal.trondhjem.org>	 <OFB53BFCCB.0CEC7A7E-ON852575C <1244138698.5203.59.camel@heimdal.trondhjem.org>	 <OF37FCED66.33F08949-ON852575CB <1244149042.5203.108.camel@heimdal.trondhjem.org> <OFA43D111A.982879F6-ON852575CB.0073FBF9-852575CB.007622CD@us.ibm.com>
Message-Id: <2E6FA271-39F6-4FE7-9642-B5F3CCF60045@fys.uio.no>
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Brian R Cowan <brcowan@us.ibm.com>
In-Reply-To: <OFA43D111A.982879F6-ON852575CB.0073FBF9-852575CB.007622CD@us.ibm.com>
Content-Type: text/plain;
	charset=us-ascii;
	format=flowed;
	delsp=yes
Subject: Re: Link performance over NFS degraded in RHEL5. -- was : Read/Write NFS I/O performance degraded by FLUSH_STABLE page flushing
Date: Thu, 4 Jun 2009 17:48:56 -0400
Cc: Carlos Carvalho <carlos@fisica.ufpr.br>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-nfs-owner@vger.kernel.org" <linux-nfs-owner@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Well, that's a good reason to get rid of those Solaris servers. :-)

Seriously, though, we do _not_ fix server bugs by changing the client.  
If we had been doing something that was incorrect, or not recommended  
by the NFS spec, then matters would be different...

Trond

On Jun 4, 2009, at 17:30, Brian R Cowan <brcowan@us.ibm.com> wrote:

> I'll have to see if/how this impacts the flush behavior. I don't  
> THINK we
> are doing getattrs in the middle of the link, but the trace  
> information
> kind of went astray when the VM's gor reverted to base OS.
>
> Also, your recommended workaround of setting no_wdelay only works if  
> the
> NFS server is Linux, the option isn't available on Solaris or HP-UX.  
> This
> limits it's usefulness in heterogenous environments. Solaris 10  
> doesn't
> support async NFS exports, and we've already discussed how the small- 
> write
> optimization overrides write behavior on async mounts.
>
> =================================================================
> Brian Cowan
> Advisory Software Engineer
> ClearCase Customer Advocacy Group (CAG)
> Rational Software
> IBM Software Group
> 81 Hartwell Ave
> Lexington, MA
>
> Phone: 1.781.372.3580
> Web: http://www.ibm.com/software/rational/support/
>
>
> Please be sure to update your PMR using ESR at
> http://www-306.ibm.com/software/support/probsub.html or cc all
> correspondence to sw_support@us.ibm.com to be sure your PMR is  
> updated in
> case I am not available.
>
>
>
> From:
> Trond Myklebust <trond.myklebust@fys.uio.no>
> To:
> Brian R Cowan/Cupertino/IBM@IBMUS
> Cc:
> Carlos Carvalho <carlos@fisica.ufpr.br>, linux-nfs@vger.kernel.org,
> linux-nfs-owner@vger.kernel.org
> Date:
> 06/04/2009 04:57 PM
> Subject:
> Re: Link performance over NFS degraded in RHEL5. -- was : Read/Write  
> NFS
> I/O performance degraded by FLUSH_STABLE page flushing
>
>
>
> On Thu, 2009-06-04 at 16:43 -0400, Brian R Cowan wrote:
>> What I'm trying to understand is why RHEL 4 is not flushing anywhere
> near
>> as often. Either RHEL4 erred on the side of not writing, and RHEL5 is
>> erring on the opposite side, or RHEL5 is doing unnecessary flushes...
> I've
>> seen that 2.6.29 flushes less than the Red hat 2.6.18-derived  
>> kernels,
> but
>> it still flushes a lot more than RHEL 4 does.
>
> Most of that increase is probably mainly due to the changes to the way
> stat() works. More precisely, it would be due to this patch:
>
>
> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git&a=commitdiff&h=70b9ecbdb9c5fdc731f8780bffd45d9519020c4a
>
>
> which went into Linux 2.6.16 in order to fix a posix compatibility
> issue.
>
> Trond
>
>
>

From: Andrew Morton <akpm@digeo.com>
Subject: Re: [PATCH] zerocopy NFS for 2.5.36
Date: Wed, 18 Sep 2002 20:30:52 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3D8944EC.D129579D@digeo.com>
References: <20020918.160057.17194839.davem@redhat.com> <1032393277.24895.8.camel@irongate.swansea.linux.org.uk> <3D89176B.40FFD09B@digeo.com> <20020919021333.GC20500@vitelus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from packet.digeo.com ([12.110.80.53])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17rs1s-0000G9-00
	for <nfs@lists.sourceforge.net>; Wed, 18 Sep 2002 20:31:00 -0700
Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id UAA16228
	for <nfs@lists.sourceforge.net>; Wed, 18 Sep 2002 20:30:52 -0700 (PDT)
To: Aaron Lehmann <aaronl@vitelus.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

Aaron Lehmann wrote:
> 
> > akpm:/usr/src/cptimer> ./cptimer -d -s
> > nbytes=10240  from_align=0, to_align=0
> >     copy_32: copied 19.1 Mbytes in 0.078 seconds at 243.9 Mbytes/sec
> > __copy_duff: copied 19.1 Mbytes in 0.090 seconds at 211.1 Mbytes/sec
> 
> It's disappointing that this program doesn't seem to support
> benchmarking of MMX copy loops (like the ones in arch/i386/lib/mmx.c).
> Those seem to be the more interesting memcpy functions on modern
> systems.

Well the source is there, and the licensing terms are most reasonable.

But then, the source was there eighteen months ago and nothing happened.
Sigh.

I think in-kernel MMX has fatal drawbacks anyway.  Not sure what
they are - I prefer to pretend that x86 CPUs execute raw C.


-------------------------------------------------------
This SF.NET email is sponsored by: AMD - Your access to the experts
on Hammer Technology! Open Source & Linux Developers, register now
for the AMD Developer Symposium. Code: EX8664
http://www.developwithamd.com/developerlab
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

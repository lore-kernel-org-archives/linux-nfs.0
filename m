From: Matt C <wago@phlinux.com>
Subject: Re: Problems getting started with booting via NFS
Date: Wed, 27 Aug 2003 10:08:27 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0308271007400.30372-100000@fubar.phlinux.com>
References: <6.0.0.10.0.20030827134940.0264cde0@helmholtz.hia.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19s3n0-00026C-00
	for <nfs@lists.sourceforge.net>; Wed, 27 Aug 2003 10:08:58 -0700
Received: from fubar.phlinux.com ([216.254.54.154])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 19s3n0-0000cF-C1
	for nfs@lists.sourceforge.net; Wed, 27 Aug 2003 10:08:58 -0700
To: Lars Meinecke <meinecke@hia.rwth-aachen.de>
In-Reply-To: <6.0.0.10.0.20030827134940.0264cde0@helmholtz.hia.rwth-aachen.de>
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hi Lars-

Have you read nfsroot.txt in the Documentation directory of the kernel 
source? That's a really good first step.

-mc

On Wed, 27 Aug 2003, Lars Meinecke wrote:

> 
> 
> Hello,
> 
> I'm quite new to Linux in general, so may be one or the other question may 
> sound quite simple to you. Nevertheless:
> 
> My situation:
> I have a Workstation with static IP runnning RedHat 9.0. This is the NFS 
> Server.
> Secondly I have a singele-chip PC with a flash ROM running RedBoot which 
> then loads the Linux Busybox system if not interrupted. This is the client 
> system.
> 
> What I want to do:
> I'd like to have the client system booting via NFS from the server system, 
> so that I can develop software and perhaps alter the operating system for 
> the single-chip PC on the server system and thus reducing time for development.
> 
> What I'm searching for:
> ... is something like a step-by-step instruction set on how to reach the 
> above mentioned system configuration.
> I already read through a lot of how-to's and books, but still I find 
> setting up the system quite complicated... - may be I worked to long with M$...
> 
> Any help would be greatly appreciated.
> 
> tia
> Lars 
> 
> 
> 
> 
> -------------------------------------------------------
> This sf.net email is sponsored by:ThinkGeek
> Welcome to geek heaven.
> http://thinkgeek.com/sf
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> 



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: James Pearson <james-p@moving-picture.com>
Subject: Re: Problems with hard links in root NFS filesystem
Date: Thu, 01 Aug 2002 12:51:22 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3D4920BA.6685567E@moving-picture.com>
References: <F418066D6DFA5040A1169F0B39B7604A0DE23D@rg273.reliance.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mpc-26.sohonet.co.uk ([193.203.82.251] helo=moving-picture.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17aEUP-0000wY-00
	for <nfs@lists.sourceforge.net>; Thu, 01 Aug 2002 04:51:33 -0700
To: Donald Burns <DMB@reliance.co.uk>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

What options are you using to export the file systems from the server?

Are you using 'no_subtree_check' ?

Using no_subtree_check fixed a similar problem I had - see: 

http://marc.theaimsgroup.com/?l=linux-nfs&m=101309591431249&w=2

James Pearson

Donald Burns wrote:
> 
> 
> Dear list members,
> 
> I have a problem using NFS.
> 
> Synopsis:       Files that are hard linked on the server's root
>                 NFS images for a Beowulf cluster become inaccesable
>                 either imediately or after a few hours.
> 
> Boot example:   From the server's logs (server is rg272) :-
> 
>                 July 30 10:05:45 rg272 kernel: nfsd Security: sbin/init bad
> export.
>                 July 30 10:05:46 rg272 kernel: nfsd Security: sbin/bash bad
> export.
> 
>                 The client boot-up hangs at this point.
> 
> After time example: From the server's logs (as I remember it):-
> 
>                 July 30 11:34:02 rg272 kernel: nfsd Security:
> lib/libc6.x.x.so bad export.
> 
> Client example: From the command line:-
> 
>                 cat /etc/inittab
>                 cat: standard output: Stale NFS file handle
> 
> Other symptoms:
> 
>                 When booting the cluster each machine must be booted
>                 on its own. Booting the machines in parallel fills the
>                 servers logs with "bad export" messages.
> 
>                 Problem exists irrespective of NFS protocol
>                 used (V2 or V3)
> 
>                 Cycling the power on the server clears the problem
>                 temporarily but restarting the NFS service does not.
> 
> System Details:
> 
>                 Software:- Linux RedHat 7.3 on server and clients
>                 (kernel 2.4.18)
>                 Server:- Dell GX530 dual processor precision work
>                 station.
>                 Clients:- Dell GX260 single processor work station.
> 
> Progress in solving the problem to date:
> 
>                 By trawling the web I found one Gunnar Raetch who
>                 experianced almost identical problems using kernel
>                 2.4.14. He fixed the problem by applying the
>                 following kernel patches:-
> 
>                 http://www.cse.unsw.edu.au/~neilb/patches/linux/2.4.14-pre4/
> 
>                 patch-D-NfsdOpsPrepare
>                 patch-E-NfsdOps
>                 patch-F-ReiserfsNfsdOps
> 
>                 I am unable patch my 2.4.18 kernel with these patches.
>                 I also tried down grading to kernel 2.4.14, successfully
>                 applied the patches & compiled, but the USB support
>                 in 2.4.14 would not allow me use of my mouse and keyboard
>                 (Oh Sh*t!).
> 
> I hope this provides sufficient info to resolve the problem.
> 
> Many thanks in advance for your anticipated kind help.
> 
> Best Regards,
> 
> Donald.
> 
> Reliance Gear Company Ltd.
> Rowley Mills
> Penistone Road
> Lepton
> Huddersfield
> England
> HD8 0LE
> 
> Tel: +44 1484 601000
> fax: +44 1484 601001
> 
> http://www.reliance.co.uk
> 
> THE INFORMATION IN THIS COMMUNICATION IS CONFIDENTIAL AND INTENDED ONLY FOR
> THE USE OF THE ADDRESSEE.  DISCLOSURE, USE  OR COPYING OF THIS MESSAGE OR
> ITS CONTENTS OTHER THAN BY THE ADDRESSEE IS PROHIBITED. IF YOU RECEIVE THIS
> COMMUNICATION IN ERROR WE WOULD BE GRATEFUL IF YOU WOULD NOTIFY US
> IMMEDIATELY AND DELETE ANY MATERIAL RECEIVED
> 
> -------------------------------------------------------
> This sf.net email is sponsored by:ThinkGeek
> Welcome to geek heaven.
> http://thinkgeek.com/sf
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

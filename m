From: miyoshi@hpc.bs1.fc.nec.co.jp
Subject: Re: NFS client stall within __lock_page()
Date: Fri, 10 Jan 2003 17:12:36 +0900
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030110171236A.miyoshi@hpc.bs1.fc.nec.co.jp>
References: <20030110151929Z.miyoshi@hpc.bs1.fc.nec.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: tanaka-h@mxm.nes.nec.co.jp
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tyo201.gate.nec.co.jp ([210.143.35.51])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18WuFz-0002aX-00
	for <nfs@lists.sourceforge.net>; Fri, 10 Jan 2003 00:11:12 -0800
Received: from mailgate4.nec.co.jp ([10.7.69.197])
	by TYO201.gate.nec.co.jp (8.11.6/3.7W01080315) with ESMTP id h0A8B4w28860
	for <nfs@lists.sourceforge.net>; Fri, 10 Jan 2003 17:11:04 +0900 (JST)
Received: from mailsv4.nec.co.jp (mailgate51.nec.co.jp [10.7.69.196]) by mailgate4.nec.co.jp (8.11.6/3.7W-MAILGATE-NEC) with ESMTP
	id h0A8B3804576 for <nfs@lists.sourceforge.net>; Fri, 10 Jan 2003 17:11:03 +0900 (JST)
Received: from mailsv.bs1.fc.nec.co.jp (venus.d2.bs1.fc.nec.co.jp [10.34.77.164]) by mailsv4.nec.co.jp (8.11.6/3.7W-MAILSV4-NEC) with ESMTP
	id h0A8B2H26085 for <nfs@lists.sourceforge.net>; Fri, 10 Jan 2003 17:11:02 +0900 (JST)
To: nfs@lists.sourceforge.net
In-Reply-To: <20030110151929Z.miyoshi@hpc.bs1.fc.nec.co.jp>
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


Hi, all.

> I am using kernel 2.4.17 as an NFS client (server is HP-UX)
> and one of client processes hangs and never wakes up.
> 
> From kdb backtrace (attached), I found that the client process
> stalls within nfs write and never returns (kill -9 is not accepted.)
> It sleeps on __lock_page.

I want to add one thing.

I saw the following message after the program started,
but I am not sure the accurate time and date of the stall.
In addition, it appears frequently (a few times in a day?) and
it seems to have no relation with the problem.

    Dec 26 17:41:19 client kernel: nfs_notify_change: revalidate failed, error=-116

Regards,
--
MIYOSHI Kazuto <miyoshi@hpc.bs1.fc.nec.co.jp>
 HPC Operating System Group, 1st Computers Software Division,
 Computers Software Operations Unit, NEC Solutions.


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

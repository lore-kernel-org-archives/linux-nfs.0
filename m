From: Knut Petersen <Knut_Petersen@t-online.de>
Subject: Re: [BUG] nfs version 2 broken
Date: Wed, 01 Feb 2006 08:13:37 +0100
Message-ID: <43E05FA1.6070407@t-online.de>
References: <43E05031.2000107@t-online.de>	 <1138774519.7861.4.camel@lade.trondhjem.org>  <43E0567F.20004@t-online.de> <1138775744.7875.0.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: linux-kernel@vger.kernel.org, neilb@cse.unsw.edu.au,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1F4CCP-0003yR-99
	for nfs@lists.sourceforge.net; Tue, 31 Jan 2006 23:14:41 -0800
Received: from mailout07.sul.t-online.com ([194.25.134.83])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1F4CCN-0001H2-OK
	for nfs@lists.sourceforge.net; Tue, 31 Jan 2006 23:14:41 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1138775744.7875.0.camel@lade.trondhjem.org>
Sender: nfs-admin@lists.sourceforge.net
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


>>AOpen i915GMm-HFS with Pentium M, linux kernel 2.6.15-git7
>>running a system that startet as SuSE 9.2. Nfs-utils are still
>>the original 1.0.6, grep -i nfs linuxbuild/.config gives
>>    
>>
>
>...and what kind of filesystem are you exporting?
>
>  
>

I think it is _not_ related to reiserfs. Moving my
exported /tftpboot directory to a fresh ext2 partition
gave the same results - failing with nfs 2, succeeding with
nfs 3.

cu,
Knut



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

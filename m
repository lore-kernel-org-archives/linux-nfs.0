From: Adrian Phillips <a.phillips@met.no>
Subject: Re: number of files per directory under ext3 & directory indexing
Date: 18 Feb 2003 07:16:18 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <87bs1a15cd.fsf@freeze.oslo.dnmi.no>
References: <20030218022449.85354.qmail@web12202.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from smtp1.oslo.dnmi.no ([128.39.62.241])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18l13L-0007Ng-00
	for <nfs@lists.sourceforge.net>; Mon, 17 Feb 2003 22:16:27 -0800
Received: from uucp by freeze.oslo.dnmi.no with spam-scanned (Exim 3.35 #1)
	id 18l13C-0003S8-00
	for nfs@lists.sourceforge.net; Tue, 18 Feb 2003 06:16:18 +0000
Received: from tandem by freeze.oslo.dnmi.no with local (Exim 3.35 #1)
	id 18l13C-0003S5-00
	for nfs@lists.sourceforge.net; Tue, 18 Feb 2003 06:16:18 +0000
To: nfs@lists.sourceforge.net
In-Reply-To: <20030218022449.85354.qmail@web12202.mail.yahoo.com>
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

>>>>> "Alan" == Alan Powell <lakerfaniam2@yahoo.com> writes:

    Alan> Can you share your experiences of when performance starts
    Alan> dropping dramatically based on the number of files in a
    Alan> directory under ext3? (assuming that you haven't applied any
    Alan> directory indexing patch)

This may be obvious, but I presume you have considered another file
system ? It would seem testing with XFS and reiserfs would be
advisable at least. Certainly my experiences with reiserfs and several
thousand files per directory over NFS have been only good,

Sincerely,

Adrian Phillips

-- 
Your mouse has moved.
Windows NT must be restarted for the change to take effect.
Reboot now?  [OK]


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

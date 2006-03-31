From: Chuck Lever <cel@citi.umich.edu>
Subject: Re: NFS directio
Date: Fri, 31 Mar 2006 09:35:34 -0500
Message-ID: <12E368A4-2262-4EBF-8769-581DB3500A36@citi.umich.edu>
References: <20060330151544.GA11915@suse.de> <1143734612.8093.8.camel@lade.trondhjem.org> <20060331074900.GC32461@suse.de>
Mime-Version: 1.0 (Apple Message framework v746.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FPKjC-0006pw-Db
	for nfs@lists.sourceforge.net; Fri, 31 Mar 2006 06:35:54 -0800
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FPKj9-0003Pm-Md
	for nfs@lists.sourceforge.net; Fri, 31 Mar 2006 06:35:54 -0800
In-Reply-To: <20060331074900.GC32461@suse.de>
To: Olaf Kirch <okir@suse.de>
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


On Mar 31, 2006, at 2:49 AM, Olaf Kirch wrote:

> On Thu, Mar 30, 2006 at 11:03:32AM -0500, Trond Myklebust wrote:
>> MAX_DIRECTIO_SIZE is gone from Linus' tree. I don't think we have any
>> limits on the size of the buffer that users can feed to us apart from
>> those set by mm/filemap.c:generic_write_checks().
>
> So you're saying we can safely remove this check in 2.6.16?

the check isn't in 2.6.16.  it was removed sometime after 2.6.5.

-- 
corporate:   < cel at netapp dot com >
personal:    < chucklever at bigfoot dot com >





-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

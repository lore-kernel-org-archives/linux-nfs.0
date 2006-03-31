From: Chuck Lever <cel@citi.umich.edu>
Subject: Re: NFS directio
Date: Fri, 31 Mar 2006 10:50:26 -0500
Message-ID: <442D4FC2.7060109@citi.umich.edu>
References: <20060330151544.GA11915@suse.de> <1143734612.8093.8.camel@lade.trondhjem.org> <20060331074900.GC32461@suse.de> <12E368A4-2262-4EBF-8769-581DB3500A36@citi.umich.edu> <20060331145849.GF18629@suse.de>
Reply-To: cel@citi.umich.edu
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FPLtY-00072Q-HR
	for nfs@lists.sourceforge.net; Fri, 31 Mar 2006 07:50:40 -0800
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FPLtX-0006Xs-Dd
	for nfs@lists.sourceforge.net; Fri, 31 Mar 2006 07:50:40 -0800
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20060331145849.GF18629@suse.de>
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

Olaf Kirch wrote:
> On Fri, Mar 31, 2006 at 09:35:34AM -0500, Chuck Lever wrote:
>> the check isn't in 2.6.16.  it was removed sometime after 2.6.5.
> 
> It is still in the 2.6.16 tree I'm looking at; else I wouldn't ask :)

it's been in my trees since 2.6.13 or even earlier, my mistake.

that change is part of the aio+dio patches that were just included in 
2.6.17-rc1.  instead of creating a single patch for this change, you 
should consider taking those patches, since they were tested as a unit.

if you can guarantee that atomic_t is 32-bits on every platform you 
support, then it should be save to change that #define to 2^31. 
otherwise, the work to eliminate the limit entirely has already been 
done by the above-mentioned patches.

-- 
corporate:	<cel at netapp dot com>
personal:	<chucklever at bigfoot dot com>


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

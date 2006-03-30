From: Chuck Lever <cel@citi.umich.edu>
Subject: Re: NFS directio
Date: Thu, 30 Mar 2006 12:27:27 -0500
Message-ID: <442C14FF.3080901@citi.umich.edu>
References: <20060330151544.GA11915@suse.de> <1143734612.8093.8.camel@lade.trondhjem.org>
Reply-To: cel@citi.umich.edu
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FP0vo-0003Lm-NK
	for nfs@lists.sourceforge.net; Thu, 30 Mar 2006 09:27:36 -0800
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FP0vm-0005bu-S1
	for nfs@lists.sourceforge.net; Thu, 30 Mar 2006 09:27:36 -0800
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <1143734612.8093.8.camel@lade.trondhjem.org>
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

Trond Myklebust wrote:
> On Thu, 2006-03-30 at 17:15 +0200, Olaf Kirch wrote:
>> In recent kernels, NFS direct IO limits the size of a request to
>> 4096 pages, ie 16M on most platforms. This causes growisofs from the
>> dvd+rw-tools package (http://fy.chalmers.se/~appro/linux/DVD+RW/) to fail.
>> Its builtin "dd" style function uses 32M buffers by default.
>>
>> It puzzled me a lot that it is returning -EFBIG, which means "file too
>> big". At least that should be EINVAL, I think. EFBIG should be reserved
>> for problems related to largefile support, IMO.
>>
>> We can easily work around the problem by restricting the buffer size
>> growisofs uses on NFS, but that feels strange. I think the right way
>> would be to increase MAX_DIRECTIO_SIZE, and if someone submits a bigger
>> request, to loop and do that in MAX_DIRECTIO_SIZE chunks.
>>
>> Comments?
> 
> MAX_DIRECTIO_SIZE is gone from Linus' tree. I don't think we have any
> limits on the size of the buffer that users can feed to us apart from
> those set by mm/filemap.c:generic_write_checks().

that's correct.  this was just an arbitrary limit to prevent type 
overflows (namely the atomic_t's were only 24 bits on some platforms).

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

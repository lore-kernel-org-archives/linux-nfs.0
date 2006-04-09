From: Chuck Lever <cel@citi.umich.edu>
Subject: Re: NFS directio
Date: Sun, 09 Apr 2006 18:09:27 -0400
Message-ID: <44398617.2000208@citi.umich.edu>
References: <20060330151544.GA11915@suse.de>	<1143734612.8093.8.camel@lade.trondhjem.org>	<20060331074900.GC32461@suse.de>	<12E368A4-2262-4EBF-8769-581DB3500A36@citi.umich.edu>	<20060331145849.GF18629@suse.de>	<442D4FC2.7060109@citi.umich.edu> <17465.67.550070.247218@cse.unsw.edu.au>
Reply-To: cel@citi.umich.edu
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Olaf Kirch <okir@suse.de>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FSi64-0000k3-Md
	for nfs@lists.sourceforge.net; Sun, 09 Apr 2006 15:09:28 -0700
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FSi63-0006yu-8N
	for nfs@lists.sourceforge.net; Sun, 09 Apr 2006 15:09:28 -0700
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17465.67.550070.247218@cse.unsw.edu.au>
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

Neil Brown wrote:
> On Friday March 31, cel@citi.umich.edu wrote:
>> Olaf Kirch wrote:
>>> On Fri, Mar 31, 2006 at 09:35:34AM -0500, Chuck Lever wrote:
>>>> the check isn't in 2.6.16.  it was removed sometime after 2.6.5.
>>> It is still in the 2.6.16 tree I'm looking at; else I wouldn't ask :)
>> it's been in my trees since 2.6.13 or even earlier, my mistake.
>>
>> that change is part of the aio+dio patches that were just included in 
>> 2.6.17-rc1.  instead of creating a single patch for this change, you 
>> should consider taking those patches, since they were tested as a unit.
>>
>> if you can guarantee that atomic_t is 32-bits on every platform you 
>> support, then it should be save to change that #define to 2^31. 
>> otherwise, the work to eliminate the limit entirely has already been 
>> done by the above-mentioned patches.
> 
> (Coming into the conversation a bit late....)
> 
> What about the kmalloc in nfs_get_user_pages:
> 
> 	array_size = (page_count * sizeof(struct page *));
> 	*pages = kmalloc(array_size, GFP_KERNEL);
> 
> With a page_count of 1024, this allocates one page (on 32bit) which is
> easy.
> With a page_count of 4096 (the previous MAX_DIRECTIO_SIZE)), this
> allocates 4 consecutive pages, which won't always succeed.
> 
> If you want to go higher than that (which was the point of the start
> of this thread) then you need a large-order allocation which doesn't
> (in my understanding) have a good chance of success due to
> fragmentation.
> 
> So I guess my question is: how hard would it be to use a more scalable
> data structure so that very large IO sizes would be reliably
> practical?

howdy neil-

usually I/O is broken up into smaller chunks by the time it gets down to 
this level, so it's never been much of an issue.  it's pretty 
challenging to generate a test case for extremely large I/O sizes (for 
example, the size of the entire process address space).

and until now, there really hasn't been much call for doing NFS O_DIRECT 
with very large requests.  it's been a matter of meeting the 
requirements of database I/O, which is generally 4KB to 16KB for data 
files, and about a megabyte for log writes.

at this point we don't really have a test case and a use case that 
reliably breaks this, so it hasn't been a priority to address this.

the structure of this code was adapted (ie stolen) from other parts of 
the kernel that also employ get_user_pages.  you can probably take a 
look at other places that employ get_user_pages(), and see how they've 
since tackled the issue.

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

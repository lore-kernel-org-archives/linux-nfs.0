From: James Pearson <james-p@moving-picture.com>
Subject: Re: File system cache corruptions?
Date: Thu, 07 Oct 2004 09:57:54 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <41650512.1050309@moving-picture.com>
References: <4164201A.8020005@moving-picture.com> <1097084729.5245.44.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CFU7m-0002nt-FZ
	for nfs@lists.sourceforge.net; Thu, 07 Oct 2004 01:59:46 -0700
Received: from externalmx-1.sourceforge.net ([12.152.184.25])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CFU6Y-0000sz-DX
	for nfs@lists.sourceforge.net; Thu, 07 Oct 2004 01:59:46 -0700
Received: from mpc-26.sohonet.co.uk ([193.203.82.251] helo=moving-picture.com)
	by externalmx-1.sourceforge.net with esmtp (Exim 4.41)
	id 1CFU6U-00039o-Ng
	for nfs@lists.sourceforge.net; Thu, 07 Oct 2004 01:58:27 -0700
Received: from minion.mpc.local ([172.16.11.112] helo=moving-picture.com)
	by moving-picture.com with esmtp (Exim 4.24)
	id 1CFU5y-00019C-7a
	for nfs@lists.sourceforge.net; Thu, 07 Oct 2004 09:57:54 +0100
To: nfs@lists.sourceforge.net
In-Reply-To: <1097084729.5245.44.camel@lade.trondhjem.org>
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
> På on , 06/10/2004 klokka 18:40, skreiv James Pearson:
> 
> 
>>Any ideas on what may be causing this?
> 
> 
> Shared mmapped files tend not to be easy to keep consistent w.r.t. the
> server, because mmap pins the pages in memory.
> 
> Instead of copying data into the mmapped file, it is better to create a
> new file, then rename it onto the old one (like tools such as GNU
> install do for you).

This is true (and something I do as a matter of course if I ever have to 
replace/upgrade shared libraries/binaries etc), but not the case here - 
the executable and its required shared libraries which are on the NFS 
server have been in place and not changed for about 6 months.

There are over 100 clients using the exact same binary and shared 
libraries - only one had this problem.

The server is hard mounted.

Thanks

James Pearson




-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

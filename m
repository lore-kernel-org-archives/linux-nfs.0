From: Peter Staubach <staubach@redhat.com>
Subject: Re: strange caching behavior
Date: Fri, 08 Jul 2005 16:34:17 -0400
Message-ID: <42CEE349.6050204@redhat.com>
References: <3C7A1801D550F14B96C2EB6D2C8B989B0835143B@seaex01.180solutions.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DqzYT-0004bu-Hw
	for nfs@lists.sourceforge.net; Fri, 08 Jul 2005 13:34:37 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.44)
	id 1DqzYT-0007Fc-0K
	for nfs@lists.sourceforge.net; Fri, 08 Jul 2005 13:34:37 -0700
To: Mark Steele <mark@zango.com>
In-Reply-To: <3C7A1801D550F14B96C2EB6D2C8B989B0835143B@seaex01.180solutions.com>
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

Mark Steele wrote:

>Hi Peter,
>
>The opcode cache is working as expected. It detects the changes
>in the php scripts and recompiles the new files into memory.
>
>Therefore it sees the change in the modification time of the files.
>
>I am using rsync to update the files on the server from a code 
>repository.
>
>I don't see how either of things things affect the behavior of the
>NFS.
>
>Using more caching/less bandwidth when 'freshly' mounted 
>without any file updates 
>
>VS. 
>
>Using lots of bandwidth when files are changed on the NFS server
>(which is done infrequently)
>

My thinking that was the NFS client typically does not do things on its
own, but does so based on application activity.  For a large enough
working set, the more applications request from the file system, the
more traffic that there will be over the wire.

What does the increased traffic look like?  Is it metadata style operations
such as GETATTR or LOOKUP or is it data movement like READ?  What is the
typical working set size, in bytes and numbers of files, of these scripts?

    Thanx...

       ps


-------------------------------------------------------
This SF.Net email is sponsored by the 'Do More With Dual!' webinar happening
July 14 at 8am PDT/11am EDT. We invite you to explore the latest in dual
core and dual graphics technology at this free one hour event hosted by HP, 
AMD, and NVIDIA.  To register visit http://www.hp.com/go/dualwebinar
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

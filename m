From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH nfsd] ignore chmod calls on symlinks
Date: Mon, 11 Jul 2005 09:05:58 -0400
Message-ID: <42D26EB6.3090301@redhat.com>
References: <20050711110635.GM27163@suse.de> <42D26A3F.7030703@redhat.com> <20050711125918.GT27163@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Dry0C-0001EE-5k
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 06:07:16 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.44)
	id 1Drxzh-00038Q-N8
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 06:07:16 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20050711125918.GT27163@suse.de>
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

>On Mon, Jul 11, 2005 at 08:46:55AM -0400, Peter Staubach wrote:
>  
>
>>>I submitted this before - this is a somewhat cosmetic fix to
>>>keep the SpecFS validation test from complaining.
>>>
>>>      
>>>
>>It seems to me that this test could/should considered to be broken and 
>>hence,
>>fixed, as opposed to cluttering up file system dependent code with checks
>>like this that the upper layers are responsible for catching.
>>    
>>
>
>An NFS client is allowed to send a chmod on a symlink. It just happens
>to be an illegal operation on most file systems.
>

So, the nfsd layer is not doing what the vfs layer on the system is already
for callers into the file systems?

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

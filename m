From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Re: Debian, SIGPIPE, "libnfsidmap", and init.d vs. umount
Date: Mon, 06 Dec 2004 14:39:35 -0500
Message-ID: <41B4B577.3000009@RedHat.com>
References: <20041204221504.GD6146@perlsupport.com> <16819.43303.95619.661063@cse.unsw.edu.au> <20041206020506.GJ6146@perlsupport.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Neil Brown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CbOff-0000Kp-Is
	for nfs@lists.sourceforge.net; Mon, 06 Dec 2004 11:37:19 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CbOfb-0007G8-Rq
	for nfs@lists.sourceforge.net; Mon, 06 Dec 2004 11:37:18 -0800
To: Chip Salzenberg <chip@pobox.com>
In-Reply-To: <20041206020506.GJ6146@perlsupport.com>
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

Chip Salzenberg wrote:

>According to Neil Brown:
>  
>
>>On Saturday December 4, chip@pobox.com wrote:
>>    
>>
>>>Debian needs a bugfix release of nfs-utils, because of the SIGPIPE
>>>bug.  This being my job, I figured I could grab the HEAD version of
>>>nfs-utils.  And since the Debian sarge release is coming up soon (no,
>>>really), I hoped I'd find something unlikely to crash; instead I'm
>>>having difficulty with the build.
>>>      
>>>
>>I use "./configure --disable-nfsv4 --disable-gss"  but you might not
>>want to...
>>    
>>
>
>Well, that could work, actually.  Do you think that the changes since
>March 24 -- other than GSS and NFSv4 -- are valuable and safe?
>  
>
Well I'm running the code with everything enabled and turned on,
for a while now....  things seem to be stable... but only time will 
tell... ;-)

steved.



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Neil Horman <nhorman@redhat.com>
Subject: Re: possible client stale filehandle bug?
Date: Wed, 16 Feb 2005 16:23:14 -0500
Message-ID: <4213B9C2.2040709@redhat.com>
References: <482A3FA0050D21419C269D13989C61130853976D@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Garrick Staples <garrick@usc.edu>, nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D1Wdg-0003xJ-Dh
	for nfs@lists.sourceforge.net; Wed, 16 Feb 2005 13:23:16 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1D1Wdf-00058x-Ri
	for nfs@lists.sourceforge.net; Wed, 16 Feb 2005 13:23:16 -0800
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C61130853976D@lavender-fe.eng.netapp.com>
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

Lever, Charles wrote:
> hi neil-
> 
> 
>>>>It seems that the Solaris clients never report any such 
>>
>>errors, only the Linux
>>
>>>>clients.  However, watching 'snoop' on the Solaris NFS 
>>
>>server, I see that it IS
>>
>>>>returning stale file handles to both OSes, but Solaris 
>>
>>clients seem to retry
>>
>>>>the request several times; and the Linux clients 
>>
>>immediately pass the error up
>>
>>>>to the application.
>>>>
>>>>Is there some condition that the 2.4 kernel is handling incorrectly?
>>>
>>>
>>>I do not believe that Solaris redrives ESTALE on read, but 
>>
>>they may do
>>
>>>it on open(). Linux does not redrive either case. See the many
>>>discussions in the NFS list archives for why.
>>>
>>
>>Solaris does in fact retry on operations on ESTALE errors, 
>>definately on 
>>open, and I think on read/readdir/stat/etc. as well.  We had some 
>>discussion about tht here recently.
> 
> 
> as far as i know Solaris doesn't redrive on read or write, but only
> during pathname resolution.  redriving a read or write will only work in
> the case where the server has taken the export offline temporarily; if
> the file handle really is bad, then redriving a read or write is
> probably safe, but won't accomplish anything.
> 
> i have a patch that adds support for pathname resolution retry to 2.6
> (now in Trond's NFS_ALL for 2.6.11-rc4) and a pair of patches that
> implement this for RHEL 3.0 that i've sent to steve and al viro for
> review.

I agree, it probably doesn't re-drive on any operation that doesn't walk 
a path, which is in line with what RHEL is doing currently.  I didn't 
mean to imply that solaris retired ESTALE in all occurances of the 
event.  Anywho, Can you point me to your patches?  I'd be interested to 
know how you managed to implement retry on ESTALE without leaking into 
the VFS, which I think you will recall was the big sticking point that 
we were debating here.

Thanks! :)
Neil

-- 
/***************************************************
  *Neil Horman
  *Software Engineer
  *Red Hat, Inc.
  *nhorman@redhat.com
  *gpg keyid: 1024D / 0x92A74FA1
  *http://pgp.mit.edu
  ***************************************************/


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Peter Staubach <staubach@redhat.com>
Subject: Re: Performance: NFS v3  mounting with 'noac' option
Date: Thu, 08 Mar 2007 11:13:24 -0500
Message-ID: <45F03624.1000207@redhat.com>
References: <121929.1837.qm@web56610.mail.re3.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: AK <amithl_prem@yahoo.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HPLFD-0003I0-54
	for nfs@lists.sourceforge.net; Thu, 08 Mar 2007 08:13:31 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HPLFC-00018e-N9
	for nfs@lists.sourceforge.net; Thu, 08 Mar 2007 08:13:32 -0800
In-Reply-To: <121929.1837.qm@web56610.mail.re3.yahoo.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

AK wrote:
> --- Peter Staubach <staubach@redhat.com> wrote:
>
>   
>>>>>       
>>>>>           
>>>> What about this application requires that the
>>>>         
>> "noac"
>>     
>>>> option be used?
>>>>     
>>>>         
>>>   application is romio with mpich2 ...
>>>       
>> Sorry, I'm not familiar with those.  What about
>> either one of those
>> require "noac" semantics?
>>     
>
> "To use ROMIO on NFS, file locking with fcntl must
> work correctly on the NFS installation. On some
> installations, fcntl locks don't work. To get them to
> work, you need to use Version 3 of NFS, ensure that
> the lockd daemon is running on all the machines, and
> have the system administrator mount the NFS file
> system with the "noac" option (no attribute caching).
> Turning off attribute caching may reduce performance,
> but it is necessary for correct behavior."

I think that I would assume that fcntl style locking works on all current
implementations, that this is not NFS version dependent, and also that
"noac" is not required in combination with the locking in order to get
correct behavior.

       ps

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

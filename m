From: Peter Staubach <staubach@redhat.com>
Subject: Re: Performance: NFS v3  mounting with 'noac' option
Date: Wed, 07 Mar 2007 17:39:28 -0500
Message-ID: <45EF3F20.5060300@redhat.com>
References: <141076.2067.qm@web56606.mail.re3.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: AK <amithl_prem@yahoo.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HP4nG-0006zf-7C
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 14:39:34 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HP4nI-0005hJ-3t
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 14:39:36 -0800
In-Reply-To: <141076.2067.qm@web56606.mail.re3.yahoo.com>
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
>>> We have multiple file systems begin mounted from
>>>       
>> the
>>     
>>> same NFS server. One of our user's application
>>> requires to mount the file system with 'noac'
>>>       
>> option. 
>>     
>>>   
>>>       
>> What about this application requires that the "noac"
>> option be used?
>>     
>   application is romio with mpich2 ...
>  
>   

Sorry, I'm not familiar with those.  What about either one of those
require "noac" semantics?

>> One of the impacts of using the "noac" option is
>> much more network
>> traffic and it will be composed of small packets. 
>> If the server is
>> busy handling all of the additional GETATTR
>> requests, then it won't
>> be handling other requests.  The client will also be
>> a bit busier
>> with generating the additional requests, instead of
>> just doing what
>> might be considered more useful work.
>>
>> So, there should be no direct impact to other
>> mounted file systems.
>> However, there may be indirect impacts.
>>     
>
> indirect impacts: can you please elaborate on this.

I thought that I did.  :-)

If the system is busy handling the "noac" aspects of one file system,
then it isn't doing something else on one of the other file systems.
System resources are limited and using up more of them for one thing
leaves less for others.

       ps

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: James Pearson <james-p@moving-picture.com>
Subject: Re: How to know whether a given directory in in NFS
Date: Thu, 02 Dec 2004 12:22:25 +0000
Message-ID: <41AF0901.30907@moving-picture.com>
References: <20041202121530.16871.qmail@web60307.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CZpyh-00024t-UV
	for nfs@lists.sourceforge.net; Thu, 02 Dec 2004 04:22:31 -0800
Received: from mpc-26.sohonet.co.uk ([193.203.82.251] helo=moving-picture.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CZpyd-0001dr-SP
	for nfs@lists.sourceforge.net; Thu, 02 Dec 2004 04:22:31 -0800
To: Raghu Ram Murthy <me_rams@yahoo.com>
In-Reply-To: <20041202121530.16871.qmail@web60307.mail.yahoo.com>
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

You can use the statfs system call (on Linux) - see a similar thread at 
http://marc.theaimsgroup.com/?t=108784378500006&r=1&w=2

There is probably a statfs Perl module.

James Pearson

Raghu Ram Murthy wrote:
> How with mount.
> 
> for example, /home directory is in NFS and /tmp is not
> in NFS and I don't know whether /home is in NFS or
> not?
> 
> Then how can I find?
> -Raghuram
> --- Vincent Roqueta <vincent.roqueta@ext.bull.net>
> wrote:
> 
> 
>>Le jeudi 2 Décembre 2004 11:45, Raghu Ram Murthy a
>>écrit :
>>
>>>Hi,
>>>
>>>I want to know (from perl), whether a given
>>
>>directory
>>
>>>is in part of NFS. Are there any Unix commands to
>>
>>find
>>
>>>it out or any indirect methods?
>>
>>mount ?
>>
>>
>>
> 
> -------------------------------------------------------
> 
>>SF email is sponsored by - The IT Product Guide
>>Read honest & candid reviews on hundreds of IT
>>Products from real users.
>>Discover which products truly live up to the hype.
>>Start reading now.
>>http://productguide.itmanagersjournal.com/
>>_______________________________________________
>>NFS maillist  -  NFS@lists.sourceforge.net
>>https://lists.sourceforge.net/lists/listinfo/nfs
>>
> 
> 
> 
> =====
> ----------------------------------------------
> P.Raghu Ram Murthy, M-tech (Computer Science),
> Member, Information Technology,
> D E Shaw India Software Private Limited,
> 6-3-879 & 879/B
> Begumpet, Hyderabad 500 016
> Andhra Pradesh
> India
> 
> Mobile: (+91) 98852 17928
> ----------------------------------------------
> 
> If it doesn't work, you're not hitting it with a big enough hammer
> 
> __________________________________________________
> Do You Yahoo!?
> Tired of spam?  Yahoo! Mail has the best spam protection around 
> http://mail.yahoo.com 
> 
> 
> -------------------------------------------------------
> SF email is sponsored by - The IT Product Guide
> Read honest & candid reviews on hundreds of IT Products from real users.
> Discover which products truly live up to the hype. Start reading now. 
> http://productguide.itmanagersjournal.com/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> 



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

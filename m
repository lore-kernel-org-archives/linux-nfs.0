From: "Jeffrey B. Layton" <laytonjb@bellsouth.net>
Subject: Re: network storage solutions
Date: Thu, 15 May 2003 18:12:37 +0000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3EC3D895.2050008@bellsouth.net>
References: <3EC2A740.9060902@cert.ucr.edu> <Pine.LNX.3.96.1030514135224.2430H-100000@Maggie.Linux-Consulting.com> <20030515070359.GB1912@greglaptop.attbi.com> <3EC3ECC6.6000802@cert.ucr.edu> <3EC40815.9040504@lanl.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Josip Loncaric <josip@lanl.gov>,  nfs@lists.sourceforge.net,
 Charles.Lever@netapp.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail146.mail.bellsouth.net ([205.152.58.106] helo=imf60bis.bellsouth.net)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19GQt9-00032b-00
	for <nfs@lists.sourceforge.net>; Thu, 15 May 2003 15:07:47 -0700
To: beowulf@beowulf.org
In-Reply-To: <3EC40815.9040504@lanl.gov>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Josip Loncaric wrote:

> Glen Kaukola wrote:
>
>> Greg Lindahl wrote:
>>
>>> There are soft and hard mounts, and there are interruptable mounts
>>> ("intr" -- check out "man nfs").
>>>
>>> A hard mount will never time out. If you make it interruptable, then
>>> the user can choose to ^C. This is the safe option.
>>>  
>>>
>>
>> You know, I thought that's how it was supposed to work too.  I do use 
>> the intr option, but even with that option, when a nfs drive is down, 
>> and something like a df command gets stuck, hitting ctrl-c doesn't 
>> seem to do a thing.  All I can ever do is just kill my xterm or 
>> whatever.  
>
>
> We've had similar problems while I was at ICASE.  "Hard" mounts would 
> lock up client processes (even unmount) when the NFS server went down, 
> but "soft" mounts were "too soft" for some of our users.  A reasonable 
> solution is to "harden" your soft mounts by insisting on longer major 
> timeouts, as in "retrans=15" (the default is 3). 


I still think this is dangerous. With soft mounts you can
still get silent data corruption despite the longer timeouts.
Chuck, do you agree?

Jeff

>
>
> Sincerely,
> Josip
>
> P.S.  Our NFS servers virtually never went down, except due to 
> hardware problems or service, so indefinite retransmissions were 
> highly undesirable.
>




-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

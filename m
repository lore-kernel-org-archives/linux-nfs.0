From: Steve Dickson <SteveD@RedHat.com>
Subject: Re: [PATCH] Timeouts gone wild on ia64
Date: Wed, 14 May 2003 20:34:28 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3EC2E094.4070804@RedHat.com>
References: <3EBBA1FA.3090301@RedHat.com> <shsbryauczr.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from host-64-179-20-100.man.choiceone.net ([64.179.20.100] helo=Odyssey.Home.4Dicksons.Org)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19G6ei-0004fn-00
	for <nfs@lists.sourceforge.net>; Wed, 14 May 2003 17:31:32 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>, nfs@lists.sourceforge.net
In-Reply-To: <shsbryauczr.fsf@charged.uio.no>
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

Hi Trond,

Trond Myklebust wrote:

>>>>>>" " == Steve Dickson <SteveD@RedHat.com> writes:
>>>>>>            
>>>>>>
>
>     > What this patch does is make the minimal Round Trip time value
>     > relative to HZ. So When HZ is greater (as in the case of ia64)
>     > the minimal value goes up.
>     >  Comments?
>
>1/30 of a second is a long time. Why that particular choice?
>
>Note: "It works" won't cut ice as that is completely a function of the
>choice of hardware.
>
I realize this but... I figured waiting a few extra ticks of time before 
timing
out was probably a good thing with respect to soft mounts to slow 
servers...
Especially  since EIO errors can be pretty disruptive...

And as I see, its a no-op with a fast (or slow) client  talking to a fast
server because the timeout will should never happen... (i.e. the waiting
thread will get the response before the time out occurs)....

SteveD.





-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

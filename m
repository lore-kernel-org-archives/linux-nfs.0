From: James Pearson <james-p@moving-picture.com>
Subject: Re: mtab and procs not in sync?
Date: Wed, 09 Jun 2004 11:28:37 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <40C6E655.8070802@moving-picture.com>
References: <482A3FA0050D21419C269D13989C61130435E229@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BY0K9-00026Z-K9
	for nfs@lists.sourceforge.net; Wed, 09 Jun 2004 03:28:49 -0700
Received: from mpc-26.sohonet.co.uk ([193.203.82.251] helo=moving-picture.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BY0K8-0006eR-NM
	for nfs@lists.sourceforge.net; Wed, 09 Jun 2004 03:28:48 -0700
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C61130435E229@lavender-fe.eng.netapp.com>
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

Do you know how many 'a lot of mounts' is?

I believe there was a problem with /proc/mounts in 2.2 kernels (limited 
to one page) - is there still a limit in 2.4 or 2.6 kernels?

I currently symlink /proc/mounts to /etc/mtab on diskless machines to 
get round the issue that /etc/mtab can not trusted to be correct. I only 
have a maximum of a few 10's of mounts at any one time.

James Pearson

Lever, Charles wrote:
> if there are a lot of mounts on the system, then /proc/mounts can be
> truncated and not show all of them.
> 
> however, if there are more mounts in /proc/mounts than in /etc/mtab,
> there is probably a bug in mount.  not unheard of.
> 
> 
>>-----Original Message-----
>>From: Phy Prabab [mailto:phyprabab@yahoo.com] 
>>Sent: Tuesday, June 08, 2004 2:21 PM
>>To: nfs@lists.sourceforge.net
>>Subject: [NFS] mtab and procs not in sync?
>>
>>
>>Hello,
>>
>>Have run into a situation where mtab does not match
>>/proc/mounts in that mtab has numerous entries that
>>have expired off and removed, yet does not show that
>>it has been removed from mtab.  Is this known and is
>>there a fix?
>>
>>Kernel 2.4.21 and 23
>>nfs-utils 1.06
>>automount 4.1.2
>>
>>Thanks!
>>Phy
>>
>>
>>	
>>		
>>__________________________________
>>Do you Yahoo!?
>>Friends.  Fun.  Try the all-new Yahoo! Messenger.
>>http://messenger.yahoo.com/ 
>>
>>
>>-------------------------------------------------------
>>This SF.Net email is sponsored by: GNOME Foundation
>>Hackers Unite!  GUADEC: The world's #1 Open Source Desktop Event.
>>GNOME Users and Developers European Conference, 28-30th June in Norway
>>http://2004/guadec.org
>>_______________________________________________
>>NFS maillist  -  NFS@lists.sourceforge.net
>>https://lists.sourceforge.net/lists/listinfo/nfs
>>
> 
> 
> 
> -------------------------------------------------------
> This SF.Net email is sponsored by: GNOME Foundation
> Hackers Unite!  GUADEC: The world's #1 Open Source Desktop Event.
> GNOME Users and Developers European Conference, 28-30th June in Norway
> http://2004/guadec.org
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> 



-------------------------------------------------------
This SF.Net email is sponsored by: GNOME Foundation
Hackers Unite!  GUADEC: The world's #1 Open Source Desktop Event.
GNOME Users and Developers European Conference, 28-30th June in Norway
http://2004/guadec.org
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

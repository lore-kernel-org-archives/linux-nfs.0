From: James Pearson <james-p@moving-picture.com>
Subject: Re: mtab and procs not in sync?
Date: Wed, 09 Jun 2004 22:20:46 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <40C77F2E.5040401@moving-picture.com>
References: <482A3FA0050D21419C269D13989C61130435E236@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BYAUz-0007AN-Oj
	for nfs@lists.sourceforge.net; Wed, 09 Jun 2004 14:20:41 -0700
Received: from mpc-26.sohonet.co.uk ([193.203.82.251] helo=moving-picture.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BYAUv-0002Bn-6u
	for nfs@lists.sourceforge.net; Wed, 09 Jun 2004 14:20:37 -0700
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C61130435E236@lavender-fe.eng.netapp.com>
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

It looks like seq_file for /proc/mounts was introduced with 2.4.19 ...

James Pearson

Lever, Charles wrote:
> i would guess that if seq_file is used, then /proc/mounts should be OK.
> 
> i was looking at a RHEL AS 2.1 system last week that used the single
> page I/O model for /proc/mounts, and it was definitely busted.
> 
> 
>>-----Original Message-----
>>From: James Pearson [mailto:james-p@moving-picture.com] 
>>Sent: Wednesday, June 09, 2004 11:05 AM
>>To: Lever, Charles
>>Cc: nfs@lists.sourceforge.net
>>Subject: Re: [NFS] mtab and procs not in sync?
>>
>>
>>On a 2.4.26 kernel on x86 I can get /proc/mounts to go over 
>>4K (over 8K 
>>with about 100 automounted file systems).
>>
>>Having a quick look through the kernel code I can see 
>>seq_file used in 
>>relation to proc_mounts_operations (fs/proc/base.c) - however 
>>as I don't 
>>pretend to understand the code, I can't say this is the case ...
>>
>>If 2.4.X does use seq_file, then is it safe to say 
>>/proc/mounts doesn't 
>>suffer from a truncation problem?
>>
>>James Pearson
>>
>>Lever, Charles wrote:
>>
>>>as far as i can tell, the 4KB limit is common to x86 on 2.2 and 2.4.
>>>2.6 has replaced the old /proc read method with seq_file, 
>>
>>so i believe
>>
>>>/proc/mounts on 2.6 kernels will not suffer from this problem.
>>>
>>>it's not a fixed number of mounts, because the length of 
>>
>>each line in
>>
>>>/proc/mounts depends on what mount options are in effect.  
>>
>>the limit is
>>
>>>the number of characters in the file.
>>>
>>>
>>>
>>>>-----Original Message-----
>>>>From: James Pearson [mailto:james-p@moving-picture.com] 
>>>>Sent: Wednesday, June 09, 2004 6:29 AM
>>>>To: Lever, Charles
>>>>Cc: nfs@lists.sourceforge.net
>>>>Subject: Re: [NFS] mtab and procs not in sync?
>>>>
>>>>
>>>>Do you know how many 'a lot of mounts' is?
>>>>
>>>>I believe there was a problem with /proc/mounts in 2.2 
>>>>kernels (limited 
>>>>to one page) - is there still a limit in 2.4 or 2.6 kernels?
>>>>
>>>>I currently symlink /proc/mounts to /etc/mtab on diskless 
>>
>>machines to 
>>
>>>>get round the issue that /etc/mtab can not trusted to be 
>>>>correct. I only 
>>>>have a maximum of a few 10's of mounts at any one time.
>>>>
>>>>James Pearson
>>>>
>>>>Lever, Charles wrote:
>>>>
>>>>
>>>>>if there are a lot of mounts on the system, then 
>>>>
>>>>/proc/mounts can be 
>>>>
>>>>
>>>>>truncated and not show all of them.
>>>>>
>>>>>however, if there are more mounts in /proc/mounts than in 
>>>>
>>>>/etc/mtab, 
>>>>
>>>>
>>>>>there is probably a bug in mount.  not unheard of.
>>>>>
>>>>>
>>>>>
>>>>>
>>>>>>-----Original Message-----
>>>>>>From: Phy Prabab [mailto:phyprabab@yahoo.com]
>>>>>>Sent: Tuesday, June 08, 2004 2:21 PM
>>>>>>To: nfs@lists.sourceforge.net
>>>>>>Subject: [NFS] mtab and procs not in sync?
>>>>>>
>>>>>>
>>>>>>Hello,
>>>>>>
>>>>>>Have run into a situation where mtab does not match 
>>
>>/proc/mounts in 
>>
>>>>>>that mtab has numerous entries that have expired off and 
>>>>
>>>>removed, yet 
>>>>
>>>>
>>>>>>does not show that it has been removed from mtab.  Is this 
>>>>
>>>>known and 
>>>>
>>>>
>>>>>>is there a fix?
>>>>>>
>>>>>>Kernel 2.4.21 and 23
>>>>>>nfs-utils 1.06
>>>>>>automount 4.1.2
>>>>>>
>>>>>>Thanks!
>>>>>>Phy
>>>>>>
>>>>>>
>>>>>>	
>>>>>>		
>>>>>>__________________________________
>>>>>>Do you Yahoo!?
>>>>>>Friends.  Fun.  Try the all-new Yahoo! Messenger. 
>>>>>>http://messenger.yahoo.com/
>>>>>>
>>>>>>
>>>>>>-------------------------------------------------------
>>>>>>This SF.Net email is sponsored by: GNOME Foundation
>>>>>>Hackers Unite!  GUADEC: The world's #1 Open Source Desktop Event. 
>>>>>>GNOME Users and Developers European Conference, 28-30th 
>>>>
>>>>June in Norway 
>>>>
>>>>
>>>>>>http://2004/guadec.org 
>>>>
>>>>_______________________________________________
>>>>
>>>>
>>>>>>NFS maillist  -  NFS@lists.sourceforge.net
>>>>>>https://lists.sourceforge.net/lists/listinfo/nfs
>>>>>>
>>>>>
>>>>>
>>>>>
>>>>>-------------------------------------------------------
>>>>>This SF.Net email is sponsored by: GNOME Foundation
>>>>>Hackers Unite!  GUADEC: The world's #1 Open Source Desktop Event. 
>>>>>GNOME Users and Developers European Conference, 28-30th 
>>>>
>>>>June in Norway 
>>>>
>>>>
>>>>>http://2004/guadec.org 
>>>>
>>>>_______________________________________________
>>>>
>>>>
>>>>>NFS maillist  -  NFS@lists.sourceforge.net
>>>>>https://lists.sourceforge.net/lists/listinfo/nfs
>>>>>
>>>>
>>>
>>
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
> 
> 



-------------------------------------------------------
This SF.Net email is sponsored by: GNOME Foundation
Hackers Unite!  GUADEC: The world's #1 Open Source Desktop Event.
GNOME Users and Developers European Conference, 28-30th June in Norway
http://2004/guadec.org
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

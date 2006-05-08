From: Steffen Kolbe <kolbe@vwi.tu-dresden.de>
Subject: Re: trace attached - Re: Folder in NFS-Share-Permission denied-but
 the user is group member
Date: Mon, 08 May 2006 14:33:21 +0200
Message-ID: <445F3A91.2030809@vwi.tu-dresden.de>
References: <445B30FD.9040103@vwi.tu-dresden.de>	<17499.15037.908665.125536@cse.unsw.edu.au>	<445F05BD.8010503@vwi.tu-dresden.de> <17503.11043.7670.762241@cse.unsw.edu.au>
Reply-To: kolbe@vwi.tu-dresden.de
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.94] (helo=sc8-sf-list2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FdEyT-0000aD-6C
	for nfs@lists.sourceforge.net; Mon, 08 May 2006 16:17:09 -0700
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fd4vc-0006pj-8t
	for nfs@lists.sourceforge.net; Mon, 08 May 2006 05:33:32 -0700
Received: from rks36.urz.tu-dresden.de ([141.30.66.166] helo=mailgate.urz.tu-dresden.de)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1Fd4vZ-0008Jr-RD
	for nfs@lists.sourceforge.net; Mon, 08 May 2006 05:33:32 -0700
Received: from [127.0.0.1] (helo=localhost)
	  by mailgate.urz.tu-dresden.de with esmtp (exim-4.51)
	  for <nfs@lists.sourceforge.net>
	  id 1Fd4vQ-00012W-NF; Mon, 08 May 2006 14:33:20 +0200
Received: from mailgate.urz.tu-dresden.de ([127.0.0.1])
 by localhost (rks36 [127.0.0.1]) (amavisd-new, port 10024) with ESMTP
 id 21671-181 for <nfs@lists.sourceforge.net>;
 Mon,  8 May 2006 14:33:19 +0200 (MEST)
Received: from [141.30.186.11] (helo=vwitme011.vwi.vkw.tu-dresden.de)
	  by mailgate.urz.tu-dresden.de with esmtp (exim-4.51)
	  for <nfs@lists.sourceforge.net>
	  id 1Fd4vP-00012O-T9; Mon, 08 May 2006 14:33:19 +0200
Received: from vwitme048.vwi.vkw.tu-dresden.de ([141.30.186.48])
	by vwitme011.vwi.vkw.tu-dresden.de with esmtp (Exim 4.52)
	id 1Fd4vH-0005kX-3M
	for nfs@lists.sourceforge.net; Mon, 08 May 2006 14:33:11 +0200
To: nfs@lists.sourceforge.net
In-Reply-To: <17503.11043.7670.762241@cse.unsw.edu.au>
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


@ Neil Brown: Thanks

Neil Brown wrote:

>On Monday May 8, kolbe@vwi.tu-dresden.de wrote:
>  
>
>>Hi Neil,
>>
>>I've reduced the groups massive. The test user is in 15 groups, an other 
>>test user is in 14 groups - same problem.
>>I've traced the traffic with ethereal, the captured traffic files are here:
>>
>>http://141.30.186.11/~kolbe/nfs   or    
>>http://vwitme011.vkw.tu-dresden.de/~kolbe/nfs
>>    
>>
>
>This trace shows requests coming from user with uid 10010, gid 10012 and
>Auxiliary gids: 20,21,24,25,29,30,44,46,100,110,10010,10011,10012,10014,10016,10017
>
>The accesses are for a file with uid 10021 and gid 10038 (not on this
>list).
>
>  
>
yes, the file/folder was written by user 10021 with sec. gid 10038  
(pri. gid 10012)
but the file (parent folder) is 2770, so members of gid 10038 should 
have access

the user who would access them has uid 10010 and primary gid 10012
but: the user (uid  10010) is also member of gid 10038 and should so 
have access (because 2770) - but haven't

>Maybe you need to log out and log back in again for the changes you
>made to take effect properly?
>  
>
done + restart nfs-server, same problem

>I use the 'groups' command to find out exactly what groups you are in
>at a given time.
>  
>
ooops, 'groups' shows also the system groups...

vwitme-staff dialout fax cdrom floppy audio dip video plugdev users 
scanner vwi-all vwitme-all vwitme-students vwitme-admins vwi-admins 
vwitme-projects vwitme-extern vwitme-projects-katastrophen vwi-staff 
vwitme-library vwitme-projects-lanechanging vwitme-projects-roadnetworks 
vwitme-studi vwitme-www

.....so the user is in 25 groups, hmmmmm...... but I've no real chance 
to reduce them. I think the system groups + ~30 network groups for some 
users is minimum I need.

>  
>
>>-----------------------------------------------------------
>>general question:
>>Is their a real solution to use ~50 groups with nfs? Because we've many 
>>project groups, some team leaders, many crossover memberships over some 
>>departments and .......
>>How is this solved in bigger environments?
>>    
>>
???? , any ideas ?

>>    
>>
>
>I'll be happy to answer this when you post it to the list :-)
>  
>
sorry, I've understand ;-)

>NeilBrown
>  
>
Thanks and regards
Steffen


-- 


Mit freundlichen Gruessen

Steffen Kolbe
Andreas-Schubert-Str. 23
D-01062 Dresden
------------------------------------------------------
Phone: +49/0 351 463-36750
Fax: +49/0 351 463-36809
e-mail: kolbe1@vwi.tu-dresden.de
------------------------------------------------------
Institut fuer Wirtschaft und Verkehr
Fakultaet Verkehrswissenschaften "Friedrich List"
Technische Universitaet Dresden
------------------------------------------------------ 



-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

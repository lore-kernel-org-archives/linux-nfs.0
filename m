From: Peter Staubach <staubach@redhat.com>
Subject: Re: "Permission Denied" when attempting mount command - Any
 help appreciated
Date: Tue, 21 Mar 2006 16:33:20 -0500
Message-ID: <44207120.3040400@redhat.com>
References: <FB2F81A7764D9244849441E9DC12702B01E06739@teak.vontu.corp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FLoTs-0006Kp-LR
	for nfs@lists.sourceforge.net; Tue, 21 Mar 2006 13:33:32 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FLoTs-0001AD-Ag
	for nfs@lists.sourceforge.net; Tue, 21 Mar 2006 13:33:32 -0800
To: "Brookes, John" <john.brookes@vontu.com>
In-Reply-To: <FB2F81A7764D9244849441E9DC12702B01E06739@teak.vontu.corp>
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

Brookes, John wrote:

> Hello,
> I am running redhat linux 4 enterprise version. (I'll be glad to send 
> more version info, but you'll have to tell me how to find it. :)
>
> The exports file on the server machine is:
>
> /usr/lib    *(async, all_squash)
> /root/try/   *(rw)
>
> I added the second line to exports and ran exportfs -ra afterwords.
>
> Running rpcinfo -p on the server box produces:
>
>    program vers proto   port
>     100000    2   tcp    111  portmapper
>     100000    2   udp    111  portmapper
>     100024    1   udp  32768  status
>     100024    1   tcp  32770  status
>     100011    1   udp    641  rquotad
>     100011    2   udp    641  rquotad
>     100011    1   tcp    644  rquotad
>     100011    2   tcp    644  rquotad
>     100003    2   udp   2049  nfs
>     100003    3   udp   2049  nfs
>     100003    4   udp   2049  nfs
>     100003    2   tcp   2049  nfs
>     100003    3   tcp   2049  nfs
>     100003    4   tcp   2049  nfs
>     100021    1   udp  34146  nlockmgr
>     100021    3   udp  34146  nlockmgr
>     100021    4   udp  34146  nlockmgr
>     100021    1   tcp  33275  nlockmgr
>     100021    3   tcp  33275  nlockmgr
>     100021    4   tcp  33275  nlockmgr
>     100005    1   udp    662  mountd
>     100005    1   tcp    665  mountd
>     100005    2   udp    662  mountd
>     100005    2   tcp    665  mountd
>     100005    3   udp    662  mountd
>     100005    3   tcp    665  mountd
>
> Running rpcinfo on the client:
>
>    program vers proto   port
>     100000    2   tcp    111  portmapper
>     100000    2   udp    111  portmapper
>     100024    1   udp  32768  status
>     100024    1   tcp  32769  status
>     100011    1   udp    779  rquotad
>     100011    2   udp    779  rquotad
>     100011    1   tcp    782  rquotad
>     100011    2   tcp    782  rquotad
>     100003    2   udp   2049  nfs
>     100003    3   udp   2049  nfs
>     100003    4   udp   2049  nfs
>     100003    2   tcp   2049  nfs
>     100003    3   tcp   2049  nfs
>     100003    4   tcp   2049  nfs
>     100021    1   udp  32771  nlockmgr
>     100021    3   udp  32771  nlockmgr
>     100021    4   udp  32771  nlockmgr
>     100021    1   tcp  33975  nlockmgr
>     100021    3   tcp  33975  nlockmgr
>     100021    4   tcp  33975  nlockmgr
>     100005    1   udp    800  mountd
>     100005    1   tcp    803  mountd
>     100005    2   udp    800  mountd
>     100005    2   tcp    803  mountd
>     100005    3   udp    800  mountd
>     100005    3   tcp    803  mountd
>
>
> The mount command and response:
>
> [root@redhat13 mnt]# mount -o intr,timeo=50 ds10.test.lab:root/try  
> mnt/jbrookes
> mount: ds10.test.lab:root/try failed, reason given by server: 
> Permission denied
>

Is it safe to assume that trying to mount "ds10.test.lab:/root/try"
instead of "ds10.test.lab:root/try" results in the same thing?

    Thanx...

       ps

> I am logged in as root on both machines. I have tried many different 
> combinations, but same negative result.
> Machine A (which is the server in this example) can successfully mount 
> the volumes on machine B when it is functioning as client, but not the 
> other way around. (as illustrated by the mount command above.)
>
> Anyone can offer me any clues into this puzzling problem?
>
> Thanks in advance,
>
> John Brookes
>
>



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

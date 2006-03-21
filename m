From: "Brookes, John" <john.brookes@vontu.com>
Subject: RE: "Permission Denied" when attempting mount command - Any help appreciated
Date: Tue, 21 Mar 2006 13:38:27 -0800
Message-ID: <FB2F81A7764D9244849441E9DC12702B01E0673A@teak.vontu.corp>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FLoZt-00078M-B8
	for nfs@lists.sourceforge.net; Tue, 21 Mar 2006 13:39:45 -0800
Received: from dsl081-249-146.sfo1.dsl.speakeasy.net ([64.81.249.146] helo=sentinal.vontu.corp)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FLoZs-0001pU-KB
	for nfs@lists.sourceforge.net; Tue, 21 Mar 2006 13:39:45 -0800
Received: from teak.vontu.corp (teak.vontu.corp [10.67.20.15])
	by sentinal.vontu.corp with ESMTP id k2LLcqgb003324
	for <nfs@lists.sourceforge.net>; Tue, 21 Mar 2006 13:38:52 -0800 (PST)
To: "Peter Staubach" <staubach@redhat.com>
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

Yes, a forward slash makes no difference. -John B
Thanks

-----Original Message-----
From: Peter Staubach [mailto:staubach@redhat.com]=20
Sent: Tuesday, March 21, 2006 1:33 PM
To: Brookes, John
Cc: nfs@lists.sourceforge.net
Subject: Re: [NFS] "Permission Denied" when attempting mount command -
Any help appreciated


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
> [root@redhat13 mnt]# mount -o intr,timeo=3D50 ds10.test.lab:root/try
> mnt/jbrookes
> mount: ds10.test.lab:root/try failed, reason given by server:=20
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

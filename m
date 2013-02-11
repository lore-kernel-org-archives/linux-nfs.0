Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ipo2-out.fzu.cz ([147.231.27.21]:12037 "EHLO ipo2-out.fzu.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759513Ab3BKUlG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Feb 2013 15:41:06 -0500
Message-ID: <5119572C.3080000@gmail.com>
Date: Mon, 11 Feb 2013 21:40:12 +0100
From: Jiri Horky <jiri.horky@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFSv4 server ignores local filesystem's POSIX ACL
References: <51190E62.5090304@gmail.com> <20130211182212.GB30117@fieldses.org> <4FA345DA4F4AE44899BD2B03EEEC2FA91F3C2047@sacexcmbx05-prd.hq.netapp.com> <20130211184936.GC30117@fieldses.org>
In-Reply-To: <20130211184936.GC30117@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all,
On 02/11/2013 07:49 PM, J. Bruce Fields wrote:
> On Mon, Feb 11, 2013 at 06:32:26PM +0000, Myklebust, Trond wrote:
>>> -----Original Message-----
>>> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
>>> owner@vger.kernel.org] On Behalf Of J. Bruce Fields
>>> Sent: Monday, February 11, 2013 1:22 PM
>>> To: Jiri Horky
>>> Cc: linux-nfs@vger.kernel.org
>>> Subject: Re: NFSv4 server ignores local filesystem's POSIX ACL
>>>
>>> On Mon, Feb 11, 2013 at 04:29:38PM +0100, Jiri Horky wrote:
>>>> Hi all,
>>>>
>>>> we use NFSv4 with Kerberos and a custom idmap mapping plugin. The
>>>> mapping is configured in a way that all principals that are not
>>>> explicitly defined are mapped to nobody/nogroup on a server.
>>>> Recently, the kerberos infrastructure within our organization expanded
>>>> by crossrealming with other parties which should not be allowed to use
>>>> our NFSv4 mounts.
>>>> It is my understanding that everybody who is able to authenticate
>>>> against the used kerberos infrastructure can mount the filesystems but
>>>> nonauthorized users will be mapped to user nobody/nogroup and
>>>> according to server's filesystem rights can do other actions. Now, I
>>>> would like to set deny ACL for user nobody to the server's /exports
>>>> directory to restrict nobody user access. But it seems this ACL is
>>>> ignored. In fact, local POSIX ACL's on any directory seems to
>>>> ignored:
>>>>
>>>> SERVER:
>>>> root@store4 /exports # mkdir local_tmp
>>>> root@store4 /exports # chmod 777 local_tmp/
>>>> root@store4 /exports # setfacl -m u:nobody:--- /exports/local_tmp/
>>>> root@store4 /exports # getfacl /exports/local_tmp/
>>>> getfacl: Removing leading '/' from absolute path names # file:
>>>> exports/local_tmp/ # owner: root # group: root user::rwx
>>>> user:nobody:---
>>>> group::rwx
>>>> mask::rwx
>>>> other::rwx
>>>> root@store4 /exports # su nobody -c "touch /exports/local_tmp/filelocal"
>>>> touch: cannot touch `/exports/local_tmp/filelocal': Permission denied
>>>>
>>>> so far so good, now on a client:
>>>>
>>>> CLIENT:
>>>> metex-1:~# mount -t nfs4 -o sec=krb5 store4.du1.cesnet.cz:/ /mnt
>>>> metex-1:~# touch /mnt/local_tmp/a metex-1:~# ls -l /mnt/local_tmp/a
>>>> -rw-r--r-- 1 nobody nogroup 0 Feb 11 15:23 /mnt/local_tmp/a
>>>>
>>>> and on the SERVER again:
>>>> root@store4 /exports # ls -l /exports/local_tmp/a
>>>> -rw-r--r-- 1 nobody nogroup 0 Feb 11 15:23 /exports/local_tmp/a
>>>>
>>>> So the ACL is ignored when accessing through NFS. Is it the expected
>>>> behavior and I am just doing something terribly wrong?
>>> That looks like a bug, but I'm at a loss to explain how it could have happened.
>>> A network trace (tcpdump -s0 -wtmp.pcap, then send me
>>> tmp.pcap) taken during the file creation above might be interesting.
>> If everyone is being squashed to user, nobody and the 'nobody' user owns the file, isn't that just expected behaviour? NFSv3 servers are always supposed to allow reads and writes from the owner, since the protocol itself has no stateful equivalent of open("foo", O_RDWR|O_CREAT, 0);
> Oops, I was assuming the second touch above was doing a create--based on
> the timestamps in the two ls's, you're right the second touch wasn't
> creating.
>
> So, agreed, this looks normal.
I am a bit lost here. The second  touch (the one from nfs client) 
actually was creating the file. What I wanted to show is that creating a 
file on the server itself failed with permission denied whereas through 
NFS, it worked just fine and created the file as user nobody on the 
server, which should not be possible as nobody user should not be able 
to enter the directory. Are you pointing to the fact that on the client, 
the "local_tmp" directory seems to be owned by user nobody?

I have sent you privately the requested tcpdump trace.

Thank you.
Jiri Horky




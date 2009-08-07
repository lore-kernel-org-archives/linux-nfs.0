Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:30178
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754879AbZHGGmY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Aug 2009 02:42:24 -0400
Message-ID: <4A7BCCCA.4020307@panasas.com>
Date: Fri, 07 Aug 2009 09:42:18 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: =?ISO-8859-1?Q?Carlos_Andr=E9?= <candrecn@gmail.com>
CC: nfsv4@linux-nfs.org, Steve Dickson <steved@redhat.com>,
        "J. Bruce Fields" <bfields@citi.umich.edu>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: AutoFS+NFSv4 server down = LOOOOONG timeout.
References: <f6ce31e30907291021p769d8bb7jb7a13d0370b87bd6@mail.gmail.com> <f6ce31e30908061718u2c527e2eo5cf35f6eb0800fd4@mail.gmail.com>
In-Reply-To: <f6ce31e30908061718u2c527e2eo5cf35f6eb0800fd4@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Aug. 07, 2009, 3:18 +0300, Carlos André <candrecn@gmail.com> wrote:
> Anyone ?
> 
> 2009/7/29 Carlos André <candrecn@gmail.com>:
>> PPL, I need put a CentOS 5.3 (updated) NFSv4 server to work with Kerberos
>> and AutoFS, but i got a problem: If NFS server goes down i get a LOOOOOOONG
>> mount timeout on CentOS 5.3 (updated) NFSv4 client...
>>
>> Since i need mount some (3 to 6) dirs at user logon process, if mount hangs,
>> user logon hangs. Then i want configure it to timeout (if server down) after
>> 10-15 secs (MAX) on each mount attempt.
>>
>> I already make a lab and tried a LOT of combinations, there my findings
>> (server DOWN IP: 172.16.0.10 / client IP: 172.16.1.10) using basic command
>> (time mount 172.16.0.10:/remotedir /localdir/ -t nfs4 -o
>> sec=krb5,proto=<tcp/udp>) from NFS client:
>>
>> - Once i try access mount point using AutoFS (proto=tcp OR proto=udp) it
>> hangs for 189 secs (3m9s: real  3m9.001s)  until show error (mount: mount to
>> NFS server '172.16.0.10' failed: timed out (giving up))

Sounds like you're hitting the server's grace period.
You can try hacking it in /etc/init.d/nfs
by adding
	echo 15 > /proc/fs/nfsd/nfsv4leasetime

before
        daemon rpc.nfsd $RPCNFSDARGS $RPCNFSDCOUNT

Then, look at your /var/log/messages file for
NFSD: starting 15-second grace period

That said, I'm not sure why it can't be passed as a command line
option to the nfsd daemon and controlled via RPCNFSDARGS
in /etc/sysconfig/nfs

Benny

>>
>> Mounting manually using NFSv4 i got same timeouts of AutoFS.
>>
>> The only way to get a lower timeout value is using only proto=udp,retry=0
>> (not using sec=krb5) any another combination i get 3m9s (sec=krb5,proto=tcp
>>
>>
>> I tried change another NFS mount options putting a lower value (timeo,
>> retrans, retry), and they only change something then i use NFSv3 with
>> proto=udp. But i want NFSv4/TCP (coz Kerberos) and a timeout lower then 15
>> secs... :(
>>
>> I'm using these packages (server and client side):
>> autofs-5.0.1-0.rc2.102.el5_3.1
>> nfs-utils-1.0.9-40.el5
>> kernel-2.6.18-128.1.16.el5
>>
>> The only way to resolve this behavior is changing the source code? There's
>> no way to lower timeout with NFSv4/TCP in this case ?
>>
>> Thanks.
>>
>>
> _______________________________________________
> NFSv4 mailing list
> NFSv4@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4

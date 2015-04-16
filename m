Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:36299 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757194AbbDPMpk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Apr 2015 08:45:40 -0400
Received: by pdea3 with SMTP id a3so90936129pde.3
        for <linux-nfs@vger.kernel.org>; Thu, 16 Apr 2015 05:45:40 -0700 (PDT)
Message-ID: <552FAEEA.2090604@gmail.com>
Date: Thu, 16 Apr 2015 20:45:30 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Eino Juhani Oltedal <e.j.oltedal@fys.uio.no>, linux-nfs@vger.kernel.org
Subject: Re: Problem installing nfs-utils to non standard dir
References: <552E3508.5000403@fys.uio.no> <552E86A8.6080506@gmail.com> <552E9D80.1090003@fys.uio.no> <552F3DE2.4020603@gmail.com> <552F8394.4070701@fys.uio.no>
In-Reply-To: <552F8394.4070701@fys.uio.no>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 4/16/2015 5:40 PM, Eino Juhani Oltedal wrote:
> The arm machine does not have rpcinfo.
> On the server i get this:
>  rpcinfo -p
>    program vers proto   port  service
>     100000    4   tcp    111  portmapper
>     100000    3   tcp    111  portmapper
>     100000    2   tcp    111  portmapper
>     100000    4   udp    111  portmapper
>     100000    3   udp    111  portmapper
>     100000    2   udp    111  portmapper
>     100024    1   udp  43663  status
>     100005    1   udp  20048  mountd
>     100024    1   tcp  39197  status
>     100005    1   tcp  20048  mountd
>     100005    2   udp  20048  mountd
>     100005    2   tcp  20048  mountd
>     100005    3   udp  20048  mountd
>     100005    3   tcp  20048  mountd
>     100003    3   tcp   2049  nfs
>     100003    4   tcp   2049  nfs
>     100227    3   tcp   2049  nfs_acl
>     100003    3   udp   2049  nfs
>     100003    4   udp   2049  nfs
>     100227    3   udp   2049  nfs_acl
>     100021    1   udp  55946  nlockmgr
>     100021    3   udp  55946  nlockmgr
>     100021    4   udp  55946  nlockmgr
>     100021    1   tcp  57551  nlockmgr
>     100021    3   tcp  57551  nlockmgr
>     100021    4   tcp  57551  nlockmgr
> 
> My /etc/exports:
>  /share/ 192.168.0.0/24(rw,fsid=0,no_subtree_check)
>  /share/test 192.168.0.0/24(rw,no_subtree_check,nohide)
> 
> I am able to mount the nfs share on a third computer, but not on the arm computer that uses my build.

It means it's not nfs server's problem.

> On 04/16/2015 06:43 AM, Kinglong Mee wrote:
>> On 4/16/2015 1:18 AM, Eino Juhani Oltedal wrote:
>>> Thank you for the help. I was able to avoid the error by using make DESTDIR=${HOME}/installs/arm
>>> instead of the prefix. Then i copied everything  under ${HOME}/installs/arm over to the root of the
>>> ARM file-system.
>>>
>>> However when trying to use the newly built nfs I get some errors:
>>>
>>> mount -t nfs 192.168.0.104:/test /mnt
>>>      mount.nfs: rpc.statd is not running but is required for remote locking.
>>>      mount.nfs: Either use '-o nolock' to keep locks local, or start statd.
>>>      mount.nfs: an incorrect mount option was specified
>>>
>>> mount -t nfs -o nolock 192.168.0.104:/test /mnt
>>>      mount.nfs: Protocol not supported
>>>
>>>
>>> showmount also gives an error:
>>>      showmount -e 192.168.0.104
>>>      clnt_create: RPC: Unknown protocol

static CLIENT *nfs_get_mount_client(const char *hostname, rpcvers_t vers)
{
        rpcprog_t program = nfs_getrpcbyname(MOUNTPROG, mount_pgm_tbl);
        CLIENT *client;

        client = clnt_create(hostname, program, vers, "tcp");
        if (client)
                return client;
        client = clnt_create(hostname, program, vers, "udp");
        if (client)
                return client;

        clnt_pcreateerror("clnt_create");
        exit(1);
}

Showmount prints the error message only clnt_create both "tcp" and "udp" fail.
Does your arm machine not support "tcp" and "udp"? or the firewalld is up?
Can you check with firewalld stop?

thanks,
Kinglong Mee

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:57107 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752578AbcAHUX6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Jan 2016 15:23:58 -0500
Date: Fri, 8 Jan 2016 15:23:57 -0500
To: Robb <rbarr138@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS v4, are special steps required for uid/gid to work, even if
 they are the same on server and client?
Message-ID: <20160108202357.GE5031@fieldses.org>
References: <CAOHJ0jQyGD=RHCNSTSsOYWCy=o4ryw2X2NCcqs2DmMrXRSFdGg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <CAOHJ0jQyGD=RHCNSTSsOYWCy=o4ryw2X2NCcqs2DmMrXRSFdGg@mail.gmail.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 07, 2016 at 05:02:19PM -0600, Robb wrote:
> I have a NFS server running on CentOS7 nfs-utils-1.3.0-0.21.el7.x86_64
> 
> Basically the oddity I am finding is as follows:
> server and client have same user and group with same uid's and gid's
> 
> Client can only write to an exported folder if it "other/all" permission
> is set to write.  I can get around this by using all_squash and setting
> the anon id's but this isn't really what I want.
> 
> Am I missing a step that would allow this to work without all_squash.
> 
> This is my setup:
> server0: where nfs-server is running
> client:  where export is mounted
> 
> 
> Groups and uids all match on both machines
> [root@server0 ~]# groups user
> user : user common
> [root@server0 ~]# cat /etc/passwd | grep 'common\|^user'
> common:x:20000:20000:common:/home/common:/bin/bash
> user:x:1000:1000::/:/sbin/nologin
> 
> [user@client ~] $ groups user
> user : user lp common
> [user@client ~] $ cat /etc/passwd | grep 'common\|^user'
> user:x:1000:1000:user:/home/user:/bin/bash
> common:x:20000:20000::/:/sbin/nologin
> 
> 
> server0 setup:
> 
> [root@server0 ~]# ls -lr /test*
> drwxrwxrwx. 2 common common 6 Jan  7 16:05 /test_squash/chmod777
> drwxrwxr-x. 2 common common 6 Jan  7 16:06 /test_squash/chmod775
> drwxrwxrwx. 2 common common 6 Jan  7 16:05 /test/chmod777
> drwxrwxr-x. 2 common common 6 Jan  7 16:05 /test/chmod775
> 
> 
> [root@server0 ~]# cat /etc/exports
> /test        192.168.1.0/24(rw,async)
> /test_squash 192.168.1.0/24(rw,async,all_squash,anonuid=20000,anongid=20000)
> 
> [root@server0 ~]# systemctl restart nfs-server
> 
> 
> client setup:
> [user@client ~] $ cat /etc/fstab | grep '^server'
> server0:/test        /test            nfs     defaults        0 0
> server0:/test_squash /test_squash     nfs     defaults        0 0
> 
> [user@client ~] $ sudo mount /test
> [user@client ~] $ sudo mount /test_squash
> 
> [user@client ~] 1 $ touch /test_squash/chmod777/file
> [user@client ~] $ touch /test_squash/chmod775/file
> [user@client ~] $ touch /test/chmod777/file
> [user@client ~] $ touch /test/chmod775/file
> touch: cannot touch ‘/test/chmod775/file’: Permission denied
> 
> [user@client ~] $ ls -lR /test*
> drwxrwxr-x. 2 common common  6 Jan  7 16:05 /test/chmod775
> drwxrwxrwx. 2 common common 17 Jan  7 16:27 /test/chmod777
> -rw-rw-r--. 1 user   user    0 Jan  7 16:27 /test/chmod777/file
> drwxrwxr-x. 2 common common 17 Jan  7 16:28 /test_squash/chmod775
> drwxrwxrwx. 2 common common 17 Jan  7 16:28 /test_squash/chmod777
> -rw-rw-r--. 1 common common  0 Jan  7 16:28 /test_squash/chmod775/file
> -rw-rw-r--. 1 common common  0 Jan  7 16:28 /test_squash/chmod777/file
> 
> 
> 
> So my real question is why cant user:user create a file in /test/chmod775 ?

Hm, and chmod775 should permit write to members of common, and user is a
member of common on both client and server (and names and uids are the
same on both).

I'm not seeing the explanation....

I think the next thing I'd do would be get a network trace:

	1. run "tcpdump -s0 -wtmp.pcap"
	2. try the failed "touch /test/chmod755/file"
	3. kill the tcpdump

Then run "wireshark tmp.pcap" and look at the result.  If this is v4
thee should be an OPEN call in there that tries to create "file", with
the server replying with an error.

It'd be especially interesting to look at the rpc header on that call,
specifically the credential, which should include a list of gid's (with
20000 being one of those gid's).

--b.

> 
> Thanks for any help.
> 
> -Robb
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

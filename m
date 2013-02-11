Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:64830 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758620Ab3BKSc2 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Feb 2013 13:32:28 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Jiri Horky <jiri.horky@gmail.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: RE: NFSv4 server ignores local filesystem's POSIX ACL
Date: Mon, 11 Feb 2013 18:32:26 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA91F3C2047@sacexcmbx05-prd.hq.netapp.com>
References: <51190E62.5090304@gmail.com>
 <20130211182212.GB30117@fieldses.org>
In-Reply-To: <20130211182212.GB30117@fieldses.org>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
> owner@vger.kernel.org] On Behalf Of J. Bruce Fields
> Sent: Monday, February 11, 2013 1:22 PM
> To: Jiri Horky
> Cc: linux-nfs@vger.kernel.org
> Subject: Re: NFSv4 server ignores local filesystem's POSIX ACL
> 
> On Mon, Feb 11, 2013 at 04:29:38PM +0100, Jiri Horky wrote:
> > Hi all,
> >
> > we use NFSv4 with Kerberos and a custom idmap mapping plugin. The
> > mapping is configured in a way that all principals that are not
> > explicitly defined are mapped to nobody/nogroup on a server.
> > Recently, the kerberos infrastructure within our organization expanded
> > by crossrealming with other parties which should not be allowed to use
> > our NFSv4 mounts.
> > It is my understanding that everybody who is able to authenticate
> > against the used kerberos infrastructure can mount the filesystems but
> > nonauthorized users will be mapped to user nobody/nogroup and
> > according to server's filesystem rights can do other actions. Now, I
> > would like to set deny ACL for user nobody to the server's /exports
> > directory to restrict nobody user access. But it seems this ACL is
> > ignored. In fact, local POSIX ACL's on any directory seems to
> > ignored:
> >
> > SERVER:
> > root@store4 /exports # mkdir local_tmp
> > root@store4 /exports # chmod 777 local_tmp/
> > root@store4 /exports # setfacl -m u:nobody:--- /exports/local_tmp/
> > root@store4 /exports # getfacl /exports/local_tmp/
> > getfacl: Removing leading '/' from absolute path names # file:
> > exports/local_tmp/ # owner: root # group: root user::rwx
> > user:nobody:---
> > group::rwx
> > mask::rwx
> > other::rwx
> > root@store4 /exports # su nobody -c "touch /exports/local_tmp/filelocal"
> > touch: cannot touch `/exports/local_tmp/filelocal': Permission denied
> >
> > so far so good, now on a client:
> >
> > CLIENT:
> > metex-1:~# mount -t nfs4 -o sec=krb5 store4.du1.cesnet.cz:/ /mnt
> > metex-1:~# touch /mnt/local_tmp/a metex-1:~# ls -l /mnt/local_tmp/a
> > -rw-r--r-- 1 nobody nogroup 0 Feb 11 15:23 /mnt/local_tmp/a
> >
> > and on the SERVER again:
> > root@store4 /exports # ls -l /exports/local_tmp/a
> > -rw-r--r-- 1 nobody nogroup 0 Feb 11 15:23 /exports/local_tmp/a
> >
> > So the ACL is ignored when accessing through NFS. Is it the expected
> > behavior and I am just doing something terribly wrong?
> 
> That looks like a bug, but I'm at a loss to explain how it could have happened.
> A network trace (tcpdump -s0 -wtmp.pcap, then send me
> tmp.pcap) taken during the file creation above might be interesting.

If everyone is being squashed to user, nobody and the 'nobody' user owns the file, isn't that just expected behaviour? NFSv3 servers are always supposed to allow reads and writes from the owner, since the protocol itself has no stateful equivalent of open("foo", O_RDWR|O_CREAT, 0);

> 
> > Some more info about server:
> >
> > root@store4 /exports # cat /etc/exports /exports
> >
> *(sec=krb5:krb5i:krb5p,rw,fsid=0,sync,no_subtree_check,no_root_squash,
> > insecure,crossmnt)
> > root@store4 /exports # uname -a
> > Linux fe4 2.6.32.59-0.7.1.du2-default #1 SMP 2012-07-13 15:50:56
> > +0200 x86_64 x86_64 x86_64 GNU/Linux
> > OS is: SLES 11 SP1
> >
> > root@store4 /exports # modinfo nfsd
> > filename: /lib/modules/2.6.32.59-0.7.1.du2-default/kernel/fs/nfsd/nfsd.ko
> > license:        GPL
> > author:         Olaf Kirch <okir@monad.swb.de>
> > srcversion:     74D3604622B7912E7C96E03
> > depends:        auth_rpcgss,sunrpc,lockd,exportfs,nfs_acl
> > supported:      yes
> > vermagic:       2.6.32.59-0.7.1.du2-default SMP mod_unload modversions
> >
> > Our intention is  simply to force nobody users out of our NFS servers.
> 
> It might be better to teach rpc.svcgssd to fail authentications from any users
> outside your local domain.  I'm not sure how to do that.
> 
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in the
> body of a message to majordomo@vger.kernel.org More majordomo info at
> http://vger.kernel.org/majordomo-info.html

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:59081 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752240Ab1IWMBN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Sep 2011 08:01:13 -0400
Date: Fri, 23 Sep 2011 08:01:12 -0400
To: Nattapon Viroonsri <linuxbkk@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: nfs4 AD2008R2 kinit success but mount failed
Message-ID: <20110923120112.GD2904@fieldses.org>
References: <CA+1OVfZpQyLtYauJ4TL7gwXXqL3EF4XKxA_X0Q-=L45ZSGi7fA@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CA+1OVfZpQyLtYauJ4TL7gwXXqL3EF4XKxA_X0Q-=L45ZSGi7fA@mail.gmail.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Sep 22, 2011 at 11:34:23PM +0700, Nattapon Viroonsri wrote:
> Hi,
> 
> I try to use nfs4 authentication with Active directory 2008
> 
> kinit success to authenticated, but mount still faile with permission denied
> Any suggestion , would be appreciate
> 
> nfs server: suse1.reuint.com ( SLES11 SP1)
> nfs client:  krbclient.reuint.com ( SLES11 SP1)

Have you reported this to SUSE?

--b.

> Windows2008 SP2 standard edition:  ad2008.reuint.com ( windows2008R2
> standard edition)
> 
>  package: samba-winbind-3.4.3-1.17.2,
> nfs-kernel-server-1.2.1-2.18.1,nfs-client-1.2.1-2.18.1
>                krb5-1.6.3-133.46.1
> 
> 
> # ------ Both NFS Server and NFS Client can join domain ---------------
> rcwinbind stop
> rcnfsserver stop
> net -Ureutadmin%'mypasswd' ads leave
> net -Ureutadmin%'mypasswd' ads keytab flush
> kdestroy
> \rm /etc/krb5.keytab
> \rm /tmp/kr*
> 
> net -Ureutadmin%'mypasswd' ads join  createupn='nfs/suse1.reuint.com@REUINT.COM'
> net -Ureutadmin%'mypasswd' ads keytab add nfs
> 
> rcwinbind start
> 
> 
> suse1:~/keytab # wbinfo -u
> REUINT\administrator
> REUINT\guest
> REUINT\krbtgt
> REUINT\reutadmin
> 
> 
> 
> suse1:~/keytab # ssh REUINT\\reutadmin@localhost
> Password:
> Last login: Tue Sep 20 10:13:54 2011 from localhost
> Could not chdir to home directory /home/REUINT/reutadmin: No such file
> or directory
> REUINT\reutadmin@suse1:/>exit
> 
> 
> 
> #-------  ON NFS Server -----------------------------------------
> 
> suse1:~/keytab # klist -ke
> Keytab name: FILE:/etc/krb5.keytab
> KVNO Principal
> 
>    2 nfs/suse1.reuint.com@REUINT.COM (DES cbc mode with CRC-32)
>    2 nfs/suse1.reuint.com@REUINT.COM (DES cbc mode with RSA-MD5)
>    2 nfs/suse1.reuint.com@REUINT.COM (ArcFour with HMAC/md5)
>    2 nfs/suse1@REUINT.COM (DES cbc mode with CRC-32)
>    2 nfs/suse1@REUINT.COM (DES cbc mode with RSA-MD5)
>    2 nfs/suse1@REUINT.COM (ArcFour with HMAC/md5)
> 
> suse1:~/keytab # kinit -V  -k  nfs/suse1.reuint.com@REUINT.COM
> Authenticated to Kerberos v5
> 
> 
> #-------  ON NFS Client  -----------------------------------------------
> 
> krbclient:~ # klist -ke
> 
> Keytab name: FILE:/etc/krb5.keytab
> KVNO Principal
>    2 nfs/krbclient.reuint.com@REUINT.COM (DES cbc mode with CRC-32)
>    2 nfs/krbclient.reuint.com@REUINT.COM (DES cbc mode with RSA-MD5)
>    2 nfs/krbclient.reuint.com@REUINT.COM (ArcFour with HMAC/md5)
>    2 nfs/krbclient@REUINT.COM (DES cbc mode with CRC-32)
>    2 nfs/krbclient@REUINT.COM (DES cbc mode with RSA-MD5)
>    2 nfs/krbclient@REUINT.COM (ArcFour with HMAC/md5)
> 
> krbclient:~ # kinit -V -k nfs/krbclient.reuint.com
> Authenticated to Kerberos v5
> 
> 
> krbclient:~ # showmount -e suse1.reuint.com
> Export list for suse1.reuint.com:
> /media/nfs4server gss/krb5i,gss/krb5
> 
> krbclient:~ # mount -vvv -tnfs4 -o sec=krb5  suse1.reuint.com:/  /media/nfs/
> mount: fstab path: "/etc/fstab"
> mount: mtab path:  "/etc/mtab"
> mount: lock path:  "/etc/mtab~"
> mount: temp path:  "/etc/mtab.tmp"
> mount: UID:        0
> mount: eUID:       0
> mount: spec:  "suse1.reuint.com:/"
> mount: node:  "/media/nfs/"
> mount: types: "nfs4"
> mount: opts:  "sec=krb5"
> mount: external mount: argv[0] = "/sbin/mount.nfs4"
> mount: external mount: argv[1] = "suse1.reuint.com:/"
> mount: external mount: argv[2] = "/media/nfs/"
> mount: external mount: argv[3] = "-v"
> mount: external mount: argv[4] = "-o"
> mount: external mount: argv[5] = "rw,sec=krb5"
> mount.nfs4: timeout set for Tue Sep 20 11:05:15 2011
> mount.nfs4: trying text-based options
> 'sec=krb5,addr=192.168.125.130,clientaddr=192.168.125.132'
> mount.nfs4: mount(2): Permission denied
> mount.nfs4: access denied by server while mounting suse1.reuint.com:/
> 
> ----------------------------------------------
> 
> Rgds,
> Nattapon
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

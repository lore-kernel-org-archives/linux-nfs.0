Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:38540 "EHLO
	relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751437Ab3IQBLL convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 Sep 2013 21:11:11 -0400
Date: Mon, 16 Sep 2013 20:11:05 -0500
From: Contact <contact@ryper.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: 16+ GID issue, mountd's --manage-gids not helping
Message-ID: <20130916201105.717449b1@svelte.ryper.org>
In-Reply-To: <20130917003825.GD25308@fieldses.org>
References: <20130916094351.263d433d@svelte.ryper.org>
	<20130916193709.GA25308@fieldses.org>
	<20130916175612.012d7301@svelte.ryper.org>
	<20130916232024.GC25308@fieldses.org>
	<20130917003825.GD25308@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

My apologies for not providing the information that you requested.

(client)
rypervenche@svelte ~ $ id
uid=1000(rypervenche) gid=1000(rypervenche)
groups=1000(rypervenche),4(adm),6(disk),7(lp),10(wheel),16(cron),18(audio),27(video),35(games),70(postgres),85(usb),100(users),103(vboxusers),105(wireshark),106(lpadmin),244(plugdev),246(crontab),250(portage),1100(nfs)

(server)
nfs@noir ~ $ id
uid=1100(nfs) gid=1100(nfs) groups=1100(nfs)

I expect to see GID 1100 in the output of
"cat /proc/net/rpc/auth.unix.gid/content"

My friend who is using a Mac is able to mount the NFS mount just fine
and I can use it when using "newgrp", so I believe it is configured
correctly. I would just like to be able to have GUI access without
needing to use newgrp.

Thank you.


On Mon, 16 Sep 2013 20:38:25 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Mon, Sep 16, 2013 at 07:20:24PM -0400, J. Bruce Fields wrote:
> > On Mon, Sep 16, 2013 at 05:56:12PM -0500, Contact wrote:
> > > Hello,
> > > 
> > > I was assuming it would grab all of my GIDs as it appears to do
> > > in the following link:
> > > https://xkyle.com/solving-the-nfs-16-group-limit-problem/
> > > 
> > > Just under the quote:
> > > "Also, the NFS server will cache group lookups so it doesn’t have
> > > to continuously make queries. The cache is visible like this:"
> > > 
> > > The GID 1000 is my primary user on both boxes (rypervenche).
> > > 
> > > If there is another way to do this (aside maybe from setting up
> > > kerberos/ldap) I would be willing to try that.
> > 
> > Could you please answer the two questions which I asked in my
> > previous email?
> 
> To make them more concrete:
> 
> 	- if you run "id rypervenche" on the server, what is the
> output?
> 	- on the output from "cat /proc/net/rpc/auth.unix.gid/content"
> 	  which you list below, which id that you expected to be
> present is not included?
> 
> --b.
> 
> > 
> > --b.
> > 
> > > 
> > > Thank you.
> > > 
> > > 
> > > On Mon, 16 Sep 2013 15:37:09 -0400
> > > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > > 
> > > > On Mon, Sep 16, 2013 at 09:43:51AM -0500, Contact wrote:
> > > > > Hi all,
> > > > > 
> > > > > I'm having an issue with my NFS mount and being able to
> > > > > access it from my normal user account. The mount point is
> > > > > chmod'ed to 2770 with a GID of 1100 (nfs) which is the same
> > > > > on both systems. I can access it if I change my active group
> > > > > using newgrp, but not normally.
> > > > > 
> > > > > ====================================
> > > > > noir ~ # ls -lhd /home/nfs/share
> > > > > drwxrws--- 8 nfs nfs 4.0K Sep  4 15:30 /home/nfs/share
> > > > > 
> > > > > rypervenche@svelte ~ $ pwd
> > > > > /home/rypervenche
> > > > > rypervenche@svelte ~ $ cd nfs
> > > > > -su: cd: nfs: Permission denied
> > > > > rypervenche@svelte ~ $ newgrp nfs
> > > > > rypervenche@svelte ~ $ cd nfs
> > > > > rypervenche@svelte ~/nfs $ 
> > > > > 
> > > > > svelte ~ # grep nfs /etc/group
> > > > > nfs:x:1100:rypervenche
> > > > > ====================================
> > > > > 
> > > > > You can find the details of my NFS server and client here:
> > > > > 
> > > > > ====================================
> > > > > svelte = client
> > > > > noir = server
> > > > > 
> > > > > svelte ~ # tail -1 /etc/fstab
> > > > > 192.168.1.100:/ /home/rypervenche/nfs   nfs
> > > > > rw,noauto,noexec,nodev,nosuid   0       0
> > > > > 
> > > > > noir ~ # cat /etc/exports 
> > > > > # /etc/exports: NFS file systems being exported.  See
> > > > > exports(5). /home/nfs/share
> > > > > 192.168.1.205(rw,sync,fsid=0,no_root_squash,no_subtree_check)
> > > > > 192.168.2.100(rw,sync,fsid=0,no_root_squash,no_subtree_check)
> > > > > 
> > > > > noir ~ # id nfs
> > > > > uid=1100(nfs) gid=1100(nfs) groups=1100(nfs)
> > > > > 
> > > > > noir ~ # grep -v ^# /etc/conf.d/nfs | grep -v ^$
> > > > > NFS_NEEDED_SERVICES="rpc.idmapd"
> > > > > OPTS_RPC_NFSD="8"
> > > > > OPTS_RPC_MOUNTD="-V 4 --manage-gids -p 32767"
> > > > > OPTS_RPC_STATD="-p 32765 -o 32766"
> > > > > OPTS_RPC_IDMAPD=""
> > > > > OPTS_RPC_GSSD=""
> > > > > OPTS_RPC_SVCGSSD=""
> > > > > OPTS_RPC_RQUOTAD=""
> > > > > EXPORTFS_TIMEOUT=30
> > > > > 
> > > > > noir ~ # iptables-save | egrep '(NFS|T -m conn)'
> > > > > -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
> > > > > -A INPUT -s 192.168.1.205/32 -p tcp -m tcp -m multiport
> > > > > --dports 111,2049,4001,32765:32767 -m conntrack --ctstate NEW
> > > > > -m comment --comment NFS -j ACCEPT -A INPUT -s
> > > > > 192.168.1.205/32 -p udp -m udp -m multiport --dports
> > > > > 111,2049,4001,32765:32767 -m conntrack --ctstate NEW -m
> > > > > comment --comment NFS -j ACCEPT -A INPUT -s 192.168.2.100/32
> > > > > -p tcp -m tcp -m multiport --dports 111,2049,4001,32765:32767
> > > > > -m conntrack --ctstate NEW -m comment --comment NFS -j ACCEPT
> > > > > -A INPUT -s 192.168.2.100/32 -p udp -m udp -m multiport
> > > > > --dports 111,2049,4001,32765:32767 -m conntrack --ctstate NEW
> > > > > -m comment --comment NFS -j ACCEPT
> > > > > 
> > > > > svelte:
> > > > > net-fs/nfs-utils-1.2.6 was built with the following:
> > > > > USE="ipv6 nfsdcld nfsidmap nfsv4 nfsv41 tcpd -caps -kerberos
> > > > > (-selinux)"
> > > > > 
> > > > > noir:
> > > > > net-fs/nfs-utils-1.2.6 was built with the following:
> > > > > USE="ipv6 (multilib) nfsdcld nfsidmap nfsv4 nfsv41 tcpd -caps
> > > > > -kerberos (-selinux)" ABI_X86="64"
> > > > > 
> > > > > svelte ~ # uname -a
> > > > > Linux svelte 3.10.7-gentoo-svelte #1 SMP Thu Aug 22 17:46:44
> > > > > CDT 2013 i686 Intel(R) Atom(TM) CPU N450 @ 1.66GHz
> > > > > GenuineIntel GNU/Linux
> > > > > 
> > > > > noir ~ # uname -a
> > > > > Linux noir 3.10.7-gentoo-noir #1 SMP Wed Aug 28 11:19:43 CDT
> > > > > 2013 x86_64 AMD Athlon(tm) II X2 260 Processor AuthenticAMD
> > > > > GNU/Linux ====================================
> > > > > 
> > > > > 
> > > > > I found online that the issue is due to NFS not being able to
> > > > > grab over 16 GIDs. I found help in the following two links:
> > > > > 
> > > > > https://xkyle.com/solving-the-nfs-16-group-limit-problem/
> > > > > https://wiki.archlinux.org/index.php/NFS_Troubleshooting
> > > > > 
> > > > > I tried adding the --manage-gids flag to mountd (which can be
> > > > > seen in the /etc/conf.d/nfs file above), however, it does not
> > > > > appear to resolve the issue.
> > > > > 
> > > > > ====================================
> > > > > noir ~ #
> > > > > cat /proc/net/rpc/auth.unix.gid/content #uid cnt: gids...
> > > > > 0 10: 0 1 2 3 4 6 10 11 26 27
> > > > > 1000 9: 10 18 19 27 78 85 100 250 1000
> > > > > 
> > > > > noir ~ # date +%s > /proc/net/rpc/auth.unix.gid/flush     
> > > > >                                                                                                                               
> > > > > noir ~ #
> > > > > cat /proc/net/rpc/auth.unix.gid/content #uid cnt: gids...
> > > > > 
> > > > > Then I mount the NFS again:
> > > > > 
> > > > > noir ~ # cat /proc/net/rpc/auth.unix.gid/content
> > > > > #uid cnt: gids...
> > > > > 0 10: 0 1 2 3 4 6 10 11 26 27
> > > > > 1000 9: 10 18 19 27 78 85 100 250 1000
> > > > > ====================================
> > > > > 
> > > > > It looks as though it is not grabbing all of my GIDs.
> > > > 
> > > > What do you expect the list to be?  Which groups is uid 1000 a
> > > > member of on the server?
> > > > 
> > > > --b.
> > > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe
> > linux-nfs" in the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html


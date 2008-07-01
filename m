From: Carsten Aulbert <carsten.aulbert-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>
Subject: Massive NFS problems on large cluster with large number of mounts
Date: Tue, 01 Jul 2008 10:19:55 +0200
Message-ID: <4869E8AB.4060905@aei.mpg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Henning Fehrmann <henning.fehrmann-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>,
	Steffen Grunewald <steffen.grunewald-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from welcomes-you.com ([85.214.50.128]:46250 "EHLO
	smtp.welcomes-you.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753880AbYGAInB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Jul 2008 04:43:01 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all (now to the right email list),

We are running a large cluster and do a lot of cross-mounting between
the nodes. To get this running we are running a lot of nfsd (196) and
use mountd with 64 threads, just in case we get a massive number of hit=
s
onto a single node. All this is on Debian Etch with a recent 2.6.24
kernel using autofs4 at the moment to do the automounts.

When running these two not nice scripts:

$ cat test_mount
#!/bin/sh

n_node=3D1000

for i in `seq 1 $n_node`;do
        n=3D`echo $RANDOM%1342+10001 | bc| sed -e "s/1/n/"`
        $HOME/bin/mount.sh $n&
        echo -n .
done

$ cat mount.sh
#!/bin/sh

dir=3D"/distributed/spray/data/EatH/S5R1"

ping -c1 -w1 $1 > /dev/null&& file=3D"/atlas/node/$1$dir/"`ls -f
/atlas/node/$1$dir/|head -n 50 | tail -n 1`
md5sum ${file}

With that we encounter different problems:

Running this gives this in syslog:
Jul  1 07:37:19 n1312 rpc.idmapd[2309]: nfsopen:
open(/var/lib/nfs/rpc_pipefs/nfs/clntaa58/idmap): Too many open files
Jul  1 07:37:19 n1312 rpc.idmapd[2309]: nfsopen:
open(/var/lib/nfs/rpc_pipefs/nfs/clntaa58/idmap): Too many open files
Jul  1 07:37:19 n1312 rpc.idmapd[2309]: nfsopen:
open(/var/lib/nfs/rpc_pipefs/nfs/clntaa5e/idmap): Too many open files
Jul  1 07:37:19 n1312 rpc.idmapd[2309]: nfsopen:
open(/var/lib/nfs/rpc_pipefs/nfs/clntaa5e/idmap): Too many open files
Jul  1 07:37:19 n1312 rpc.idmapd[2309]: nfsopen:
open(/var/lib/nfs/rpc_pipefs/nfs/clntaa9c/idmap): Too many open files

Which is not surprising to me. However, there are a few things I'm
wondering about.

(1) All our mounts use nfsvers=3D3 why is rpc.idmapd involved at all?
(2) Why is this daemon growing so extremely large?
# ps aux|grep rpc.idmapd
root      2309  0.1 16.2 2037152 1326944 ?     Ss   Jun30   1:24
/usr/sbin/rpc.idmapd
NOTE: We are now disabling this one, but still it wouldbe nice to
understand why there seem to be a memory leak.

(3) The script maxes out at about 340 concurrent mounts, any idea how t=
o
increase this number? We are already running all servers with the
insecure option, thus low ports should not be a restriction.
(4) After running this script /etc/mtab and /proc/mounts are out of
sync. Ian Kent from autofs fame suggested a broken local mount
implementation which does not lock mtab well enough. Any idee about tha=
t?

We are currently testing autofs5 and this is not giving these messages,
but still we are not using high/unprivilidged ports.

TIA for any help you might give us.

Cheers

Carsten

--=20
Dr. Carsten Aulbert - Max Planck Institut f=C3=BCr Gravitationsphysik
Callinstra=C3=9Fe 38, 30167 Hannover, Germany
=46on: +49 511 762 17185, Fax: +49 511 762 17193
http://www.top500.org/system/9234 | http://www.top500.org/connfam/6/lis=
t/31

Received: from ssl.schu.net (ssl.schu.net [136.143.158.4])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3E9D442EEBD
	for <linux-nfs@vger.kernel.org>; Fri,  6 Mar 2026 19:46:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=136.143.158.4
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1772826419; cv=none; b=ayxbBN8pAp45CZFAzklqp7VQQ1Q14tcL9IHqesu7vQiM3P+omlAITMQczyek1miB7GZjI8eitioGy40IOFT4wPWVebD9XLWsyuATicMGG93vhSzUXNLAPbQ84BikX5Whm2ltVDq3aKXa/hipOMYWI9TaZc+8j06nFsiy4hoYzp0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1772826419; c=relaxed/simple;
	bh=w9PEg83cGjkiWahXhW4WH3SbDUNYJankLt9TmXSyTuc=;
	h=Message-ID:Date:MIME-Version:To:From:Subject:Content-Type; b=Hy9Z4aTNnseQzoxEDB7k4g05e/qLYlkbV+E7HfyWTkRyYrAPDOpBHOBje3KnA0JSQrzTSuXf0SXnB/TKah0+k5ezCUT8ENOSCof1GOF+Q336iWLlRuSMPMTbjN75Tw25gaxJ5kforciq9cJzjzBts7PGDsuwPU06a5g96XhBjfc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=schu.net; spf=pass smtp.mailfrom=schu.net; dkim=pass (2048-bit key) header.d=schu.net header.i=schu@schu.net header.b=otGg6zq7; arc=none smtp.client-ip=136.143.158.4
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=schu.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=schu.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=schu.net header.i=schu@schu.net header.b="otGg6zq7"
Received: from [192.168.120.145] (2-97-186-64.aptalaska.net [64.186.97.2])
	(authenticated bits=0)
	by ssl.schu.net (8.15.2/8.15.2) with ESMTPSA id 626Jkv9d028607
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Fri, 6 Mar 2026 11:46:57 -0800
Message-ID: <0d586513-819c-4af9-8c9f-8d09d326e547@schu.net>
Date: Fri, 6 Mar 2026 11:46:56 -0800
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
To: linux-nfs@vger.kernel.org
Content-Language: en-US
From: Matthew Schumacher <schu@schu.net>
Subject: Current state of nfsdv4 recovery.
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
X-Spam-Report: Content analysis details:   (-1.3 points)
	pts  rule name              description
	---- ---------------------- -------------------------------------------
	-1.0 ALL_TRUSTED            Passed through trusted hosts only via SMTP
	-0.3 BAYES_05               BODY: Bayes spam probability is 1 to 5%
	                            [score: 0.0257]
X-Spam-Bayes: Learn: no autolearn_force=no
X-Spam-Score: No, -1.3 hits
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed; d=schu.net; h=message-id
	:date:mime-version:to:from:subject:content-type
	:content-transfer-encoding; s=schu; i=schu@schu.net; t=
	1772826417; bh=w9PEg83cGjkiWahXhW4WH3SbDUNYJankLt9TmXSyTuc=; b=o
	tGg6zq7iKVEeVugkzOLiPMlHhWlPSCKmBWBCKrvdVN/WjsFeuau0ZJ6UbzJl6kyS
	OCDeRcl6KmCXXSdY8YiRAXlF51zsFKYA+dfzjvxR511jT654bf8Hk+gCQzWWC57A
	7jh3R2RpEgCZFCy8kueSjUau6tpO+/cpkR5NBFBU3jL0lcXKBonYiawic7E4kQJY
	CUHXrAGN9798Tpc3vpSON0N5FbQ2XeOx0zkda+ciwfV7jg7OiSs2jDslqHC06FeE
	GvIElGvSpjcmThSnRuoAsknW5iPEf8cs5xwDD0hbVDRsmgjC3l1hllZZ36j+3xKH
	m9WxeI5hWT5TrWD0jNuGA==
X-Scanned-By: MIMEDefang 3.2 on 192.168.98.12

Hello List,

I am building an HA nfsv4 cluster and need to have my locking migrate 
when a node fails or goes into standby for maint.  There is a lot of 
documentation around the net, but some of it seems old, like this: 
https://wiki.linux-nfs.org/wiki/index.php/Nfsd4_server_recovery. I think 
I have what I need worked out, but I'm still losing locks on recovery.  
Can someone help me understand how this currently works or point me to 
the up to date documentation?

This is what I'm currently doing:

Moving from nodeA to nodeB

NodeA: Remove nfsd ip address
NodeA: /usr/sbin/exportfs -au
NodeA: /usr/sbin/rpc.nfsd 0
NodeA: killall --ns $$ -q -v -w rpc.mountd
NodeA: killall --ns $$ -q -v -w nfsdcld
NodeA: killall --ns $$ -q -v -w rpc.idmapd
NodeA: killall --ns $$ -q -v -w rpcbind
NodeA: umount /var/lib/nfs/rpc_pipefs
NodeA: zpool export (which umounts /var/lib/nfs)

NodeB: zpool import (which mounts /var/lib/nfs)
NodeB: mount /proc/fs/nfs if not previously mounted
NodeB: mount -t rpc_pipefs -o nodev sunrpc /var/lib/nfs/rpc_pipefs
NodeB: /sbin/rpcbind -l -w
NodeB: /usr/sbin/rpc.idmapd
NodeB: /usr/sbin/nfsdcld -d
NodeB: /usr/sbin/exportfs -av
NodeB: /usr/sbin/rpc.mountd
NodeB: /usr/sbin/rpc.nfsd -s -V 4.2 -U -t 8
NodeB: start nfsd ip address

 From what I understand, nfsdcld writes the lock information to 
/var/lib/nfs/nfsdcltrack/main.sqlite which is moved to the other side 
and everything is started, but I still lose locks when I migrate.

Mar  6 08:39:14 nfsha user.warn kernel: [37675.787509] NFS: 
10.255.255.3: lost 1 locks

I think the problem is that kernel (6.12.74) isn't getting the locks 
reported to it when nfsdcld starts.  Here are some logs:

Mar  6 08:38:46 nfsha daemon.warn rpc.idmapd[14113]: Setting log level to 0
Mar  6 08:38:46 nfsha daemon.warn rpc.idmapd[14113]: libnfsidmap: Unable 
to determine the NFSv4 domain; Using 'localdomain' as the NFSv4 domain 
which means UIDs will be mapped to the 'Nobody-User' user defined in 
/etc/idmapd.conf
Mar  6 08:38:46 nfsha daemon.info nfsdcld[14116]: 
sqlite_startup_query_grace: current_epoch=2 recovery_epoch=1
Mar  6 08:38:46 nfsha daemon.info nfsdcld[14116]: 
sqlite_check_db_health: returning 0
Mar  6 08:38:46 nfsha daemon.info nfsdcld[14116]: attaching 
/var/lib/nfs/nfsdcltrack/main.sqlite
Mar  6 08:38:46 nfsha daemon.notice rpc.mountd[14125]: Version 2.8.5 
starting
Mar  6 08:38:46 nfsha daemon.info nfsdcld[14116]: detaching database
Mar  6 08:38:46 nfsha daemon.info nfsdcld[14116]: 
sqlite_copy_cltrack_records: returning 0
Mar  6 08:38:46 nfsha daemon.info nfsdcld[14116]: sqlite_prepare_dbh: 
num_cltrack_records = 2
Mar  6 08:38:47 nfsha user.info kernel: [37649.053531] NFSD: Using UMH 
upcall client tracking operations.
Mar  6 08:38:47 nfsha user.info kernel: [37649.055262] NFSD: Using UMH 
upcall client tracking operations.
Mar  6 08:38:47 nfsha user.info kernel: [37649.055264] NFSD: starting 
90-second grace period (net f0000000)
Mar  6 08:38:47 nfsha daemon.info nfsdcld[14116]: sqlite_prepare_dbh: 
num_legacy_records = 0
Mar  6 08:38:47 nfsha daemon.info nfsdcld[14116]: cld_pipe_init: init 
pipe handlers
Mar  6 08:38:47 nfsha daemon.info nfsdcld[14116]: cld_pipe_open: opening 
upcall pipe /var/lib/nfs/rpc_pipefs/nfsd/cld
Mar  6 08:38:47 nfsha daemon.info nfsdcld[14116]: cld_pipe_open: open of 
/var/lib/nfs/rpc_pipefs/nfsd/cld failed: No such file or directory
Mar  6 08:38:47 nfsha daemon.info nfsdcld[14116]: main: Starting event 
dispatch handler.
Mar  6 08:38:47 nfsha daemon.info IPaddr(failover-ip)[14153]: INFO: eval 
ifconfig eth3:0 10.255.255.3 netmask 255.255.255.0 broadcast 10.255.255.255
Mar  6 08:38:47 nfsha daemon.notice rpc.mountd[14125]: v4.2 client 
attached: 0x7bdfeba269ab0316 from "10.255.255.2:47380"
Mar  6 08:39:13 nfsha daemon.notice rpc.mountd[14125]: v4.2 client 
attached: 0x7bdfeba369ab0316 from "10.255.255.1:49220"
Mar  6 08:39:14 nfsha user.warn kernel: [37675.787509] NFS: 
10.255.255.3: lost 1 locks

I think the problem is that nfsdcld can't pass the locks to the kernel 
using /var/lib/nfs/rpc_pipefs/nfsd/cld as it's missing.  I'm not sure 
why, /var/lib/nfs/rpc_pipefs/ has everything else:

find /var/lib/nfs/rpc_pipefs/
/var/lib/nfs/rpc_pipefs/
/var/lib/nfs/rpc_pipefs/gssd
/var/lib/nfs/rpc_pipefs/gssd/clntXX
/var/lib/nfs/rpc_pipefs/gssd/clntXX/gssd
/var/lib/nfs/rpc_pipefs/gssd/clntXX/info
/var/lib/nfs/rpc_pipefs/nfsd
/var/lib/nfs/rpc_pipefs/cache
/var/lib/nfs/rpc_pipefs/nfsd4_cb
/var/lib/nfs/rpc_pipefs/statd
/var/lib/nfs/rpc_pipefs/portmap
/var/lib/nfs/rpc_pipefs/nfs
/var/lib/nfs/rpc_pipefs/nfs/blocklayout
/var/lib/nfs/rpc_pipefs/nfs/clnt1
/var/lib/nfs/rpc_pipefs/nfs/clnt1/info
/var/lib/nfs/rpc_pipefs/nfs/clnt0
/var/lib/nfs/rpc_pipefs/nfs/clnt0/info
/var/lib/nfs/rpc_pipefs/mount
/var/lib/nfs/rpc_pipefs/lockd

Anyone able to point me in the right direction?  I feel like I'm pretty 
close to getting this to work.

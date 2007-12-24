From: Fabian Steiner <lists-A1xC5SIKT5unwkN7LPkuEg@public.gmane.org>
Subject: [NFS] Attempting to mount a large number of directories
Date: Mon, 24 Dec 2007 12:00:08 +0100
Message-ID: <200712241200.08410.lists@fabis-site.net>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_4E5bH6ZaPcz9an9"
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:56070 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751806AbXL1ITb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 28 Dec 2007 03:19:31 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1J8ARG-0004Vg-I5
	for linux-nfs@vger.kernel.org; Fri, 28 Dec 2007 19:19:30 +1100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Boundary-00=_4E5bH6ZaPcz9an9
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hello!

After having finished the migration to our new setup (user home directories 
are mounted automatically using autofs [4.1.4-8ubuntu1] and NFSv3) we are 
experiencing some problems which use to occur whenever many users attempt to 
access their directories. If such an issue appears the following messages 
will be seen in /var/log/syslog of the server:

Dec 23 18:38:00 ubuntu1 mountd[8995]: refused mount request from client 
for /exports/dir157 (/exports): illegal port 59537

At first we thought it would be an autofs problem but after having tried to 
reproduce the problem employing normal nfs mounts we encountered the same 
issues. The attached scripts might help you to reproduce it.

Running these scripts reveal that mounting 105 directories work, the 106th 
fails, however, resulting in the following error: 

[...]
Working on dir 105 ...nfs bindresvport: Address already in use
OK
Working on dir 106 ...mount: 192.168.0.46:/exports/dir106: can't read 
superblock
OK
[...]

At next, I added the "insecure" option to my /etc/exports file and increased 
the value of /proc/sys/sunrpc/max_resvport from 1023 to 5000. Now 139 
directories can be mounted without any single error, then "nfs bindresvport: 
Address already in use" appears again and mounting 141-172 also works fine. 
Afterwards all the other mount attempts are failing.

Could you explain this behaviour? What does "nfs bindresvport: Address already 
in use" try to tell me? Generally speaking both the server as well as the 
client should run out of open ports.

Merry Christmas and relaxing holidays,
Fabian :-)
























--Boundary-00=_4E5bH6ZaPcz9an9
Content-Type: text/plain;
  charset="us-ascii";
  name="CONSTANTS"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="CONSTANTS"

SERVER="192.168.0.46"
SERVER_BASE="/exports"

CLIENT_BASE="/nfs-mounts"

--Boundary-00=_4E5bH6ZaPcz9an9
Content-Type: application/x-shellscript;
  name="create_dirs.sh"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="create_dirs.sh"

#!/bin/bash

if [[ -z $1 ]]; then
    echo "Specify the number of dirs to be created."
    exit 1
fi

NUM=$1
BASE="/exports/"

for i in `seq 0 $NUM`; do
    mkdir "${BASE}/dir${i}"
done
--Boundary-00=_4E5bH6ZaPcz9an9
Content-Type: application/x-shellscript;
  name="mount_all.sh"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="mount_all.sh"

#!/bin/bash

if [[ -z $1 ]]; then
    echo "Specify the number of dirs to be mounted"
    exit 1
fi

if [[ ! -e CONSTANTS ]]; then
    echo "CONSTANTS file couldn't be found."
    exit 1
else
    source CONSTANTS
fi

NUM=$1

for i in `seq 0 $NUM`; do
    echo -n "Working on dir ${i} ..."
    mkdir "${CLIENT_BASE}/dir${i}"
    mount -t nfs -o rw,hard,intr,nodev,nosuid,exec "${SERVER}:${SERVER_BASE}/dir${i}" "${CLIENT_BASE}/dir${i}"
    echo "OK"
done

--Boundary-00=_4E5bH6ZaPcz9an9
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
--Boundary-00=_4E5bH6ZaPcz9an9
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

--Boundary-00=_4E5bH6ZaPcz9an9--



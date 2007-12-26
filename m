From: Fabian Steiner <lists-A1xC5SIKT5unwkN7LPkuEg@public.gmane.org>
Subject: Attempting to mount a large number of directories
Date: Wed, 26 Dec 2007 17:07:51 +0100
Message-ID: <200712261707.52224.lists@fabis-site.net>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_YxncHr36K5JTyRJ"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from zucker.schokokeks.org ([85.10.204.247]:47426 "EHLO
	zucker.schokokeks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750972AbXLZQMo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Dec 2007 11:12:44 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Boundary-00=_YxncHr36K5JTyRJ
Content-Type: text/plain;
  charset="iso-8859-1"
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

Cheers,
Fabian

--Boundary-00=_YxncHr36K5JTyRJ
Content-Type: text/plain;
  charset="us-ascii";
  name="CONSTANTS"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="CONSTANTS"

SERVER="192.168.0.46"
SERVER_BASE="/exports"

CLIENT_BASE="/nfs-mounts"

--Boundary-00=_YxncHr36K5JTyRJ
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
--Boundary-00=_YxncHr36K5JTyRJ
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

--Boundary-00=_YxncHr36K5JTyRJ--

From: pwitting@Cyveillance.com
Subject: RedHat 8.0 nfs
Date: Thu, 20 Mar 2003 11:52:58 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <D38AFB3080F3D311807300B0D0203E53033A94CB@MERCURY>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [63.100.163.69] (helo=mercury.cyveillance.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18w3I3-0004lB-00
	for <nfs@lists.sourceforge.net>; Thu, 20 Mar 2003 08:53:15 -0800
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

I'm migrating some decent sized RH nfs servers to RedHat 8.0. Looking things
over, it seems they've change the nfs scripts fairly significantly, adding
the possibility of a /etc/sysconfig/nfs file (doesn't exist by default) for
storing config parameters. I went ahead and created the sysconfig file using
the defaults, then changed the number of threads from the default 8 

cat /etc/sysconfig/nfs 
# Referenced by Red Hat 8.0 nfs script to set initial values

# Number of threads start. 
RPCNFSDCOUNT=120

# yes, no, or auto (attempts to auto-detect support and enable)
MOUNTD_NFS_V2=auto
MOUNTD_NFS_V3=auto

# Should we tune TCP/IP settings for nfs (consumes RAM)
TUNE_QUEUE=yes
# 256kb recommended minimum size based on SPECsfs NFS benchmarks
# default values:
#       net.core.rmem_default    65535
#       net.core.rmem_max       131071
NFS_QS=262144

# Force rpc.mountd to bind to the specified port num, instead of using 
# the random port number assigned by the portmapper.
#MOUNTD_PORT=

# Any other options can be passed here. The primary option not covered 
# here would be -o num or  --descriptors num; which set the limit of 
# the number of open file descriptors to num. The default is 256.
#RPCMOUNTDOPTS="-o 256"


So what guidelines should I use in setting these values? RH 7.3 limited me
to 128 threads (I got nervous using ALL the possible threads and backed it
off), RH8 supports more. Judging by the /proc, there is a significant amount
of time where all threads are in use, even at 120.

Also, what would be a good number for NFS_QS? Both rmem.default and rmem.max
will be set to this number; should it be a multiple of threads? Say
something like smallest binary power (2^n) greater than 1500 (MTU size) *
$RPCNFSDCOUNT 

So 120*1500 = 180,000 > 262,144, but
   220*1500 = 330,000 > 524,288

Or should RPCNFSDCOUNT itself be some power of 2?

And while we're on the subject of RedHat, any idea how up to date the NFS
code is in their latest kernel (2.4.18-27)? Its nice relying on their bug
testing/security/useful_patches/fixes, but I saw a significant performance
increase by migrating to 2.4.20 a few months ago. I also ran into a wall
trying to integrate the Q-Logic FC drivers I need for some of my systems.

Thanks


-------------------------------------------------------
This SF.net email is sponsored by: Tablet PC.  
Does your code think in ink? You could win a Tablet PC. 
Get a free Tablet PC hat just for playing. What are you waiting for? 
http://ads.sourceforge.net/cgi-bin/redirect.pl?micr5043en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

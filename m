Return-Path: <nfsv4-bounces@linux-nfs.org>
Message-ID: <4A7B2324.9090406@RedHat.com>
Date: Thu, 06 Aug 2009 14:38:28 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [Patch 0/10] NFS Mount Configuration File (Vers 3)
Cc: Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

Hello,

Here is the latest version of these patches. In the version
the following changes were made:

   1) Section headers how have an argument to them. Similar
      to [Server "foobar" ] or [MountPoint "/export"]
   
   2) Only the Section names are now case-less. Its up to
      the caller of the parsing routines to deal with case
      sensitivity of the data.


Here are the pointers to the two previous versions which
will explain the who, what and whys:  

http://marc.info/?l=linux-nfs&m=123663164305546&w=2
http://marc.info/?l=linux-nfs&m=124931114811175&w=2


This entire patch set is available at:
    http://people.redhat.com/steved/mount-conf/ver03/

and on the 'mount_conf-ver03' branch on my experimental git tree:
    git://linux-nfs.org/~steved/nfs-utils-exp.git

Comments?

steved.

_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4

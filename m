Return-Path: <nfsv4-bounces@linux-nfs.org>
Message-ID: <4A76F8E6.2010607@RedHat.com>
Date: Mon, 03 Aug 2009 10:49:10 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [Patch 0/8] NFS Mount Configuration File (Vers 2)
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

This is an updated version of the mount configuration patches
I sent out a few months ago... The main difference in these
patches is this functionality is only enabled by a 
configuration flag (see patch 4/8 for details). 

I have been convinced that its probably best to leave it up to 
the individual users or distros to decide if they want a
system-wide mount configuration file and where the file should live. 

The following patch set introduces a configuration file where 
mount options can be define. The options in the file can be 
applied globally or per server or per mount point. 

The patch set reuses the configuration parsing code that
idmapd uses. I did added a couple enhancements like ignoring
blanks in certain definitions as well as at the beginning of 
assignment statements.

There are man pages include in the patch set but in a
nut shell, the configuration file has three basic types
of sections. A global section, server section and mount point
section. There can only be one global section and multiple 
server and mount point sections.

The mount command prioritize these sections in the following
way:
     * Options on the command line are always used.

     * Options defined in the mount point section are used
       as long a the options are not in the command line options.

     * Options defined in the server section are used as long as
       they are not defined on the command line or in the mount point
       section.

     * Options defined in the global section are used as long as the
       options are not on the command line or in the mount point section
       or in the server section.

This is the first step toward moving the default NFS version from 3 to 4
on the client. Having a configuration file which allows users to define
the maximum and minimum NFS versions that should be negotiated is the
right thing to do... IMHO.. Even though this patch does not does not 
do that, it does lay the ground work for that type of functionality.

The entire patch set is available at:
    http://people.redhat.com/steved/mount-conf/ver02/

and on the 'mount_conf-ver02' branch on my experimental git tree:
    git://linux-nfs.org/~steved/nfs-utils-exp.git

Comments?

steved.
_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4

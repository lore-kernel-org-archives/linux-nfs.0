From: Gilles Quillard <gilles.quillard@bull.net>
Subject: [NFS] support of IPv6 by NFS
Date: Fri, 28 Jan 2005 16:05:53 +0100
Message-ID: <41FA54D1.1090101@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfsv4-bounces@linux-nfs.org>
To: nfs@lists.sourceforge.net, nfsv4@linux-nfs.org
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <nfs.lists.sourceforge.net>

A new version providing patches/packages to add the support of IPv6 by 
NFS is available:

   http://nfsv4.bullopensource.org/patches/nfsv4_ipv6-2

This version contains:
 - kernel patches over linux 2.6.9,
 - a new TI-RPC (Transport Independent RPC) library and a rpcbind 
portmapper,
 - user patches over nfs-utils-1.0.6 and util-linux-2.12 packages.

Changes since nfsv4_ipv6-1:
 - support of IPv6 also by NFSv2 and NFSv3
 - bug fixes
 - add a test status.

Gilles

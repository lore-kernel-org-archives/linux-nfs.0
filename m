From: Gilles Quillard <gilles.quillard@bull.net>
Subject: [NFS] support of IPv6 by NFSv4
Date: Fri, 17 Dec 2004 17:12:18 +0100
Message-ID: <41C30562.8080103@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfsv4-bounces@linux-nfs.org>
To: nfs@lists.sourceforge.net, nfsv4@linux-nfs.org,
	Chuck Lever <cel@citi.umich.edu>, Matt Benjamin <matt@linuxbox.com>
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

I have made a new version of patches/packages to add the support of IPv6 
by NFSv4.

It is available at
    http://nfsv4.bullopensource.org/patches/nfsv4_ipv6-1

This version includes
  - kernel patches over linux 2.6.9,
  - a new TI-RPC (Transport Independent RPC) library and a rpcbind 
portmapper,
  - user patches over nfs-utils-1.0.6 and util-linux-2.12 packages.

This version is still under development.

I will be away until the 3rd of January, so have a merry Christmas and 
I'll answer to your questions as soon as I'm coming back.

Gilles

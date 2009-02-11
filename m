Return-Path: <nfsv4-bounces@linux-nfs.org>
Message-ID: <49932E72.8060209@garzik.org>
Date: Wed, 11 Feb 2009 15:00:50 -0500
From: Jeff Garzik <jeff@garzik.org>
To: linux-nfs@vger.kernel.org
Subject: NFS clients' use of fs_locations?
Cc: nfsv4@linux-nfs.org
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
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

According to the NFSv4 spec (section 6.1), regarding fs_locations,

	On first access of the filesystem, the client should obtain the
	value of the fs_locations attribute. If, in the future, the
	client finds the server unresponsive, the client may attempt to
	use another server specified by fs_locations.

Does any known client actually fail over to another fs_location, as 
described here?

I am implementing the server side of this...  AFAICT Linux barely uses 
fs_locations, and Solaris just crashes.

	Jeff



_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4

From: Greg Banks <gnb@sgi.com>
Subject: Re: [PATCH] nfs-utils - Silencing mountd
Date: Thu, 17 Jun 2004 08:45:04 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040616224504.GB29503@sgi.com>
References: <40D063D1.9010208@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BajAS-00084F-0G
	for nfs@lists.sourceforge.net; Wed, 16 Jun 2004 15:46:04 -0700
Received: from mtvcafw.sgi.com ([192.48.171.6] helo=omx2.sgi.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BajAR-0000G2-MU
	for nfs@lists.sourceforge.net; Wed, 16 Jun 2004 15:46:03 -0700
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <40D063D1.9010208@RedHat.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

G'day,

On Wed, Jun 16, 2004 at 11:14:25AM -0400, Steve Dickson wrote:
> Here is a patch to the nfs-utils-1.0.6 rpc.mountd that
> eliminates 4 syslog messages that are logged during
> _successful_ mounts and showmount queries. This should
> save quite a bit of disk space w.r.t syslog logs.

Actually, I find the "authenticated mount request from..."  message
useful in tracking down strange but nonfatal bugs on busy servers with
many mounts from many clients.  Not all NFS or RPC error messages
tell you which client was involved, so correlating those messages
with mount messages can help narrow the list.

But the other 3 are noise.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
This SF.Net email is sponsored by The 2004 JavaOne(SM) Conference
Learn from the experts at JavaOne(SM), Sun's Worldwide Java Developer
Conference, June 28 - July 1 at the Moscone Center in San Francisco, CA
REGISTER AND SAVE! http://java.sun.com/javaone/sf Priority Code NWMGYKND
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
